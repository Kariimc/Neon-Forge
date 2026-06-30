# deploy.ps1
# Usage: .\deploy.ps1 "optional commit message"
# Commits everything and pushes to Higgsfield -> auto-deploys in ~30s.
#
# Token is NOT hardcoded. Provide it one of two ways:
#   1. Set an env var:   $env:HF_TOKEN = "your-token"
#   2. Or create token.txt next to this script (it is gitignored)

param(
  [string]$Message = "chore: local update $(Get-Date -Format 'yyyy-MM-dd HH:mm')"
)

$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot

function Get-HFToken {
  if ($env:HF_TOKEN) { return $env:HF_TOKEN }
  $tokenFile = Join-Path $PSScriptRoot "token.txt"
  if (Test-Path $tokenFile) { return (Get-Content $tokenFile -Raw).Trim() }
  Write-Host "ERROR: No Higgsfield token found." -ForegroundColor Red
  Write-Host "  Set `$env:HF_TOKEN = 'your-token'  -or-  create token.txt next to this script." -ForegroundColor Red
  exit 1
}
$TOKEN = Get-HFToken

Write-Host "==> Staging all changes..." -ForegroundColor Cyan
git add -A

$status = git status --porcelain
if ($status) {
  Write-Host "==> Committing: $Message" -ForegroundColor Cyan
  git commit -m $Message
} else {
  Write-Host "==> Nothing to commit, pushing anyway..." -ForegroundColor Yellow
}

Write-Host "==> Pushing to Higgsfield..." -ForegroundColor Cyan
git -c "http.extraHeader=Authorization: token $TOKEN" push origin main

Write-Host ""
Write-Host "OK Done! Deploying now (takes ~30s):" -ForegroundColor Green
Write-Host "  Production: https://hidden-glow-736.higgsfield.app" -ForegroundColor White
Write-Host "  Preview:    https://preview--hidden-glow-736.higgsfield.app" -ForegroundColor White
