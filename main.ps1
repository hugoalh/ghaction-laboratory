$GitDepth = [bool]::Parse($env:INPUT_GITDEPTH)
$ElementsTotalCount = 0
$SetFail = $false
function Execute-Scan {
	param (
		[Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)][string]$Message,
		[Parameter()][switch]$SkipGitDatabase
	)
	Write-Output -InputObject "::group::Scan $Message."
	$Elements = $(Get-ChildItem -Force -Name -Path .\ -Recurse | Sort-Object)
	Write-Output -InputObject "::debug::Directory elements ($($Elements.Longlength)):"
	foreach ($Element in $Elements) {
		Write-Output -InputObject "::debug::- $Element"
	}
	$ElementsTotalCount += $Elements.Longlength
	$Result
	if ($SkipGitDatabase -eq $true) {
		$ElementsTotalCount -= $($(Get-ChildItem -Force -Name -Path .\.git -Recurse).Longlength + 1)
		$Result = $(clamscan --exclude=./.git --official-db-only=yes --recursive ./)
	} else {
		$Result = $(clamscan --official-db-only=yes --recursive ./)
	}
	if ($Result -match "found") {
		$SetFail = $true
		Write-Output -InputObject "::error::Found virus!"
	}
	Write-Output -InputObject @"
::debug::$Result
"@
	Write-Output -InputObject "::endgroup::"
}
Execute-Scan -Message "current workspace"
if ($GitDepth -eq $true) {
	$CommitsRaw = $(git --no-pager log --format=%H)
	if (($(Test-Path -Path .\.git) -eq $true) -and ($CommitsRaw -notmatch "fatal") -and ($CommitsRaw -notmatch "error")) {
		$Commits
		if ($CommitsRaw -match "^[\da-f]{40}$") {
			$Commits = @($CommitsRaw)
		} else {
			$Commits = $CommitsRaw
		}
		$CommitsLength = $Commits.Longlength
		if ($CommitsLength -le 1) {
			Write-Output -InputObject "::warning::Current Git repository has only $CommitsLength commits! If this is incorrect, please define ``actions/checkout`` input ``fetch-depth`` to ``0`` and re-run. (IMPORTANT: ``Re-run all jobs`` or ``Re-run this workflow`` cannot apply the modified workflow!)"
		}
		for ($CommitsIndex = 0; $CommitsIndex -lt $CommitsLength; $CommitsIndex++) {
			$Commit = $Commits[$CommitsIndex]
			Write-Output -InputObject "Checkout commit #$($CommitsIndex + 1)/$($CommitsLength): $Commit."
			$Checkout = $(git checkout "$Commit" --quiet)
			if ($Checkout -eq $null) {
				Execute-Scan -Message "commit $Commit" -SkipGitDatabase
			} else {
				$SetFail = $true
				Write-Output -InputObject @"
::error::Commit #$($CommitsIndex + 1)/$($CommitsLength) ($Commit) is not accessible or exist!
$Checkout
"@
			}
		}
	} else {
		Write-Output -InputObject "::warning::Current workspace is not a Git repository!"
	}
}
Write-Output -InputObject "Scanned elements total: $ElementsTotalCount"
if ($SetFail -eq $true) {
	Exit 1
}
