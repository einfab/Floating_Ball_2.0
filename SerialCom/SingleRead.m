function [Outtime, Outdistance] = SingleRead(arduino)
time = readline(arduino);
% if isnan(time)
    % timeValue = 0;
% else
    timeValue = str2double(time)/1000;
% end
Outtime = timeValue;

distance = readline(arduino);
% if isnan(distance)
    % distanceValue = 0;
% else
    distanceValue = str2double(distance);
% end
Outdistance = distanceValue;
end