# ETB PayShield Live Task Orchestration Daemon
# Watches for intercepted traffic logs and forwards them to the STIX 2.1 Serialization Engine

$logPath = "gate\intercept_stream.log"
Write-Host "📡 ETB PayShield Background Task Orchestration Engine Active..." -ForegroundColor Cyan
Write-Host "Watching tracking log target: $logPath" -ForegroundColor Yellow

# Create file if it doesn't exist to prevent polling breaks
if (-not (Test-Path $logPath)) { New-Item -ItemType File -Path $logPath -Force | Out-Null }

# Get current line count to only process new additions
$lineCount = (Get-Content $logPath).Length

while ($true) {
    Start-Sleep -Seconds 1
    if (Test-Path $logPath) {
        $currentLines = Get-Content $logPath
        if ($currentLines.Length -gt $lineCount) {
            # Extract new raw transaction log entries
            $newEntries = $currentLines[$lineCount..($currentLines.Length - 1)]
            foreach ($entry in $newEntries) {
                if ($entry -match 'INTERCEPTED: src=(?<src>[^ ]+) dst_port=(?<port>\d+) method=(?<method>[^ ]+)') {
                    $src = $Matches.src
                    $port = $Matches.port
                    $method = $Matches.method
                    
                    Write-Host "[⚠️] Threat Intercept Detected: src=$src dst_port=$port method=$method. Triggering STIX parser..." -ForegroundColor Red
                    
                    # Programmatically execute your Python serialization pipeline matrix
                    python pipeline\stix_parser.py --src $src --port $port --method $method --anomalous True
                }
            }
            $lineCount = $currentLines.Length
        }
    }
}
