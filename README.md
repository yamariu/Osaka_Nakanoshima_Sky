# Osaka Nakanoshima Sky Indicator 🌌

大阪市北区中之島のライブカメラから空の色をリアルタイムで取得し、Arduino Uno R4 に接続した 4極LED で再現するプロジェクトです。

## 概要
- **画像取得**: ウェザーニュースのライブカメラ[中之島](https://weathernews.jp/onebox/livecam/kinki/osaka/7CDDE9068718/)の最新 WebP 画像を PowerShell で 1分おきに取得。
- **解析**: 画像の上部 25%（空のエリア）の平均 RGB 値を計算。
- **出力**: Arduino (Serial) 経由で RGB LED を PWM 制御。

## 構成

### Hardware
- **Core**: Arduino Uno R4 Minima
- **Indicator**: RGB LED (Anode Common 推奨)
- **Pin Assignment**:
  - **Pin 10**: Red (赤)
  - **Pin 11**: Green (緑)
  - **Pin 9**: Blue (青)
  - **Common**: 5V (アノードコモンの場合)
  ※カソードコモンの場合はスケッチの `isAnodeCommon` を `false` に書き換え、Common を GND に接続してください。

### Software
- `Nakanoshima-SkyColor/Nakanoshima-SkyColor.ino`: LED 制御スケッチ (Arduino)
- `SyncSkyColor.ps1`: 画像解析 & シリアル転送スクリプト (Windows / PowerShell)
- `RunSyncSky.vbs`: バックグラウンド実行用ランナー (VBScript)

## デプロイ方法

### 1. Arduino への書き込み
`arduino-cli` を使用する場合、以下のコマンドで書き込めます。
```powershell
# コンパイル
./arduino-cli.exe compile --fqbn arduino:renesas_uno:minima Nakanoshima-SkyColor

# 書き込み (ポートは環境に合わせて変更してください)
./arduino-cli.exe upload -p COM3 --fqbn arduino:renesas_uno:minima Nakanoshima-SkyColor
```

### 2. Windows 側の準備
PowerShell スクリプトの実行を許可する必要があります。
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process
```

### 3. 自動起動の設定
1. `RunSyncSky.vbs` 内のパスが正しいことを確認します。
2. `RunSyncSky.vbs` のショートカットを作成し、スタートアップフォルダ (`shell:startup`) に配置します。

---
Produced by Gemini CLI.
