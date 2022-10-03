const int acqLiveInPin = 5;       // pin for acqLive signal from Timeline
const int LEDOutPin = 4;          // pin for driving LED (assuming digital PIN that's connected to LED driver)

const int poissonPin = 7;
const int minPoissonDur = 10; //ms
const int maxPoissonDur = 200; //ms
const int LEDFlashDuration = 500; // Duration for LED "dark" flash in ms

int lastAcqLiveState = 0;
int currentAcqLiveState = 0;

unsigned long delayStartLED = 0;
unsigned long lastFlipTime = 0;
unsigned long timeNow = 0;
unsigned long poissonStateDur = 0;
int currentPoissonState = 0;
int LEDState = 1; // current state of LED (it should be on almost all the time)

void setup() {
  pinMode(acqLiveInPin, INPUT);
  pinMode(LEDOutPin,OUTPUT);
  pinMode(poissonPin, OUTPUT);
//  Serial.begin(9600); // unnecessary?
  
  digitalWrite(poissonPin, LOW);
  digitalWrite(LEDOutPin,HIGH); // Should only transiently be low when acqLive changes its state
  currentPoissonState = LOW;
  poissonStateDur = random(minPoissonDur, maxPoissonDur);
  lastFlipTime = millis();
  delayStartLED=millis(); // Unnecessary here? Timer for LED

}

void loop() {
  // put your main code here, to run repeatedly:

  currentAcqLiveState = digitalRead(acqLiveInPin);
  timeNow = millis();

  // Turn off LED for x ms every time AcqLive flips (either beginning or end of experiment)
  if (LEDState && (currentAcqLiveState!=lastAcqLiveState)) { 
    LEDState = 0;
    digitalWrite(LEDOutPin,LOW);
    // start timer
    delayStartLED=millis(); 
  } else if (LEDState==0 && (millis()-delayStartLED)>=LEDFlashDuration){
    // we should be really unlucky for acqLive to flip just before wraparound of unsigned long
    // in which case millis()-delayStartLED will be negative (lazy coding)
    LEDState=1;
    digitalWrite(LEDOutPin,HIGH);    
  }
  
  // Update Acquisition Live Status
  lastAcqLiveState = currentAcqLiveState;

  //code for flipper
  if (currentAcqLiveState==HIGH && (timeNow-lastFlipTime)>poissonStateDur) {
    lastFlipTime = timeNow;
    if (currentPoissonState==LOW){
      currentPoissonState=HIGH;
    } else {
      currentPoissonState=LOW;
    }
    digitalWrite(poissonPin, currentPoissonState);
    poissonStateDur = random(minPoissonDur, maxPoissonDur);
  } else if (timeNow < lastFlipTime) {
    // this can only happen when the millis() function wraps around at the limit of the unsigned long datatype
    lastFlipTime = 1; // pretend we flipped at 1
  }
  
  delayMicroseconds(50);
}
