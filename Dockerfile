# FROM clamav/clamav:latest_base
# ENV CLAMAV_NO_CLAMD true
# ENV CLAMAV_NO_FRESHCLAMD true
# ENV CLAMAV_NO_MILTERD true
FROM powershell:latest
COPY main.ps1 /
CMD ["/main.ps1"]
