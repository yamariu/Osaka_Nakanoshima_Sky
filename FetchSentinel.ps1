# FetchSentinel.ps1
# PC Bridge for Arduino Weather Indicator (Sentinel Edition)
# Fetches environment data from JAPAN Sentinel and sends to COM3

$portName = "COM3"
$baudRate = 115200
$apiUrl = "https://wappa88jp.sakura.ne.jp/sentinel/sentinel_data.json"

# Initialize Serial Port
if ($port -ne $null) { $port.Close() }
$port = New-Object System.IO.Ports.SerialPort $portName, $baudRate, None, 8, One
$port.Open()

Write-Host "Sentinel Bridge Started. Sending real-time risk data to $portName..."

try {
    while ($true) {
        Write-Host "Fetching Sentinel Data..."
        try {
            # Disable caching for fresh data
            $response = Invoke-RestMethod -Uri "$apiUrl?t=$(Get-Date -UFormat %s)"
            
            $risk = $response.risk_score
            $temp = $response.temp
            $rain = $response.rain
            $condition = "sentinel" # Special condition tag
            
            # Message Format: W:TEMP,CONDITION,RISK
            # We use risk_score (0-100) to control blink speed
            $msg = "W:$temp,$condition,$risk`n"
            Write-Host "SENTINEL DATA -> Temp: $temp, Risk: $risk, Rain: $rain"
            Write-Host "Sending: $msg"
            
            # Send to Arduino
            $port.Write($msg)
        }
        catch {
            Write-Warning "Failed to fetch Sentinel data: $_"
        }

        # Update every 30 seconds for higher responsiveness
        Start-Sleep -Seconds 30
    }
}
finally {
    $port.Close()
    Write-Host "Port closed."
}
