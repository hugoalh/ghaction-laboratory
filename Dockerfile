FROM mcr.microsoft.com/powershell:alpine-3.14
RUN ["apk", "add", "--update", "clamav", "clamav-clamdscan", "clamav-daemon", "clamav-db", "clamav-doc", "clamav-libs", "clamav-libunrar", "clamav-milter", "clamav-scanner", "freshclam", "git"]
COPY clamd-minify.conf /etc/clamav/clamd.conf
COPY freshclam-minify.conf /etc/clamav/freshclam.conf
COPY main.ps1 /
RUN ["chmod", "+rx", $GITHUB_WORKSPACE]
RUN ["chmod", "+rx", "$GITHUB_WORKSPACE/"]
CMD ["pwsh", "-NonInteractive", "/main.ps1"]
