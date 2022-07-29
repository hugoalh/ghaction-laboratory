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
Enter-GitHubActionsLogGroup -Title "clamav-milter.conf"
clamconf --generate-config=clamav-milter.conf
Exit-GitHubActionsLogGroup
Enter-GitHubActionsLogGroup -Title "clamd.conf"
clamconf --generate-config=clamd.conf
Exit-GitHubActionsLogGroup
Enter-GitHubActionsLogGroup -Title "freshclam.conf"
clamconf --generate-config=freshclam.conf
Exit-GitHubActionsLogGroup
