param (
	[Parameter()][string]$arbitrary,
	[Parameter()][string]$dryRun,
	[Parameter(Mandatory = $true, Position = 0)][ValidatePattern("^[\da-zA-Z_-]+$")][string]$eventName,
	[Parameter(Mandatory = $true, Position = 1)][ValidatePattern("^[\da-zA-Z_-]+$")][string]$key,
	[Parameter(Mandatory = $true, Position = 2, ValueFromPipeline = $true)][ValidateNotNullOrEmpty()][string]$payload
)
$arbitraryBoolean = [bool]::Parse($arbitrary)
$dryRunBoolean = [bool]::Parse($dryRun)
$payloadStringify = (ConvertFrom-Json -InputObject $payload -Depth 100 | ConvertTo-Json -Depth 100 -Compress)
$ghactionUserAgent = "TriggerIFTTTWebhookApplet.GitHubAction/4.0.0"
if ($dryrun -eq $true) {
	Write-Output -InputObject "Post network request to test service."
	Write-Output -InputObject "Event Name: $eventName"
	Write-Output -InputObject "Payload Content: $payloadStringify"
	$payloadFakeStringify = (ConvertFrom-Json -InputObject '{"body": "bar", "title": "foo", "userId": 1}' -Depth 100 | ConvertTo-Json -Depth 100 -Compress)
	Write-Output -InputObject "Post network request to test service."
	$response = Invoke-WebRequest -UseBasicParsing -Uri "https://jsonplaceholder.typicode.com/posts" -UserAgent $ghactionUserAgent -MaximumRedirection 5 -Method Post -Body $payloadFakeStringify -ContentType "application/json"
	foreach ($element in $response) {
		Write-Output -InputObject "$($element.Name): $($element.Value)"
	}
} else {
	Write-Output -InputObject "Post network request to IFTTT."
	Write-Output -InputObject "::debug::Event Name: $eventName"
	Write-Output -InputObject "::debug::Payload Content: $payloadStringify"
	Write-Output -InputObject "Post network request to IFTTT."
	$webRequestURL = "https://maker.ifttt.com/trigger/$eventname"
	if ($arbitrary -eq $true) {
		$webRequestURL += "/json"
	}
	$webRequestURL += "/with/key/$key"
	$response = Invoke-WebRequest -UseBasicParsing -Uri $webRequestURL -UserAgent $ghactionUserAgent -MaximumRedirection 5 -Method Post -Body $payloadStringify -ContentType "application/json"
	foreach ($element in $response) {
		Write-Output -InputObject "::debug::$($element.Name): $($element.Value)"
	}
}
