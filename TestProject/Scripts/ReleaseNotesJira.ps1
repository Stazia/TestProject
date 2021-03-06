Param(
[string] $githubToken,
[string] $githubApiUri,
[string] $jiraUser,
[string] $jiraPassword,
[string] $jiraUri,
[string] $slackHookUri,
[string] $releaseName
)

$tagsUri = "$githubApiUri/tags"
$lastVersions = @()
$githubTags = Invoke-RestMethod -Method Get -Uri $tagsUri -Header @{Authorization = "token $githubToken"}
$githubTags | Where {$_.name -CLike "$releaseName-v*"} | Select-Object -first 2 | ForEach {$lastVersions = $lastVersions+$_.name}
$latestVersion = $lastVersions[0]
$previousVersion = $lastVersions[1]

$notes = "Ny versjon av Stadnamn ($latestVersion) er ute i produksjon! `n Dette er fikset siden sist (Jira):"

git log "$previousVersion..$latestVersion" --extended-regexp --pretty=oneline --no-merges | Select-String -Pattern "STAD-[0-9]+" | ForEach {$_.Matches.Value.Trim("#")} | Select-Object -unique | ForEach {

$jiraApiUri = "$jiraUri/rest/api/latest/issue/$_"
$jiraAuthPair = "${jiraUser}:${jiraPassword}"
$encodedCreds = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($jiraAuthPair))
$headers = @{ Authorization = "Basic $encodedCreds" }
$jiraIssue = Invoke-RestMethod -Method Get -Uri $jiraApiUri -Header $headers
$jiraSummary = $jiraIssue.fields.summary
$line = "* [$_]($jiraUri/browse/$_) $jiraSummary"

$notes = "$notes `n $line"}
Write-Host $notes

$slackMessage = @{ "text" = $notes } | ConvertTo-Json -Compress
Invoke-WebRequest -UseBasicParsing -Body $slackMessage -Method POST -Uri $slackHookUri

$messages = '-m " "'
$notes | Foreach-Object { $m = ' -m ' + '"' + $_ + '"' ; $messages = $messages + $m }

git tag $latestVersion -f $messages
git push --tags -f
