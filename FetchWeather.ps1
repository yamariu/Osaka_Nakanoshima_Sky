# FetchWeather.ps1
# PC Bridge for Arduino Weather Indicator (Intensity Edition)
# Fetches current weather + precipitation and sends to COM3

$portName = "COM3"
$baudRate = 115200
$apiUrl = "https://wttr.in/?format=j1"

# Initialize Serial Port
if ($port -ne $null) { $port.Close() }
$port = New-Object System.IO.Ports.SerialPort $portName, $baudRate, None, 8, One
$port.Open()

Write-Host "Weather Intensity Bridge Started. Sending data to $portName..."

try {
    while ($true) {
        Write-Host "Fetching weather data..."
        try {
            # Get weather from wttr.in
            $response = Invoke-RestMethod -Uri $apiUrl
            $current = $response.current_condition[0]
            
            $temp = $current.temp_C
            $condition = $current.weatherDesc[0].value.Replace(" ", "") # Remove spaces
            $precip = $current.precipMM
            
            # Message Format: W:TEMP,CONDITION,PRECIP
            $msg = "W:$temp,$condition,$precip`n"
            Write-Host "Sending to Arduino: $msg"
            
            # Send to Arduino
            $port.Write($msg)
        }
        catch {
            Write-Warning "Failed to fetch or send weather data: $_"
        }

        # Wait for 10 minutes
        Start-Sleep -Seconds 600
    }
}
finally {
    $port.Close()
    Write-Host "Port closed."
}
