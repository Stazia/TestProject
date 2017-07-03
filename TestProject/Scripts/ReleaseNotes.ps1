Param(
[string] $gToken,
[string] $gApiUrl,
[string] $gProjectUrl,
[string] $hookUri
)
$f = "Release notes for build $(Build.BuildNumber) $(Build.BuildURI):"

$tagsUri = $gApiUrl/tags
$gTags = Invoke-RestMethod -Method Get -Uri $tagsUri -Header @{Authorization = "token $gToken"}
Write-Host $gTags 

git log "test-v1335..test-v1389" --extended-regexp --pretty=oneline --no-merges | Select-String -Pattern "#[0-9]+" | ForEach {$_.Matches.Value.Trim("#")} | Select-Object -unique | ForEach {
$gU="$gApiUrl/issues/$_"
$i=Invoke-RestMethod -Method Get -Uri $gU -Header @{Authorization = "token $gToken"}
$t=$i.title
$l="* #[$_]($gProjectUrl/issues/$_) $t" 
$f="$f `n $l"}
Write-Host $f

$payload = @{ "text" = $f } | ConvertTo-Json -Compress
Invoke-WebRequest -UseBasicParsing -Body $payload -Method POST -Uri $hookUri



