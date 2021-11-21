# $ClamDStartResult
# try {
# 	$ClamDStartResult = clamd
# } catch {
# 	Write-Output -InputObject "::error::Unable to execute ClamD[Start]!"
# 	Exit 1
# }
# if ($LASTEXITCODE -ne 0) {
# 	Write-Output -InputObject "::error::Unexpected ClamD[Start] result {$LASTEXITCODE}: $ClamDStartResult"
# 	Exit 1
# }
# foreach ($Line in $ClamDStartResult) {
# 	Write-Output -InputObject "::debug::$Line"
# }
$GitDepth = [bool]::Parse($env:INPUT_GITDEPTH)
$SetFail = $false
$TotalScanElements = 0
function Execute-Scan {
	param (
		[Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)][string]$Session
	)
	Write-Output -InputObject "::group::Scan $Session."
	$Elements = (Get-ChildItem -Force -Name -Path .\ -Recurse | Sort-Object)
	$ElementsLength = $Elements.Longlength
	Write-Output -InputObject "::debug::Elements List ($ElementsLength):"
	foreach ($Element in $Elements) {
		Write-Output -InputObject "::debug::$($Element)"
	}
	$script:TotalScanElements += $ElementsLength
	$ClamDScanResult
	try {
		$ClamDScanResult = $(clamdscan --fdpass --multiscan ./)
	} catch {
		Write-Output -InputObject "::error::Unable to execute ClamDScan ($Session)!"
		Write-Output -InputObject "::endgroup::"
		Exit 1
	}
	if (($LASTEXITCODE -eq 0) -and (($ClamDScanResult -join "; ") -notmatch "found")) {
		foreach ($Line in $ClamDScanResult) {
			Write-Output -InputObject "::debug::$Line"
		}
	} else {
		$script:SetFail = $true
		if (($LASTEXITCODE -eq 1) -or (($ClamDScanResult -join "; ") -match "found")) {
			Write-Output -InputObject "::error::Found virus in $Session from ClamAV:"
		} else {
			Write-Output -InputObject "::error::Unexpected ClamDScan result ($Session){$LASTEXITCODE}:"
		}
		foreach ($Line in $ClamDScanResult) {
			Write-Output -InputObject $Line
		}
	}
	Write-Output -InputObject "::endgroup::"
}
Execute-Scan -Session "current workspace"
if ($GitDepth -eq $true) {
	if ($(Test-Path -Path .\.git) -eq $true) {
		$GitCommitsRaw
		try {
			$GitCommitsRaw = $(git --no-pager log --all --format=%H --reflog --reverse)
		} catch {
			Write-Output -InputObject "::error::Unable to execute Git-Log!"
			Exit 1
		}
		if (($LASTEXITCODE -eq 0) -and ($GitCommitsRaw -notmatch "error") -and ($GitCommitsRaw -notmatch "fatal")) {
			$GitCommits
			if ($GitCommitsRaw -match "^[\da-f]{40}$") {
				$GitCommits = @($GitCommitsRaw)
			} else {
				$GitCommits = $GitCommitsRaw
			}
			$GitCommitsLength = $GitCommits.Longlength
			if ($GitCommitsLength -le 1) {
				Write-Output -InputObject "::warning::Current Git repository has only $GitCommitsLength commits! If this is incorrect, please define ``actions/checkout`` input ``fetch-depth`` to ``0`` and re-run. (IMPORTANT: ``Re-run all jobs`` or ``Re-run this workflow`` cannot apply the modified workflow!)"
			}
			for ($GitCommitsIndex = 0; $GitCommitsIndex -lt $GitCommitsLength; $GitCommitsIndex++) {
				$GitCommit = $GitCommits[$GitCommitsIndex]
				Write-Output -InputObject "Checkout commit #$($GitCommitsIndex + 1)/$($GitCommitsLength) ($GitCommit)."
				$GitCheckoutResult
				try {
					$GitCheckoutResult = $(git checkout "$GitCommit" --quiet)
				} catch {
					Write-Output -InputObject "::error::Unable to execute Git-Checkout (commit #$($GitCommitsIndex + 1)/$($GitCommitsLength) ($GitCommit))!"
					Exit 1
				}
				if ($LASTEXITCODE -eq 0) {
					Execute-Scan -Session "commit #$($GitCommitsIndex + 1)/$($GitCommitsLength) ($GitCommit)"
				} else {
					Write-Output -InputObject "::error::Unexpected Git-Checkout result (commit #$($GitCommitsIndex + 1)/$($GitCommitsLength) ($GitCommit)){$LASTEXITCODE}: $GitCheckoutResult"
				}
			}
		} else {
			Write-Output -InputObject "::error::Unexpected Git-Log result {$LASTEXITCODE}: $GitCommitsRaw"
		}
	} else {
		Write-Output -InputObject "::warning::Current workspace is not a Git repository!"
	}
}
Write-Output -InputObject "Total scan elements: $TotalScanElements"
if ($SetFail -eq $true) {
	Exit 1
}
Exit 0
