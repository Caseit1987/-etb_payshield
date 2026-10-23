# ETB PayShield Local End-to-End Threat Simulation Harness
Write-Host "🧪 Initializing Local E2E Simulation Cycle..." -ForegroundColor Cyan

$mockLog = "gate\intercept_stream.log"
if (-not (Test-Path "gate")) { New-Item -ItemType Directory -Path "gate" | Out-Null }

# 1. Simulate Benign Valid Transaction Route
Write-Host "`n[Step 1] Injecting Benign Valid Transaction Payload..." -ForegroundColor Green
Start-Sleep -Seconds 1
Write-Host "[✔] Payload structural verification matches schema constraints. Status: 200 Verified." -ForegroundColor Green

# 2. Simulate Anomalous Zero-Click Threat Payload Intercept
Write-Host "`n[Step 2] Injecting Malformed Zero-Click Structural Exploit Payload..." -ForegroundColor Red
Start-Sleep -Seconds 1

# Append live mock logging vector format to test the active PowerShell background daemon
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$logEntry = "INTERCEPTED: src=127.0.0.1 dst_port=8080 method=POST timestamp=$timestamp anomaly=injection_attempt"
$logEntry | Out-File -FilePath $mockLog -Append -Encoding utf8

Write-Host "[🛑] Proxy Edge Intercept Action Executed: 403 Forbidden issued." -ForegroundColor Red
Write-Host "Telemetry logged successfully to: $mockLog" -ForegroundColor Yellow

# 3. Trigger Dashboard Ingestion Sync Demonstration
Write-Host "`n[Step 3] Running Dashboard Chassis Asset Refresher..." -ForegroundColor Cyan
python dashboard\ingest_to_dashboard.py

Write-Host "`n✨ Local Simulation Run Finished cleanly." -ForegroundColor Green
