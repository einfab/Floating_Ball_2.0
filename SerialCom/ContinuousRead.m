clc
clear

serialPort = 'COM3';
baudRate = 115200;
timeout = 10;
arduino = serialport(serialPort, baudRate, 'Timeout', timeout);
configureTerminator(arduino,59);
while true
    if arduino.NumBytesAvailable > 0
        [Time, Distance] = SingleRead(arduino);
        disp(Time)
        disp (Distance)
    end
end
