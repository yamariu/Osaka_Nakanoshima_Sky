/*
 * Nakanoshima-SkyColor.ino (Production Ready)
 */

const int redPin   = 10;
const int greenPin = 11;
const int bluePin  = 9;
const bool isAnodeCommon = true; 

void updateLED(int r, int g, int b) {
  r = constrain(r, 0, 255);
  g = constrain(g, 0, 255);
  b = constrain(b, 0, 255);

  if (isAnodeCommon) {
    analogWrite(redPin, 255 - r);
    analogWrite(greenPin, 255 - g);
    analogWrite(bluePin, 255 - b);
  } else {
    analogWrite(redPin, r);
    analogWrite(greenPin, g);
    analogWrite(bluePin, b);
  }
}

void setup() {
  analogWriteResolution(8);
  pinMode(redPin, OUTPUT);
  pinMode(greenPin, OUTPUT);
  pinMode(bluePin, OUTPUT);
  
  // 初期状態：スカイブルーで待機
  updateLED(135, 206, 235);
  
  Serial.begin(115200);
}

void loop() {
  if (Serial.available() > 0) {
    // 改行まで読み取る
    String line = Serial.readStringUntil('\n');
    line.trim();
    
    if (line.length() > 0) {
      int r, g, b;
      // カンマ区切りの数値を3つ抽出
      if (sscanf(line.c_str(), "%d,%d,%d", &r, &g, &b) == 3) {
        updateLED(r, g, b);
      }
    }
  }
}
