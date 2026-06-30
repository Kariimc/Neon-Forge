# watch.ps1
# Watches app\src for changes and auto-deploys after a 3s debounce.
# Run this in a separate terminal while you work. Stop with Ctrl+C.
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

$WatchPath = Join-Path $PSScriptRoot "app\src"
$DebounceSeconds = 3
$LastDeploy = [DateTime]::MinValue

Write-Host "Watching $WatchPath for changes..." -ForegroundColor Cyan
Write-Host "Press Ctrl+C to stop.`n" -ForegroundColor DarkGray

$watcher = New-Object System.IO.FileSystemWatcher
$watcher.Path = $WatchPath
$watcher.IncludeSubdirectories = $true
$watcher.Filter = "*.*"
$watcher.NotifyFilter = [System.IO.NotifyFilters]::LastWrite -bor [System.IO.NotifyFilters]::FileName
$watcher.EnableRaisingEvents = $true

$action = {
  $path = $Event.SourceEventArgs.FullPath
  $now = [DateTime]::Now
  $elapsed = ($now - $script:LastDeploy).TotalSeconds

  if ($elapsed -lt $script:DebounceSeconds) { return }
  $script:LastDeploy = $now

  Write-Host "[$(Get-Date -Format 'HH:mm:ss')] Changed: $($path | Split-Path -Leaf) - deploying..." -ForegroundColor Yellow

  Set-Location $PSScriptRoot
  git add -A
  $status = git status --porcelain
  if ($status) {
    $msg = "chore: auto-sync $(Get-Date -Format 'HH:mm:ss')"
    git commit -m $msg | Out-Null
    git -c "http.extraHeader=Authorization: token $TOKEN" push origin main | Out-Null
    Write-Host "  OK Pushed - live in ~30s" -ForegroundColor Green
  }
}

Register-ObjectEvent $watcher "Changed" -Action $action | Out-Null
Register-ObjectEvent $watcher "Created" -Action $action | Out-Null
Register-ObjectEvent $watcher "Renamed" -Action $action | Out-Null

# Keep alive
try { while ($true) { Start-Sleep -Seconds 1 } }
finally { $watcher.EnableRaisingEvents = $false; $watcher.Dispose() }
