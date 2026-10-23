# ETB PayShield Master Automation Pipeline & Test Runner (Refined v1.1)
Clear-Host
Write-Host "====================================================" -ForegroundColor Cyan
Write-Host "[*] Initializing Automated ETB PayShield Testing Loop..." -ForegroundColor Cyan
Write-Host "====================================================" -ForegroundColor Cyan

# 1. Enforce local environment state routing variables
$env:GATE_HOST = "localhost"
$env:GATE_PORT = "8080"
$env:N8N_PIPELINE_URL = "http://localhost:5678/webhook/etb-threats"
$env:GATE_ENGINE_API_KEY = "EB-COMMAND-CENTER-SECURE-KEY"

# 2. Recycle existing background task job handles cleanly
Write-Host "[*] Recycling active background process contexts..." -ForegroundColor Gray
Stop-Job -Name "ETB_Proxy_Gate" -ErrorAction SilentlyContinue
Remove-Job -Name "ETB_Proxy_Gate" -Force -ErrorAction SilentlyContinue

# 3. Launch the LayerZero Proxy Verification Gate using the absolute path
& "C:\Users\casei\Desktop\etb_payshield\start_etb_shield.ps1"

# --- REFINED: Dynamic Socket Wait Handle ---
Write-Host "[*] Waiting for backend socket layer to bind on port 8080..." -ForegroundColor Gray
$RetryCount = 0
$MaxRetries = 5
$SocketBound = $false

while (-not $SocketBound -and $RetryCount -lt $MaxRetries) {
    if (Get-NetTCPConnection -LocalPort 8080 -State Listen -ErrorAction SilentlyContinue) {
        $SocketBound = $true
    } else {
        Start-Sleep -Seconds 1
        $RetryCount++
    }
}
# --------------------------------------------

# 4. Automation Step A: Simulate Unauthorized Traffic Interception
Write-Host "`n[*] Automation Step A: Launching unauthorized simulation string..." -ForegroundColor Yellow
try {
    $null = Invoke-RestMethod -Uri "http://localhost:8080" -Method Post -Body '{"unauthorized_test": true}' -ContentType "application/json" -TimeoutSec 2
} catch {
    if ($_.Exception.Response) {
        $statusCode = $_.Exception.Response.StatusCode.Value__
        Write-Host "[?] Success: Gate actively blocked request with HTTP Status Code: $statusCode" -ForegroundColor Green
    } else {
        Write-Host "[-] Connection error encountered: Gate did not initialize properly." -ForegroundColor Red
    }
}

# 5. Automation Step B: Simulate Authorized PayPal Payload Processing
Write-Host "`n[*] Automation Step B: Launching authenticated sandbox payload..." -ForegroundColor Yellow
$headers = @{"X-ETB-Key" = "EB-COMMAND-CENTER-SECURE-KEY"}
$simBody = @{
    transaction_id = "PAYPAL-TX-AUTO-777"
    amount = "149.00"
    status = "AUTOMATION_STREAMED"
    telemetry_class = "Zero-Click Ingestion Pipeline Active"
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri "http://localhost:8080" -Method Post -Headers $headers -Body $simBody -ContentType "application/json" -TimeoutSec 5
    if ($response.status -eq "Verified") {
        Write-Host "[?] Success: Gate successfully passed telemetry array. Response: Gateway Verified." -ForegroundColor Green
    }
} catch {
    Write-Host "[-] Request failed or timed out. Check if background engine is listening on 8080." -ForegroundColor Red
}

# 6. Automation Step C: Invoke the AppSec AI Telemetry Compiler Engine
Write-Host "`n[*] Automation Step C: Triggering out-of-band AI synthesis engine..." -ForegroundColor Yellow
python "C:\Users\casei\Desktop\etb_payshield\pipeline\ai_analyzer.py"

# 7. AUTOMATED CHECKPOINT: Git Standalone Installer Check
Write-Host "`n[*] Running System Diagnostics: Checking environment toolchain paths..." -ForegroundColor Gray
if (Get-Command git -ErrorAction SilentlyContinue) {
    $GitPath = (Get-Command git).Source
    Write-Host "[?] Git CLI detected on environment PATH: $GitPath" -ForegroundColor Green
} else {
    Write-Host "[!] Git CLI not detected. Note: Use web drag-and-drop fallback for GitHub uploads." -ForegroundColor Yellow
}

# 8. Print Consolidated Execution Logs and Compliance Deliverables
Write-Host "`n====================================================" -ForegroundColor Cyan
Write-Host "[?] AUTOMATION PIPELINE RUN COMPLETE" -ForegroundColor Green
Write-Host "====================================================" -ForegroundColor Cyan
Write-Host "[*] Outputting final CISO compliance report matrix below:`n" -ForegroundColor Gray

if (Test-Path "C:\Users\casei\Desktop\etb_payshield\dashboard\ai_compliance_report.json") {
    Get-Content -Path "C:\Users\casei\Desktop\etb_payshield\dashboard\ai_compliance_report.json"
} else {
    Write-Error "CRITICAL: AI Compliance output data target missing from dashboard directory path."
}
Write-Host "`n====================================================" -ForegroundColor Cyan
