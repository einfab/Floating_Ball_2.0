//#include "C:\Users\Tim\OneDrive - FH JOANNEUM\Semester 5\Projekt\Motorshield\MotorShield_Functions.h"
#include "MotorShield_Functions.h"
#include "Arduino.h"
#include "Wire.h"
#include "Adafruit_MotorShield.h"

Adafruit_MotorShield AFMS = Adafruit_MotorShield();
Adafruit_DCMotor *myMotor = AFMS.getMotor(1);

int setVolt = 0, readVolt, direction = 0;
bool Error = 0;

void setupFunctionMotorShield_Functions(){
  AFMS.begin(400);

  if (!AFMS.begin()) {
    Error = 1;
  }

  myMotor->setSpeed(0);
  delay(20);
  myMotor->run(BACKWARD);
}


// Speed uint8 [1,1]

void stepFunctionMotorShield_Functions(uint8_T Speed,int size_vector_a){
  setVolt = (int)Speed;
  if(Speed >= 255)
  {
    Speed = 255;
  } else if (Speed <= 0)
  {
    Speed = 0;
  }
  setVolt = (int)Speed;
  myMotor->setSpeed(setVolt);
}