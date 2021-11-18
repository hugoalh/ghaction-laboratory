$mode = ($env:INPUT_MODE).ToLower()
Write-Output -InputObject $mode
Get-ChildItem -Path .\ -Force -Recurse
Exit 0
# if (($mode -ne "fast") -and ($mode -ne "full")) {
# 	Write-Output -InputObject "::error title=Error::Invalid mode!"
# }
# function Execute-ClamScan {
# 	clamscan --official-db-only=yes --quiet --recursive .
# }
# Write-Output -InputObject "Scan current file system."
# Execute-ClamScan
# if ($mode -eq "full") {
# 
# }
