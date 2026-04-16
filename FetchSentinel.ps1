# FetchSentinel.ps1 (V10: Sticky Blue Bridge)
# Sends real-time color and risk to Arduino.

$portName = "COM3"
$baudRate = 115200
$sentinelUrl = "https://wappa88jp.sakura.ne.jp/sentinel/sentinel_data.json"

if ($port -ne $null) { $port.Close() }
$port = New-Object System.IO.Ports.SerialPort $portName, $baudRate, None, 8, One
$port.Open()

Write-Host "Sticky Blue Bridge Started." -ForegroundColor Cyan

try {
    while ($true) {
        Write-Host "`n--- Syncing ---"
        try {
            $resp = Invoke-RestMethod -Uri $sentinelUrl
            $risk = $resp.risk_score
            
            # Base Color (Sunny Blue)
            $r = 0; $g = 120; $b = 255
            if ($resp.rain -gt 0) { $r = 0; $g = 0; $b = 180 }
            elseif ($resp.weather -match "曇") { $r = 80; $g = 80; $b = 80 }

            $msg = "$r,$g,$b,$risk`n"
            Write-Host "SEND -> $msg" -ForegroundColor Green
            $port.Write($msg)
        }
        catch {
            Write-Warning "Update Failed: $_"
        }
        Start-Sleep -Seconds 30
    }
}
finally {
    $port.Close()
}
