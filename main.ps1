$Mode = ($env:INPUT_MODE).ToLower()
Write-Output -InputObject $Mode
$CommitsRaw = $(git --no-pager log --format=%H)
$Commits = $CommitsRaw.Split("\r?\n")
Write-Output -InputObject $($Commits.Length)
Exit 0
# if (($Mode -ne "fast") -and ($Mode -ne "full")) {
# 	Write-Output -InputObject "::error title=Error::Invalid mode!"
# }
# function Execute-ClamScan {
# 	clamscan --official-db-only=yes --quiet --recursive .
# }
# Write-Output -InputObject "Scan current file system."
# Execute-ClamScan
# if ($Mode -eq "full") {
# 
# }