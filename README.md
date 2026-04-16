# Osaka Nakanoshima Sky Indicator 🌌

大阪市北区中之島のライブカメラから空の色をリアルタイムで取得し、Arduino Uno R4 に接続した 4極LED で再現するプロジェクトです。

## 概要
- **画像取得**: ウェザーニュースのライブカメラ（中之島）の最新 WebP 画像を PowerShell で 1分おきに取得。
- **解析**: 画像の上部 25%（空のエリア）の平均 RGB 値を計算。
- **出力**: Arduino (Serial) 経由で RGB LED を PWM 制御。

## 構成
- **Hardware**: Arduino Uno R4 Minima + RGB LED (Anode Common)
- **Software**: 
  - `Nakanoshima-SkyColor/Nakanoshima-SkyColor.ino`: LED 制御スケッチ
  - `SyncSkyColor.ps1`: 画像解析 & シリアル転送スクリプト
  - `RunSyncSky.vbs`: バックグラウンド実行用ランナー

## 使い方
1. Arduino に `Nakanoshima-SkyColor.ino` を書き込む。
2. LED を Pin 9 (B), 10 (R), 11 (G) に接続。
3. Windows 上で `SyncSkyColor.ps1` を実行、または `RunSyncSky.vbs` をスタートアップに登録。

---
Produced by Gemini CLI.
