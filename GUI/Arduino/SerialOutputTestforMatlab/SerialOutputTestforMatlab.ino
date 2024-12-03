#include <math.h>

//Timer1 preload
const unsigned int PreloadTimer1 = 64911;
//Timer2 preload
const unsigned int PreloadTimer2 = 100;
int Timer2Counter = 0;

volatile bool measurement_flag = false;

// Parameter für den Sinus
const double frequency = 5.0;   // Frequency of the Sinus in Hz
double amplitude = 100.0; // Amplitude
double offset = 100.0;   // Offset
const double sampling_rate = 5.0; // Effektive Abtastrate in Hz
double angle = 0.0;            // Angle in Radiant
const double step = 2 * M_PI * frequency / 100; // stepsize per Output
String state = "Start"; 


void setup()
{
  Serial.begin(115200);
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

  //Serial.println("Initialisation Interrupt ok");

  //---------------------------------------------------------------End of Enable Interrupt
}
bool ledState1 = false;
bool ledState2 = false;

ISR(TIMER2_OVF_vect)
{
  TCNT2 = PreloadTimer2;
  if(Timer2Counter >= 4)
  {
    measurement_flag = true;
    Timer2Counter = 0;
  }
  else{Timer2Counter++;}
}

ISR(TIMER1_OVF_vect)
{
  TCNT1 = PreloadTimer1;
  //measurement_flag = true;
}

void loop(void)
{
  if (Serial.available() > 0) {
        // read the incoming byte:
        state = Serial.readStringUntil('\n');
  }


  //Calculation for the next control circle
  if(state == "Start")
  {
    if (measurement_flag) {
      // Calculate Sinus
    double sinus = amplitude * sin(angle) + offset;
    // Winkel increment
      angle += step;
      if (angle >= 2 * M_PI)
      {
        angle -= 2 * M_PI; // reset angle, to avoid overflow
      }
      Serial.print(millis());
      Serial.print(";");
      Serial.print(sinus);
      Serial.print(";");
    
      measurement_flag = false;
    }
  }
  
  //Serial.print(state);
}
