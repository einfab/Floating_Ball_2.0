/*

SETUP: 
Connect Pin3 and an LED which is connected over a resistor to GND.
Connect the sensor with Vcc, GND, SDA & SCL

Important: The sensor mustn't look in the air -- there is a bug then! Place a book or sth else at 30cm distance befor uploading the program.

*/

//------Interrupt
#include <TimerOne.h>
//------Sensor
#include <Wire.h>
#include <VL53L1X.h>


const int led = 3; //DIO

VL53L1X sensor;

volatile bool measurement_flag = false;

void setup()
{
  while (!Serial) {}
  Serial.begin(115200);
  Wire.begin();
  Wire.setClock(400000);

  sensor.setTimeout(500);
  if (!sensor.init())
  {
    Serial.println("Failed to detect and initialize sensor!");
    while (1);
  }

 
  sensor.setDistanceMode(VL53L1X::Long);
  sensor.setMeasurementTimingBudget(50000);

  sensor.startContinuous(100);
  //--------------------------------------Interrupt
  pinMode(led, OUTPUT);
  Timer1.initialize(1000000); //at the moment the controlloop triggers every second (150000 == 15ms)
  Timer1.attachInterrupt(controlLoop);
  Serial.print("Initialisation ok");
}


bool ledState = false;
int measurements[5] = {0};

void controlLoop(void)
{
  digitalWrite(led, ledState ? HIGH : LOW);
  ledState = !ledState;
  measurement_flag = true;
}
  

void loop(void)
{
  // noInterrupts();
  // interrupts();
  if (measurement_flag) {
    measurement_flag = false;
    for (int i = 0; i < 5; i++) {
      measurements[i] = sensor.read();
    }
    int avg_measurement = (measurements[0] + measurements[1] + measurements[2] + measurements[3] + measurements[4]) / 5;
    Serial.println(avg_measurement);
  }
  delay(100);
}
