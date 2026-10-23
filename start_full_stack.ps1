# ETB PayShield Master Full-Stack Controller
Clear-Host
Write-Host "====================================================" -ForegroundColor Cyan
Write-Host "[*] Booting Complete ETB PayShield Ecosystem..." -ForegroundColor Cyan
Write-Host "====================================================" -ForegroundColor Cyan

# 1. Standardize environment session parameters
$env:GATE_HOST = "localhost"
$env:GATE_PORT = "8080"
$env:N8N_PIPELINE_URL = "http://localhost:5678/webhook/etb-threats"
$env:GATE_ENGINE_API_KEY = "EB-COMMAND-CENTER-SECURE-KEY"

# 2. Recycle existing background process handles cleanly
Stop-Job -Name "ETB_Proxy_Gate" -ErrorAction SilentlyContinue
Remove-Job -Name "ETB_Proxy_Gate" -Force -ErrorAction SilentlyContinue

# 3. Spawn the LayerZero Gateway Listener Node in the background
Write-Host "[*] Spawning LayerZero validation gate proxy context..." -ForegroundColor Yellow
& "C:\Users\casei\Desktop\etb_payshield\start_etb_shield.ps1"
Start-Sleep -Seconds 2

# 4. Fire up the Next.js Frontend Command Center on Port 3000
Write-Host "`n[*] Initializing Next.js development server on port 3000..." -ForegroundColor Yellow
cd "C:\Users\casei\Desktop\etb_payshield\dashboard"
npx next dev -p 3000
