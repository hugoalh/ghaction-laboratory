FROM mcr.microsoft.com/powershell:alpine-3.14
RUN ["apk", "add", "--update", "clamav", "clamav-libunrar", "clamav-scanner", "freshclam", "git"]
RUN ["freshclam"]
COPY main.ps1 /
CMD ["pwsh", "-NonInteractive", "/main.ps1"]
