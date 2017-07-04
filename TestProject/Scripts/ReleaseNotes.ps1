Param(
[string] $gToken,
[string] $gApiUrl,
[string] $gProjectUrl,
[string] $sHookUri
)
$notes = "Release notes for build $env:BUILD_BUILDNUMBER $env:BUILD_BUILDURI :"

$tagsUri = "$gApiUrl/tags"
$lastVersions = @()
$gTags = Invoke-RestMethod -Method Get -Uri $tagsUri -Header @{Authorization = "token $gToken"}
$gTags | Select-Object -first 2 | ForEach {$lastVersions = $lastVersions+$_.name}
$latestVersion = $lastVersions[0]
$previousVersion = $lastVersions[1]

git log "$previousVersion..$latestVersion" --extended-regexp --pretty=oneline --no-merges | Select-String -Pattern "#[0-9]+" | ForEach {$_.Matches.Value.Trim("#")} | Select-Object -unique | ForEach {
$gUrl = "$gApiUrl/issues/$_"
$item = Invoke-RestMethod -Method Get -Uri $gUrl -Header @{Authorization = "token $gToken"}
$title = $item.title
$line = "* #[$_]($gProjectUrl/issues/$_) $title" 
$notes = "$notes `n $line"}
Write-Host $notes

$slackMessage = @{ "text" = $notes } | ConvertTo-Json -Compress
Invoke-WebRequest -UseBasicParsing -Body $slackMessage -Method POST -Uri $sHookUri



