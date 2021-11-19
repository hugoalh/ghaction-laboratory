$GitDepth = [bool]::Parse($env:INPUT_GITDEPTH)
[uint64]$ElementsCount = 0
$SetError = $false
function Execute-Scan {
	param (
		[Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)][string]$Session,
		[Parameter(Mandatory = $true, Position = 1, ValueFromPipeline = $true)][switch]$SkipGitDatabase
	)
	$ElementsCount += $(Get-ChildItem -Force -Name -Path .\ -Recurse).Length
	$Result
	if ($SkipGitDatabase -eq $true) {
		$ElementsCount -= $($(Get-ChildItem -Force -Name -Path .\.git -Recurse).Length - 1)
		$Result = $(clamscan --exclude=./.git --official-db-only=yes --quiet --recursive .)
	} else {
		$Result = $(clamscan --official-db-only=yes --quiet --recursive .)
	}
	if ($Result -notmatch "^\s*$") {
		$SetError = $true
		Write-Output -InputObject "::error::Found virus at $($Session): $Result"
	}
}
Write-Output -InputObject "Scan current workspace."
Execute-Scan -Session "current workspace"
if ($GitDepth -eq $true) {
	if ($(Test-Path -Path .\.git) -eq $true) {
		$Commits = (git --no-pager log --format=%H) -split "\r?\n"
		if ($Commits -ne $null) {
			if ($Commits.Length -gt 1) {
				for ($CommitIndex = 0; $CommitIndex -lt $Commits.Length; $CommitIndex++) {
					Write-Output -InputObject "Scan commit $($Commits[$CommitIndex]) ($($CommitIndex + 1)/$($Commits.Length))."
					git checkout --quiet "$($Commits[$CommitIndex])"
					Execute-Scan -Session "commit $($Commits[$CommitIndex])" -SkipGitDatabase
				}
			} else {
				Write-Output -InputObject "::warning::Current Git repository has only $($Commits.Length) commits! If this is incorrect, please modify ``actions/checkout`` with input ``fetch-depth`` to ``0``."
				Exit 0
			}
		} else {
			$SetError = $true
			Write-Output -InputObject "::error::Current workspace is not a valid Git repository!"
		}
	} else {
		Write-Output -InputObject "::warning::Current workspace is not a Git repository!"
	}
}
Write-Output -InputObject "Scanned elements: $ElementsCount"
if ($SetError -eq $true) {
	Exit 1
}
