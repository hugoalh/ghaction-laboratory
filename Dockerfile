FROM mcr.microsoft.com/powershell:alpine-3.14
# RUN ["apk", "add", "clamav", "clamav-clamdscan", "clamav-daemon", "clamav-db", "clamav-doc", "clamav-libs", "clamav-libunrar", "clamav-milter", "clamav-scanner", "freshclam", "git"]
RUN ["apk", "add", "clamav:x86_64", "clamav-clamdscan:x86_64", "clamav-daemon:x86_64", "clamav-db:x86_64", "clamav-doc:x86_64", "clamav-libs:x86_64", "clamav-libunrar:x86_64", "clamav-milter:x86_64", "clamav-scanner:x86_64", "freshclam:x86_64", "git:x86_64"]
RUN ["apk", "update"]
RUN ["apk", "upgrade"]
COPY clamd-minify.conf /etc/clamav/clamd.conf
COPY freshclam-minify.conf /etc/clamav/freshclam.conf
COPY main.ps1 /
CMD ["pwsh", "-NonInteractive", "/main.ps1"]
