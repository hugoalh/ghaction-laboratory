$GitDepth = [bool]::Parse($env:INPUT_GITDEPTH)
$ElementsTotalCount = 0
$SetError = $false
function Execute-Scan {
	param (
		[Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)][string]$Message,
		[Parameter()][switch]$SkipGitDatabase
	)
	Write-Output -InputObject "::group::Scan $Message."
	$Elements = $(Get-ChildItem -Force -Name -Path .\ -Recurse)
	Write-Output -InputObject "::debug::Directory elements ($($Elements.Length)):"
	foreach ($Element in $Elements) {
		Write-Output -InputObject "::debug::- $Element"
	}
	$ElementsTotalCount += $Elements.Length
	$Result
	if ($SkipGitDatabase -eq $true) {
		$ElementsTotalCount -= $($(Get-ChildItem -Force -Name -Path .\.git -Recurse).Length + 1)
		$Result = $(clamscan --exclude=./.git --official-db-only=yes --recursive ./)
	} else {
		$Result = $(clamscan --official-db-only=yes --recursive ./)
	}
	if ($Result -match "found") {
		$SetError = $true
		Write-Output -InputObject "::error::Found virus!"
	}
	Write-Output -InputObject "::debug::$Result"
	Write-Output -InputObject "::endgroup::"
}
Execute-Scan -Message "current workspace"
if ($GitDepth -eq $true) {
	if ($(Test-Path -Path .\.git) -eq $true) {
		$Commits = $($(git --no-pager log --format=%H) -split "\r?\n")
		if ($Commits -ne $null) {
			if ($Commits.Length -le 1) {
				Write-Output -InputObject "::warning::Current Git repository has only $($Commits.Length) commits! If this is incorrect, please define ``actions/checkout`` input ``fetch-depth`` to ``0`` and re-run. (IMPORTANT: Press the ``Re-run all jobs`` or ``Re-run this workflow`` button cannot apply the modified workflow!)"
			}
			for ($CommitIndex = 0; $CommitIndex -lt $Commits.Length; $CommitIndex++) {
				Write-Output -InputObject "Checkout commit #$($CommitIndex + 1)/$($Commits.Length): $($Commits[$CommitIndex])."
				git checkout "$($Commits[$CommitIndex])"
				Execute-Scan -Message "commit $($Commits[$CommitIndex])" -SkipGitDatabase
			}
		} else {
			$SetError = $true
			Write-Output -InputObject "::error::Current workspace is not a valid Git repository!"
		}
	} else {
		Write-Output -InputObject "::warning::Current workspace is not a Git repository!"
	}
}
Write-Output -InputObject "Scanned elements total: $ElementsTotalCount"
if ($SetError -eq $true) {
	Exit 1
}
