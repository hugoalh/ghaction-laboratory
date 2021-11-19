FROM alpine:3.14
RUN ["apk", "add", "--update", "ca-certificates", "clamav-libunrar", "clamav-scanner", "curl", "freshclam", "git", "icu-libs", "krb5-libs", "less", "libgcc", "libintl", "libssl1.1", "libstdc++", "ncurses-terminfo-base", "tzdata", "userspace-rcu", "zlib"]
RUN ["apk", "-X", "https://dl-cdn.alpinelinux.org/alpine/edge/main", "add", "lttng-ust"]
RUN ["curl", "-L", "https://github.com/PowerShell/PowerShell/releases/download/v7.2.0/powershell-7.2.0-linux-alpine-x64.tar.gz", "-o", "/tmp/powershell.tar.gz"]
RUN ["mkdir", "-p", "/opt/microsoft/powershell/7"]
RUN ["tar", "zxf", "/tmp/powershell.tar.gz", "-C", "/opt/microsoft/powershell/7"]
RUN ["chmod", "+x", "/opt/microsoft/powershell/7/pwsh"]
RUN ["ln", "-s", "/opt/microsoft/powershell/7/pwsh", "/usr/bin/pwsh"]
RUN ["freshclam"]
COPY main.ps1 /
CMD ["pwsh", "-NonInteractive", "/main.ps1"]
