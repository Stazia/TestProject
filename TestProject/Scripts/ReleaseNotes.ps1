Param(
[string] $token,
[string] $gApiUrl,
[string] $gProjectUrl
)
$f = "Release notes:"
git log "test-v1335..test-v1389" --extended-regexp --pretty=oneline --no-merges | Select-String -Pattern "#[0-9]+" | ForEach {$_.Matches.Value.Trim("#")} | Select-Object -unique | ForEach {
$gU="$gApiUrl/issues/$_"
$i=Invoke-RestMethod -Method Get -Uri $gU -Header @{Authorization = "token $token"}
$t=$i.title
$l="* #[$_]($gProjectUrl/issues/$_) $t" 
$f="$f `n $l"}
Write-Host $f