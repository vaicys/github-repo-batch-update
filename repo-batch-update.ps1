# Requires scope: repo Full control of private repositories
$pat = "PERSONAL_ACCESS_TOKEN"
$org = "ORGANIZATION"
$searchPattern = "SEARCH_STRING"
$protectedBranches = "master", "develop", "release"

$headers = @{
    Authorization = "token $pat"
    Accept = "application/vnd.github.v3+json"
}

# Find all the relevant repositories
$resp = Invoke-RestMethod `
    -Headers $headers `
    -Uri "https://api.github.com/search/repositories?q=$searchPattern+org:$org+archived:false"
$repos = $resp.items | Where-Object { $_.name -Match "^$searchPattern" } | ForEach-Object { $_.url }

# Confirm
Write-Host "The following repositories will be updated:"
$repos | ForEach-Object { Write-Host $_ }
$answer = Read-Host -Prompt "Proceed? (y/n)"
if ($answer -ne "y") { Exit }

# Update repository settings and branch protection
foreach ($url in $repos) {
    try
    {
        Write-Host -NoNewline "Updating ""$url""... "
        $resp = Invoke-RestMethod `
            -Headers $headers `
            -Method Patch `
            -Uri $url `
             -ContentType "application/json" `
            -Body (Get-Content .\repository-settings.json)
        Write-Host "done."

        foreach ($branch in $protectedBranches) {
            Write-Host -NoNewline "    updating branch ""$branch"" protection... "
            try {
                $resp = Invoke-RestMethod `
                    -Headers $headers `
                    -ContentType "application/json" `
                    -Method Put `
                    -Uri "$url/branches/$branch/protection" `
                    -Body (Get-Content .\branch-protection.json)
                Write-Host "done."
            }
            catch {
                if ($_.Exception.Response.StatusCode -eq "NotFound") {
                    Write-Host "not found."
                    continue
                }
                throw
            }
        }
    }
    catch
    {
        Write-Host ""
        Write-Host "ERROR: $_"
        Exit
    }
}
