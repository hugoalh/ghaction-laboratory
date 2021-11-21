FROM mcr.microsoft.com/powershell:alpine-3.14
RUN ["apk", "add", "--update", "clamav", "clamav-clamdscan", "clamav-daemon", "clamav-db", "clamav-doc", "clamav-libs", "clamav-libunrar", "clamav-milter", "clamav-scanner", "freshclam", "git"]
COPY clamd.conf /etc/clamav/
COPY freshclam.conf /etc/clamav/
RUN ["freshclam"]
COPY main.ps1 /
CMD ["pwsh", "-NonInteractive", "/main.ps1"]
