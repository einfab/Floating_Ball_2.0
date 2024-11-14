# Ultrasonic Ranging Module HC-SR04
The sensor from the Arduino Uno Kit.
## Arduino IDE
This is an example program, to get sensor data from the HC-SR04.
## Simulink 
This program creates a Trigger pulse for the sensor and measures the time from echo pin, using an External Interrupt. 
The following things should be considered:
- There is no implementation for the error handling in case of an overflow for the time Measurement. (Using milis() which is a uint32)
- The trig Pin is currently triggered, by a Timer Interrupt. This needs to be reworked/considered if used in the final project.