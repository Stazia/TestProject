Param(
[string] $githubToken,
[string] $gApiUrl,
[string] $jiraUser,
[string] $jiraPassord,
[string] $jiraUrl
[string] $sHookUri
)

$tagsUri = "$gApiUrl/tags"
$lastVersions = @()
$gTags = Invoke-RestMethod -Method Get -Uri $tagsUri -Header @{Authorization = "token $githubToken"}
$gTags | Select-Object -first 2 | ForEach {$lastVersions = $lastVersions+$_.name}
$latestVersion = $lastVersions[0]
$previousVersion = $lastVersions[1]

$notes = "Ny versjon av Stadnamn ($latestVersion) er ute i produksjon! `n Dette er fikset siden sist (Jira):"

git log "$previousVersion..$latestVersion" --extended-regexp --pretty=oneline --no-merges | Select-String -Pattern "STAD-[0-9]+" | ForEach {$_.Matches.Value.Trim("#")} | Select-Object -unique | ForEach {

$jiraUrl = "$jiraUrl/rest/api/latest/issue/$_"
$pair = "$($jiraUser):$($jiraPassord)"
$encodedCreds = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($pair))
$headers = @{ Authorization = "Basic $encodedCreds" }
$jiraIssue = Invoke-RestMethod -Method Get -Uri $jiraUrl -Header $headers
$jiraSummary = $jiraIssue.fields.summary
$line = "* [$_]($jiraUrl/browse/$_) $jiraSummary"

$notes = "$notes `n $line"}
Write-Host $notes

$slackMessage = @{ "text" = $notes } | ConvertTo-Json -Compress
Invoke-WebRequest -UseBasicParsing -Body $slackMessage -Method POST -Uri $sHookUri