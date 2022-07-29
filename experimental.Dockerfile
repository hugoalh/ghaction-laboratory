FROM clamav/clamav:0.105.1 AS dependency-clamav
FROM bitnami/git:2.37.1-debian-11-r5 AS dependency-git
FROM node:16.16.0-bullseye AS dependency-nodejs
FROM mcr.microsoft.com/powershell:7.2-debian-11 AS dependency-powershell
FROM debian:11.4 AS base
FROM debian:11.4 AS main
COPY --from=dependency-clamav / /
COPY --from=dependency-git / /
COPY --from=dependency-nodejs / /
COPY --from=dependency-powershell / /
COPY --from=base / /
ENV DEBIAN_FRONTEND=noninteractive
RUN ["apt-get", "--assume-yes", "update"]
RUN ["apt-get", "--assume-yes", "install", "git-lfs", "yara"]
RUN ["apt-get", "--assume-yes", "dist-upgrade"]
RUN ["pwsh", "-Command", "Set-PSRepository -Name 'PSGallery' -InstallationPolicy 'Trusted' -Verbose"]
RUN ["pwsh", "-Command", "Install-Module -Name 'PowerShellGet' -MinimumVersion '2.2.5' -Scope 'AllUsers' -AcceptLicense -Verbose"]
RUN ["pwsh", "-Command", "Update-Module -Scope 'AllUsers' -AcceptLicense -Verbose"]
RUN ["pwsh", "-Command", "Install-Module -Name 'hugoalh.GitHubActionsToolkit' -MinimumVersion '0.5.2' -Scope 'AllUsers' -AcceptLicense -Verbose"]
COPY clamd.conf freshclam.conf /etc/clamav/
COPY experimental.ps1 /opt/hugoalh/test/
CMD ["pwsh", "-NonInteractive", "/opt/hugoalh/test/experimental.ps1"]
