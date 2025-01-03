// #include "C:\Users\Tim\OneDrive - FH JOANNEUM\Semester 5\Projekt\VL53L1X 2\Sensor_Files\VL53L1X_Function.h"
#include "VL53L1X_Function.h"
#include "Arduino.h"
#include "Wire.h"
#include "VL53L1X.h"

VL53L1X sensor;
bool Init_Error = 0;

void setupFunctionVL53L1X_Function(){
  Wire.begin();       

  if (!sensor.init()) {
    Init_Error = 1;
  }

  sensor.setDistanceMode(VL53L1X::Short); 
  sensor.startContinuous(20);
}

// Distance double [1,1]
// Error logical [1,1]


void stepFunctionVL53L1X_Function(double * Distance,int size_vector_1,boolean_T * Error,int size_vector_2){
  if (Init_Error == 0) {
    *Distance = sensor.read();
  }
  else {
    *Distance = -1;
    *Error = Init_Error;
  }
}