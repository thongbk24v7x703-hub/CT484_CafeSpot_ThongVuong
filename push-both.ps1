$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot
Remove-Item Env:GIT_SSH_COMMAND -ErrorAction SilentlyContinue
Remove-Item Env:GIT_SSH -ErrorAction SilentlyContinue
git config core.sshCommand "$PSScriptRoot\ssh-wrapper.cmd"
Write-Host "Push thong (github-thong)..."
git push -u thong main
Write-Host "Push vuong (github-vuong)..."
git push -u vuong main
Write-Host "OK"
git log --pretty=format:"%h | %an | %s" --reverse
