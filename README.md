# 🌀 Arduino Sentinel Indicator (Chimera Protocol)

Arduino Uno R4 Minima とリアルタイムな気象・環境リスクデータを同期させる、アンビエント・インジケーター・プロジェクト。
JAPAN Sentinel のデータを、Windows PC (PowerShell) をブリッジとして物理的な「光の鼓動」に変えます。

## 🌟 特徴
- **リアルタイム連動**: ブラウザが判定した現在地の「気温」と「環境リスク指数」を 30秒ごとに取得。
- **3段階アラートシステム**: 
  - **Safe (0-10)**: 常時点灯（静寂）
  - **Warning (11-50)**: サイン波による呼吸（リスクに伴い速度上昇）
  - **Alert (51-100)**: 単純点滅（高リスク時の警告フラッシュ）
- **R4 パフォーマンスの限界**: 8-bit PWM による安定した明暗制御と、13番ピンの超微光「幽玄ほたる」エフェクトを両立。
- **Chimera Protocol**: ネット接続のない Arduino に、PC の外部脳を通じて Web の知能を流し込む。

## 🛠️ ハードウェア構成
- **Core**: Arduino Uno R4 Minima
- **LED**: RGB 4極 LED (Anode Common)
  - Pin 10: Red
  - Pin 11: Green
  - Pin 9: Blue
  - Common Pin: 5V (or 3.3V)
- **Built-in LED (L)**: System Heartbeat (Heartbeat pulse)

## 📁 ソフトウェア構成
- `WeatherIndicator.ino`: Arduino 側の制御ロジック。シリアル通信で届いたデータを解析し、光の質感を変えます。
- `FetchSentinel.ps1`: PC 側のブリッジスクリプト。`wttr.in` と `sentinel_data.json` からデータを取得し、Arduino に送信します。

## 🚀 使い方
1. Arduino Uno R4 Minima に `WeatherIndicator.ino` をデプロイします。
2. Windows PC で `FetchSentinel.ps1` を実行します。
   ```powershell
   .\FetchSentinel.ps1
   ```
3. LED が現在の気温に基づいた色で光り、リスク指数に合わせたリズムで呼吸・点滅を始めます。

## 📝 ライセンス
[MIT License](LICENSE)
