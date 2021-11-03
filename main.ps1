param (
	[Parameter()][string]$arbitrary,
	[Parameter()][string]$dryRun,
	[Parameter(Mandatory = $true, Position = 0)][ValidatePattern("^[\da-zA-Z_-]+$")][string]$eventName,
	[Parameter(Mandatory = $true, Position = 1)][ValidatePattern("^[\da-zA-Z_-]+$")][string]$key,
	[Parameter(Mandatory = $true, Position = 2, ValueFromPipeline = $true)][ValidateNotNullOrEmpty()][string]$payload
)
$arbitraryBoolean = [bool]::Parse($arbitrary)
$dryRunBoolean = [bool]::Parse($dryRun)
$payloadStringify = (ConvertFrom-Json -InputObject $payload | ConvertTo-Json -Depth 100 -Compress)
$ghactionUserAgent = "TriggerIFTTTWebhookApplet.GitHubAction/4.0.0"
if ($dryrun -eq $true) {
	Write-Output -InputObject "Event Name: $eventName"
	Write-Output -InputObject "Payload Content: $payloadStringify"
	Write-Output -InputObject "Payload Length: $($payloadStringify.Length)"
	$payloadFakeStringify = (ConvertFrom-Json -InputObject '{"body": "bar", "title": "foo", "userId": 1}' | ConvertTo-Json -Depth 100 -Compress)
	Write-Output -InputObject "Post network request to test service."
	Invoke-WebRequest -UseBasicParsing -Uri "https://jsonplaceholder.typicode.com/posts" -UserAgent $ghactionUserAgent -Headers @{ "Content-Type" = "application/json"; "Content-Length" = $($payloadFakeStringify.Length) } -MaximumRedirection 5 -Method Post -Body $payloadFakeStringify -ContentType "application/json"
} else {
	Write-Output -InputObject "::debug::Event Name: $eventName"
	Write-Output -InputObject "::debug::Payload Content: $payloadStringify"
	Write-Output -InputObject "::debug::Payload Length: $($payloadStringify.Length)"
	Write-Output -InputObject "Post network request to IFTTT."
	$webRequestURL = "https://maker.ifttt.com/trigger/$eventname"
	if ($arbitrary -eq $true) {
		$webRequestURL += "/json"
	}
	$webRequestURL += "/with/key/$key"
	Invoke-WebRequest -UseBasicParsing -Uri $webRequestURL -UserAgent $ghactionUserAgent -Headers @{ "Content-Type" = "application/json"; "Content-Length" = $($payloadStringify.Length) } -MaximumRedirection 5 -Method Post -Body $payloadStringify -ContentType "application/json"
}
