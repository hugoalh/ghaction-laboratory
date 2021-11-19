$GitDepth = [bool]::Parse($env:INPUT_GITDEPTH)
Write-Output -InputObject "::debug::Git Depth: $GitDepth"
$Commits = (git --no-pager log --format=%H) -split "\r?\n"
Write-Output -InputObject $($Commits.Length)
Write-Output -InputObject $Commits
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
