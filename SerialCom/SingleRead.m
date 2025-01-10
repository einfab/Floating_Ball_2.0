function [Outtime, Outdistance, Outmotorspeed, Outvoltage] = SingleRead(arduino)
timewithstart = readline(arduino);
% disp(timewithstart)
    if contains(timewithstart, "Start")
        time = regexp(timewithstart, "Start:\s*([-\d.]+)", "tokens");
        motorspeed = readline(arduino);
        distance = readline(arduino);
        voltage = readline(arduino);
        % disp(time);
        % disp(motorspeed);
        % disp(distance);
        % disp(voltage);
        if ~isempty(time)
            timeValue = str2double(time{1}{1})/1000; 
            Outtime = timeValue;
            % disp("TimeValue")
            % disp(timeValue)
            
            distanceValue = str2double(distance);
            Outdistance = distanceValue;
            % disp("DistanceValue")
            % disp(distanceValue)
            
            motorspeedValue = str2double(motorspeed);
            Outmotorspeed = motorspeedValue;
            % disp("Motorspeed")
            % disp(motorspeedValue)
            
            voltageValue = str2double(voltage);
            Outvoltage = voltageValue;
            % disp("VoltageValue")
            % disp(voltageValue)
        end
    else
        Outtime = 0;
        Outdistance= 0;
        Outmotorspeed = 0;
        Outvoltage = 0;
    end
end