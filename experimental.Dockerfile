FROM debian:11.4 AS base
# FROM clamav/clamav:0.105.1 AS dependency-clamav
# FROM bitnami/git:2.37.1-debian-11-r5 AS dependency-git
FROM node:16.16.0-bullseye AS dependency-nodejs
FROM mcr.microsoft.com/powershell:7.2-debian-11 AS dependency-powershell

# FROM debian:11.4 AS sourceinstall-yara
# ENV DEBIAN_FRONTEND=noninteractive
# RUN ["apt-get", "--assume-yes", "update"]
# RUN ["apt-get", "--assume-yes", "install", "automake", "gcc", "libssl-dev", "libtool", "make", "pkg-config"]
# RUN ["apt-get", "--assume-yes", "dist-upgrade"]
# ADD https://github.com/VirusTotal/yara/archive/refs/tags/v4.2.2.tar.gz /tmp/yara.tar.gz
# RUN ["mkdir", "--parents", "--verbose", "/opt/microsoft/powershell/7"]
# RUN ["tar", "--extract", "--file=/tmp/powershell-7.2.5-linux-x64.tar.gz", "--directory=/opt/microsoft/powershell/7", "--gzip", "--verbose"]


FROM debian:11.4 AS main
# COPY --from=dependency-clamav / /
# COPY --from=dependency-git / /
COPY --from=dependency-nodejs / /
COPY --from=dependency-powershell / /
COPY --from=base / /
ENV DEBIAN_FRONTEND=noninteractive
RUN ["apt-get", "--assume-yes", "update"]
RUN ["apt-get", "--assume-yes", "install", "ca-certificates", "clamav", "clamav-base", "clamav-daemon", "clamav-freshclam", "clamdscan", "git", "git-lfs", "gss-ntlmssp", "less", "libc6", "libgcc1", "libgssapi-krb5-2", "libicu67", "liblttng-ust0", "libssl1.1", "libstdc++6", "locales", "openssh-client", "yara", "zlib1g"]
RUN ["apt-get", "--assume-yes", "dist-upgrade"]
RUN ["pwsh", "-Command", "Set-PSRepository -Name 'PSGallery' -InstallationPolicy 'Trusted' -Verbose"]
RUN ["pwsh", "-Command", "Install-Module -Name 'PowerShellGet' -MinimumVersion '2.2.5' -Scope 'AllUsers' -AcceptLicense -Verbose"]
RUN ["pwsh", "-Command", "Update-Module -Scope 'AllUsers' -AcceptLicense -Verbose"]
RUN ["pwsh", "-Command", "Install-Module -Name 'hugoalh.GitHubActionsToolkit' -MinimumVersion '0.5.2' -Scope 'AllUsers' -AcceptLicense -Verbose"]
COPY clamd.conf freshclam.conf /etc/clamav/
COPY experimental.ps1 /opt/hugoalh/test/
RUN ["ls", "--all", "--no-group", "--recursive", "/opt"]
CMD ["pwsh", "-NonInteractive", "/opt/hugoalh/test/experimental.ps1"]
