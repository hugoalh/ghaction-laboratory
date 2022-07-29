Import-Module -Name 'hugoalh.GitHubActionsToolkit' -Scope 'Local'
Write-GitHubActionsNotice -Message 'Success.'
$PSVersionTable
clamdscan --version
clamscan --version
freshclam --version
git --version
git-lfs --version
node --version
yara --version
clamconf --generate-config=clamav-milter.conf
clamconf --generate-config=clamd.conf
clamconf --generate-config=freshclam.conf
