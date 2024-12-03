function [Outtime, Outdistance] = SingleRead(arduino)
time = readline(arduino);
timeValue = str2double(time)/1000;
Outtime = timeValue;

distance = readline(arduino);
distanceValue = str2double(distance);
Outdistance = distanceValue;
end