FROM clamav/clamav:latest_base
COPY main.ps1 /
CMD ["/main.ps1"]
