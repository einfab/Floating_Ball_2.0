function [Outtime, Outdistance] = SingleRead(arduino)
time = readline(arduino);
timeValue = str2double(time);
Outtime = timeValue;

distance = readline(arduino);
distanceValue = str2double(distance);
Outdistance = distanceValue;
end