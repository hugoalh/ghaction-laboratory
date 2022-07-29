Import-Module -Name 'hugoalh.GitHubActionsToolkit' -Scope 'Local'
Write-GitHubActionsNotice -Message 'Success.'
$PSVersionTable
clamdscan --version
clamscan --version
freshclam --version
git --version
node --version
clamconf --generate-config=freshclam.conf
clamconf --generate-config=clamd.conf
clamconf --generate-config=clamav-milter.conf
