/*
 * WeatherIndicator.ino (Absolute Robust Edition)
 * Features:
 *   - Starts at Risk 30 (Always breathes at start)
 *   - 3-Phase: Safe(0-10), Warning(11-50), Alert(51-100)
 */

const int redPin = 10;
const int greenPin = 11;
const int bluePin = 9;
const int builtinLed = 13;
const bool isAnodeCommon = true; 

float currentTemp = 17.0; 
float currentRisk = 30.0; // Start with Breathing mode for verification
unsigned long lastBlinkUpdate = 0;
bool blinkState = true;

void setup() {
  analogWriteResolution(8);
  pinMode(redPin, OUTPUT);
  pinMode(greenPin, OUTPUT);
  pinMode(bluePin, OUTPUT);
  pinMode(builtinLed, OUTPUT);
  
  Serial.begin(115200);
  Serial.setTimeout(50); // Fast parsing
  Serial.println("Sentinel System: Robust Protocol Online.");
}

void loop() {
  unsigned long currentMillis = millis();
  
  // 1. Efficient Parsing
  if (Serial.available() > 0) {
    if (Serial.find("W:")) {
      currentTemp = Serial.parseFloat();
      Serial.read(); // Skip comma
      Serial.readStringUntil(','); // Skip condition string
      currentRisk = Serial.parseFloat();
      Serial.print("Data Rec -> Risk: "); Serial.println(currentRisk);
    }
  }

  // 2. Logic Controller
  float modifier = 1.0;

  if (currentRisk <= 10.0) {
    modifier = 1.0;
  } 
  else if (currentRisk <= 50.0) {
    // Phase 2: Sine-wave Breathing
    // 11(Risk) -> 4000ms (Slow), 50(Risk) -> 1000ms (Fast)
    float speedFactor = map(constrain((int)currentRisk, 11, 50), 11, 50, 4000, 1000);
    float angle = (currentMillis % (int)speedFactor) / speedFactor * 2.0 * PI;
    float sineVal = (sin(angle - PI/2.0) + 1.0) / 2.0; 
    modifier = sineVal * sineVal; 
  } 
  else {
    // Phase 3: Simple Blink
    int interval = map(constrain((int)currentRisk, 51, 100), 51, 100, 500, 50);
    if (currentMillis - lastBlinkUpdate >= interval) {
      lastBlinkUpdate = currentMillis;
      blinkState = !blinkState;
    }
    modifier = blinkState ? 1.0 : 0.0;
  }

  // Heartbeat (Pin 13)
  analogWrite(builtinLed, 5);

  render(modifier);
  delay(1);
}

void render(float modifier) {
  int r = 0, g = 0, b = 0;
  if (currentTemp < 10.0) { r = 0; g = map(currentTemp, -10, 10, 0, 255); b = 255; }
  else if (currentTemp < 25.0) { r = 0; g = 255; b = map(currentTemp, 10, 25, 255, 0); }
  else { r = 255; g = 0; b = 0; }

  int outR = (int)(r * modifier);
  int outG = (int)(g * modifier);
  int outB = (int)(b * modifier);

  if (isAnodeCommon) {
    analogWrite(redPin, 255 - outR);
    analogWrite(greenPin, 255 - outG);
    analogWrite(bluePin, 255 - outB);
  } else {
    analogWrite(redPin, outR);
    analogWrite(greenPin, outG);
    analogWrite(bluePin, outB);
  }
}
