# pull.ps1
# Run this before starting a session to get any changes Supercomputer pushed.
#
# Token is NOT hardcoded. Provide it one of two ways:
#   1. Set an env var:   $env:HF_TOKEN = "your-token"
#   2. Or create token.txt next to this script (it is gitignored)

function Get-HFToken {
  if ($env:HF_TOKEN) { return $env:HF_TOKEN }
  $tokenFile = Join-Path $PSScriptRoot "token.txt"
  if (Test-Path $tokenFile) { return (Get-Content $tokenFile -Raw).Trim() }
  Write-Host "ERROR: No Higgsfield token found." -ForegroundColor Red
  Write-Host "  Set `$env:HF_TOKEN = 'your-token'  -or-  create token.txt next to this script." -ForegroundColor Red
  exit 1
}
$TOKEN = Get-HFToken

Set-Location $PSScriptRoot

Write-Host "==> Pulling latest from Higgsfield..." -ForegroundColor Cyan
git -c "http.extraHeader=Authorization: token $TOKEN" pull origin main

Write-Host "OK Up to date." -ForegroundColor Green
