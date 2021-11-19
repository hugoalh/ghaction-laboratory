$GitDepth = [bool]::Parse($env:INPUT_GITDEPTH)
$SetError = $false
function Execute-Scan {
	param (
		[Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)][string]$Session
	)
	$Result = $(clamscan --official-db-only=yes --quiet --recursive .)
	if ($Result -notmatch "^\s*$") {
		$SetError = $true
		Write-Output -InputObject "::error::Found virus at $($Session): $Result"
	}
}
Write-Output -InputObject "Scan current workspace."
Execute-Scan -Session "current workspace"
if ($GitDepth -eq $true) {
	if ($(Test-Path -Path .\.git) -eq $false) {
		Write-Output -InputObject "::warning::Current workspace is not a Git repository!"
		Exit 0
	}
	$Commits = (git --no-pager log --format=%H) -split "\r?\n"
	if ($Commits -eq $null) {
		Write-Output -InputObject "::error::Current workspace is not a valid Git repository!"
		Exit 1
	}
	if ($Commits.Length -le 1) {
		Write-Output -InputObject "::warning::Current Git repository has only $($Commits.Length) commits! If this is incorrect, please modify ``actions/checkout`` with input ``fetch-depth`` to ``0``."
		Exit 0
	}
	for ($CommitIndex = 0; $CommitIndex -lt $Commits.Length; $CommitIndex++) {
		Write-Output -InputObject "Scan commit $($Commits[$CommitIndex]) ($CommitIndex/$($Commits.Length))."
		git checkout "$($Commits[$CommitIndex])"
		Execute-Scan -Session "commit $($Commits[$CommitIndex])"
	}
}
if ($SetError -eq $true) {
	Exit 1
}
