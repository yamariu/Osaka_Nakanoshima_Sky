/*
 * Arduino-Sentinel-Indicator.ino (V10: Sticky Color Edition)
 */

const int redPin = 10;
const int greenPin = 11;
const int bluePin = 9;
const int builtinLed = 13;
const bool isAnodeCommon = true; 

// 最後に成功した受信値を保持する
int currentR = 0, currentG = 0, currentB = 0;
float currentRisk = 0.0; 
unsigned long lastBlinkUpdate = 0;
bool blinkState = true;

void setup() {
  analogWriteResolution(8);
  pinMode(redPin, OUTPUT);
  pinMode(greenPin, OUTPUT);
  pinMode(bluePin, OUTPUT);
  pinMode(builtinLed, OUTPUT);
  
  // 初期消灯
  analogWrite(redPin, 255);
  analogWrite(greenPin, 255);
  analogWrite(bluePin, 255);
  
  Serial.begin(115200);
  Serial.setTimeout(100);
}

void loop() {
  unsigned long currentMillis = millis();
  
  // 1. 受信ロジック（より慎重に）
  if (Serial.available() > 0) {
    String line = Serial.readStringUntil('\n');
    line.trim();
    
    if (line.length() > 0) {
      int c1 = line.indexOf(',');
      int c2 = line.indexOf(',', c1 + 1);
      int c3 = line.indexOf(',', c2 + 1);
      
      if (c1 != -1 && c2 != -1 && c3 != -1) {
        // 新しい値が正しい時だけ上書きする
        currentR = line.substring(0, c1).toInt();
        currentG = line.substring(c1 + 1, c2).toInt();
        currentB = line.substring(c2 + 1, c3).toInt();
        currentRisk = line.substring(c3 + 1).toFloat();
      }
    }
  }

  // 2. 呼吸エフェクト
  float modifier = 1.0;
  if (currentRisk > 0 && currentRisk <= 50.0) {
    float speedFactor = map(constrain((int)currentRisk, 1, 50), 1, 50, 5000, 1000);
    float angle = (currentMillis % (int)speedFactor) / (float)speedFactor * 2.0 * PI;
    modifier = (sin(angle - PI/2.0) + 1.0) / 2.0;
    modifier = modifier * modifier; 
  } else if (currentRisk > 50.0) {
    int interval = map(constrain((int)currentRisk, 51, 100), 51, 100, 500, 50);
    if (currentMillis - lastBlinkUpdate >= interval) {
      lastBlinkUpdate = currentMillis;
      blinkState = !blinkState;
    }
    modifier = blinkState ? 1.0 : 0.0;
  } else {
    // リスクが 0 か、まだ受信してへん時はそのまま
    modifier = 1.0;
  }

  // 3. 出力（アノードコモン）
  int valR = (int)(currentR * modifier);
  int valG = (int)(currentG * modifier);
  int valB = (int)(currentB * modifier);

  if (isAnodeCommon) {
    analogWrite(redPin, 255 - valR);
    analogWrite(greenPin, 255 - valG);
    analogWrite(bluePin, 255 - valB);
  } else {
    analogWrite(redPin, valR);
    analogWrite(greenPin, valG);
    analogWrite(bluePin, valB);
  }
  
  analogWrite(builtinLed, 5);
  delay(1);
}
