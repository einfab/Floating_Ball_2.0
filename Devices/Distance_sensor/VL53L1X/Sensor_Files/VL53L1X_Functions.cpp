#include "VL53L1X_Functions.h"
#include "Arduino.h"
#include "Wire.h"
#include "VL53L1X.h"

VL53L1X sensor; 

void setupFunctionVL53L1X_Functions(){
    Wire.begin();       

    if (!sensor.init()) {
    //while (1) {}
    }

    sensor.setDistanceMode(VL53L1X::Short); 
    sensor.startContinuous(20);
}

// Distance uint16 [1,1]


void stepFunctionVL53L1X_Functions(uint16_T * Distance,int size_vector_1){
  *Distance = sensor.read();
}