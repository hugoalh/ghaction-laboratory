FROM alpine:3.14
# RUN ["apk", "add", "--update", "clamav-libunrar", "clamav-scanner", "freshclam", "git"]
RUN ["apk", "add", "--update", "git"]
# RUN ["freshclam"]
COPY main.ps1 /
CMD ["/main.ps1"]
