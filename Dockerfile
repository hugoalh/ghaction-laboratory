FROM clamav/clamav:latest_base
COPY main.ps1 /
CMD ["/usr/bin/pwsh", "-c", "/main.ps1"]
