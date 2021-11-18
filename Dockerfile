FROM alpine:3.14
RUN ["apk", "add", "--update", "clamav-libunrar", "clamav-scanner", "freshclam", "git"]
RUN ["freshclam"]
FROM mcr.microsoft.com/powershell:latest
COPY main.ps1 /
CMD ["/usr/bin/pwsh", "-c", "/main.ps1"]
