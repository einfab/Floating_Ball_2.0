function [Output] = ReadSensorData(arduino)
index = 1;
while arduino.NumBytesAvailable > 0

    data = readline(arduino);
    sensorValue = str2double(data);

        if ~isnan(sensorValue)
            Output(index) = sensorValue;
        else
            disp('Ungültige Daten empfangen.');
            Output = 0;
        end
    index = index +1;
end
