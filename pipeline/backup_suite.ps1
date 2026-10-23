# ETB PayShield Local Workspace Archival Backup Utility
$sourceDir = Get-Location
$backupDir = Join-Path $sourceDir "vault_backups"
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$archiveFile = Join-Path $backupDir "etb_payshield_vault_$timestamp.zip"

Write-Host "🗄️ Initializing high-assurance configuration folder archive backup..." -ForegroundColor Cyan

if (-not (Test-Path $backupDir)) { New-Item -ItemType Directory -Path $backupDir -Force | Out-Null }

# Cleanly compress project source files while excluding raw git historical repositories
Get-ChildItem -Path $sourceDir -Exclude "vault_backups", ".git" | ForEach-Object {
    Compress-Archive -Path $_.FullName -Update -DestinationPath $archiveFile -ErrorAction SilentlyContinue
}

if (Test-Path $archiveFile) {
    Write-Host "[✔] Local configuration folder archived successfully!" -ForegroundColor Green
    Write-Host "Backup Path: $archiveFile" -ForegroundColor Yellow
} else {
    Write-Host "[❌] Archival script failed to generate compressed target footprint." -ForegroundColor Red
}
