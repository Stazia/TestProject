Param(
[string] $githubToken,
[string] $githubApiUrl,
[string] $gProjectUrl,
[string] $sHookUri
)

$tagsUri = "$githubApiUrl/tags"
$lastVersions = @()
$gTags = Invoke-RestMethod -Method Get -Uri $tagsUri -Header @{Authorization = "token $githubToken"}
$gTags | Select-Object -first 2 | ForEach {$lastVersions = $lastVersions+$_.name}
$latestVersion = $lastVersions[0]
$previousVersion = $lastVersions[1]

$notes = "Ny versjon av Stadnamn ($latestVersion) er ute i produksjon! `n Dette er fikset siden sist:"

git log "$previousVersion..$latestVersion" --extended-regexp --pretty=oneline --no-merges | Select-String -Pattern "#[0-9]+" | ForEach {$_.Matches.Value.Trim("#")} | Select-Object -unique | ForEach {
$gUrl = "$githubApiUrl/issues/$_"
$item = Invoke-RestMethod -Method Get -Uri $gUrl -Header @{Authorization = "token $githubToken"}
$title = $item.title
$line = "* Issue $_ ($gProjectUrl/issues/$_) $title" 
$notes = "$notes `n $line"}
Write-Host $notes

$slackMessage = @{ "text" = $notes } | ConvertTo-Json -Compress
Invoke-WebRequest -UseBasicParsing -Body $slackMessage -Method POST -Uri $sHookUri