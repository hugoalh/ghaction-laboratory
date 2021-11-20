$GitDepth = [bool]::Parse($env:INPUT_GITDEPTH)
$SetFail = $false
$TotalScanElements = 0
function Execute-Scan {
	param (
		[Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)][string]$SessionCapital,
		[Parameter(Mandatory = $true, Position = 1, ValueFromPipeline = $true)][string]$SessionLower,
		[Parameter()][switch]$SkipGitDatabase
	)
	Write-Output -InputObject "::group::Scan $SessionLower."
	$Elements = (Get-ChildItem -Force -Name -Path .\ -Recurse | Sort-Object)
	$ElementsLength = $Elements.Longlength
	$ElementsScanLength = 0
	$ElementsSkipLength = 0
	Write-Output -InputObject "::debug::Elements List ($ElementsLength):"
	foreach ($Element in $Elements) {
		if (($SkipGitDatabase -eq $true) -and (
			($Element -match "^.git$") -or
			($Element -match "^.git\\")
		)) {
			Write-Output -InputObject "::debug::[Skip] $Element"
			$ElementsSkipLength += 1
		} else {
			Write-Output -InputObject "::debug::[Scan] $Element"
			$ElementsScanLength += 1
		}
	}
	Write-Output -InputObject "::debug::Will scan elements: $ElementsScanLength/$ElementsLength"
	Write-Output -InputObject "::debug::Will skip elements: $ElementsSkipLength/$ElementsLength"
	$script:TotalScanElements += $ElementsScanLength
	$ClamScanResult
	if ($SkipGitDatabase -eq $true) {
		try {
			$ClamScanResult = $(clamscan --exclude=./.git --max-dir-recursion=4096 --max-files=40960 --max-filesize=4096M --max-recursion=4096 --max-scansize=4096M --official-db-only=yes --recursive ./)
		} catch {
			Write-Output -InputObject "::error::Unexpected execute error #cs-e1!"
			Exit 1
		}
	} else {
		try {
			$ClamScanResult = $(clamscan --max-dir-recursion=4096 --max-files=40960 --max-filesize=4096M --max-recursion=4096 --max-scansize=4096M --official-db-only=yes --recursive ./)
		} catch {
			Write-Output -InputObject "::error::Unexpected execute error #cs-e0!"
			Exit 1
		}
	}
	if (($LASTEXITCODE -eq 0) -and (($ClamScanResult -join "; ") -notmatch "found")) {
		foreach ($Line in $ClamScanResult) {
			Write-Output -InputObject "::debug::$Line"
		}
	} else {
		$script:SetFail = $true
		Write-Output -InputObject "::error::Found virus in $SessionLower from ClamScan!"
		foreach ($Line in $ClamScanResult) {
			Write-Output -InputObject $Line
		}
	}
	Write-Output -InputObject "::endgroup::"
}
Execute-Scan -SessionCapital "Current Workspace" -SessionLower "current workspace"
if ($GitDepth -eq $true) {
	if ($(Test-Path -Path .\.git) -eq $true) {
		$GitCommitsRaw
		try {
			$GitCommitsRaw = $(git --no-pager log --all --format=%H --reflog --reverse)
		} catch {
			Write-Output -InputObject "::error::Unexpected execute error #gl-e!"
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
					Write-Output -InputObject "::error::Unexpected execute error #gc-e (commit #$($GitCommitsIndex + 1)/$($GitCommitsLength) ($GitCommit))!"
					Exit 1
				}
				if ($LASTEXITCODE -eq 0) {
					Execute-Scan -SessionCapital "Commit $GitCommit" -SessionLower "commit $GitCommit" -SkipGitDatabase
				} else {
					Write-Output -InputObject "::error::Unexpected execute result #gc-r (commit #$($GitCommitsIndex + 1)/$($GitCommitsLength) ($GitCommit)): $GitCheckoutResult!"
				}
			}
		} else {
			Write-Output -InputObject "::error::Unexpected execute result #gl-r: $GitCommitsRaw!"
		}
	} else {
		Write-Output -InputObject "::warning::Current workspace is not a Git repository!"
	}
}
Write-Output -InputObject "Total scan elements: $TotalScanElements"
if ($SetFail -eq $true) {
	Exit 1
}
