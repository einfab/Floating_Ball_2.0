/*

SETUP: 
Connect Pin3 and an LED which is connected over a resistor to GND.
Connect the sensor with Vcc, GND, SDA & SCL

Important: The sensor mustn't look in the air -- there is a bug then! Place a book or sth else at 30cm distance befor uploading the program.

*/

//------Sensor
#include <Wire.h>
#include <VL53L1X.h>


const int led1 = 3; //DIO
const int led2 = 4; //DIO

//Timer1 preload
const unsigned int PreloadTimer1 = 64911;
//Timer2 preload
const unsigned int PreloadTimer2 = 100;
int Timer2Counter = 0;

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

  Serial.println("Initialisation ok");


  //---------------------------------------------------------------End of Enable Interrupt
  //Timer 1
  TCCR1A = 0x00;
  TCCR1B = 0x00;
  TCCR1B |= (1 << CS12) + (0 << CS11) + (1 << CS10);//<--Prescaler 1024 // Prescaler 8: (0 << CS12) + (1 << CS11) + (0 << CS10);
  TIMSK1 = (1 << TOIE1);
  TCNT1 = PreloadTimer1; //This prload is used to achieve the 40ms timeperiode  f = sysclock/(prescaler * (2^16 - preload))

  //Timer 2
  TCCR2A = 0x00;
  TCCR2B = 0x00;
  TCCR2B |= (1 << CS22) + (1 << CS21) + (1 << CS20);
  TIMSK2 = (1 << TOIE2);
  TCNT2 = PreloadTimer2;

  Serial.println("Initialisation Interrupt ok");

  //---------------------------------------------------------------End of Enable Interrupt



}

bool ledState1 = false;
bool ledState2 = false;
int measurements[5] = {0};

ISR(TIMER2_OVF_vect)
{
  TCNT2 = PreloadTimer2;
  if(Timer2Counter >= 4)
  {
    digitalWrite(led2, ledState2 ? HIGH : LOW);
    ledState2 = !ledState2;
    measurement_flag = true;
    Timer2Counter = 0;
  }
  else{Timer2Counter++;}
}

ISR(TIMER1_OVF_vect)
{
  TCNT1 = PreloadTimer1;
  digitalWrite(led1, ledState1 ? HIGH : LOW);
  ledState1 = !ledState1;
  //measurement_flag = true;
}

void loop(void)
{
  // noInterrupts();
  // interrupts();

  //here should be the new calculated settings of the previous control circle

  //Calculation for the next control circle
  if (measurement_flag) {
    measurement_flag = false;
    for (int i = 0; i < 5; i++) {
      measurements[i] = sensor.read();
    }
    int avg_measurement = (measurements[0] + measurements[1] + measurements[2] + measurements[3] + measurements[4]) / 5;
    /*
    Serial.println(String(measurements[0]) + "," + 
               String(measurements[1]) + "," + 
               String(measurements[2]) + "," + 
               String(measurements[3]) + "," + 
               String(measurements[4]));
               //Those measurements vary thats why we take the average over 5 measures.
               */
    Serial.println(avg_measurement);
  }
  delay(100);
}
