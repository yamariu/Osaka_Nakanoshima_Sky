# SyncSkyColor.ps1
# 中之島ライブカメラの空の色を Arduino (COM3) に送信する

$portName = "COM3"
$baudRate = 115200
$camId = "7CDDE9068718"

# シリアルポートの初期化
if ($port) { $port.Close() }
try {
    $port = New-Object System.IO.Ports.SerialPort $portName, $baudRate, None, 8, One
    $port.Open()
} catch {
    Write-Error "Could not open $portName. Is the serial monitor open?"
    exit
}

Write-Host "Syncing Nakanoshima Sky Color to $portName..." -ForegroundColor Cyan
Write-Host "Press Ctrl+C to stop."

# Windows.Graphics.Imaging を使うために必要
[void][Windows.Graphics.Imaging.BitmapDecoder, Windows.Graphics.Imaging, ContentType = WindowsRuntime]

try {
    while ($true) {
        # 2分前のタイムスタンプを作成（ライブカメラの画像生成のラグを考慮）
        $now = [DateTime]::Now
        $time = $now.AddMinutes(-2).ToString("yyyyMMddHHmm00")
        $url = "https://gvs.weathernews.jp/livecam/$camId/640/$time.webp"
        $tmpFile = "$env:TEMP\skycam_$time.webp"

        Write-Host "`n[$($now.ToString('HH:mm:ss'))] Fetching: $time.webp" -NoNewline

        try {
            # 画像ダウンロード
            Invoke-WebRequest -Uri $url -OutFile $tmpFile -ErrorAction Stop

            # 画像の解析 (上部 25% の平均色)
            $stream = [System.IO.File]::OpenRead($tmpFile)
            $asyncOp = [Windows.Graphics.Imaging.BitmapDecoder]::CreateAsync($stream.AsRandomAccessStream())
            
            # 非同期処理の完了を待機
            while ($asyncOp.Status -eq 'Started') { Start-Sleep -Milliseconds 10 }
            $decoder = $asyncOp.GetResults()
            
            $pixelDataOp = $decoder.GetPixelDataAsync()
            while ($pixelDataOp.Status -eq 'Started') { Start-Sleep -Milliseconds 10 }
            $pixelData = $pixelDataOp.GetResults()
            
            $pixels = $pixelData.DetachPixelData()
            
            $totalR = $totalG = $totalB = 0
            $count = 0
            
            $height = $decoder.PixelHeight
            $width = $decoder.PixelWidth
            $sampleHeight = [Math]::Floor($height * 0.25) # 上部 25% (空の部分)

            # 10ピクセルおきにサンプリングして負荷を減らす
            for ($y = 0; $y -lt $sampleHeight; $y += 10) {
                for ($x = 0; $x -lt $width; $x += 10) {
                    $idx = ($y * $width + $x) * 4
                    # WebP デコーダー (BGRA 形式)
                    $totalB += $pixels[$idx]
                    $totalG += $pixels[$idx + 1]
                    $totalR += $pixels[$idx + 2]
                    $count++
                }
            }
            $stream.Close()
            $stream.Dispose()

            if ($count -gt 0) {
                $avgR = [Math]::Floor($totalR / $count)
                $avgG = [Math]::Floor($totalG / $count)
                $avgB = [Math]::Floor($totalB / $count)

                # Arduino へ送信
                $msg = "$avgR,$avgG,$avgB`n"
                $port.Write($msg)
                Write-Host " -> RGB($avgR, $avgG, $avgB)" -ForegroundColor Green
            }
        }
        catch {
            Write-Host " -> Failed (URL not ready or Image error)" -ForegroundColor Yellow
        }

        # 一時ファイルの削除
        if (Test-Path $tmpFile) { Remove-Item $tmpFile }

        # 60秒待機
        Start-Sleep -Seconds 60
    }
}
finally {
    if ($port) { $port.Close() }
    Write-Host "`nBridge stopped."
}
