FROM alpine:3.14
FROM mcr.microsoft.com/powershell:latest

# Setup PowerShell
#X RUN ["apk", "add", "--update", "ca-certificates", "curl", "icu-libs", "krb5-libs", "less", "libgcc", "libintl", "libssl1.1", "libstdc++", "ncurses-terminfo-base", "tzdata", "userspace-rcu", "zlib"]
#X RUN ["apk", "-X", "https://dl-cdn.alpinelinux.org/alpine/edge/main", "add", "lttng-ust"]
#X RUN ["curl", "-L", "https://github.com/PowerShell/PowerShell/releases/download/v7.2.0/powershell-7.2.0-linux-alpine-x64.tar.gz", "-o", "/tmp/powershell.tar.gz"]
#X RUN ["mkdir", "-p", "/opt/microsoft/powershell/7"]
#X RUN ["tar", "zxf", "/tmp/powershell.tar.gz", "-C", "/opt/microsoft/powershell/7"]
#X RUN ["chmod", "+x", "/opt/microsoft/powershell/7/pwsh"]
#X RUN ["ln", "-s", "/opt/microsoft/powershell/7/pwsh", "/usr/bin/pwsh"]

#X RUN ["apk", "add", "--update", "clamav-libunrar", "clamav-scanner", "freshclam", "git"]
RUN ["apk", "add", "--update", "git"]

#X RUN ["freshclam"]

COPY main.ps1 /
CMD ["pwsh", "-c", "/main.ps1"]
