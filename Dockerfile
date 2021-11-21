FROM mcr.microsoft.com/powershell:alpine-3.14
RUN ["apk", "add", "--update", "clamav", "clamav-clamdscan", "clamav-daemon", "clamav-db", "clamav-doc", "clamav-libs", "clamav-libunrar", "clamav-milter", "clamav-scanner", "freshclam", "git"]
RUN ["clamconf"]
RUN ["clamconf", "--generate-config", "freshclam.conf", ">", "freshclam.conf"]
RUN ["clamconf", "--generate-config", "clamd.conf", ">", "clamd.conf"]
RUN ["clamconf", "--generate-config", "clamav-milter.conf", ">", "clamav-milter.conf"]
RUN ["freshclam"]
COPY main.ps1 /
CMD ["pwsh", "-NonInteractive", "/main.ps1"]
