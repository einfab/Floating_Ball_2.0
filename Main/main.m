clc
disp("Starting the Floating Ball...")


if exist('baudRate', 'var') == 0
  clear;
  PortList = serialportlist;

  baudRate = 19200;
  timeout = 10;
  ArduinoPort = "";
  for i = 1:length(PortList)
      try
          port = char(PortList(i)); % current Port
          arduino = serialport(port, baudRate, 'Timeout', timeout);
      catch
          % No error handling, try next Port
      end
  end

  % clear;
  %   PortAsString = serialportlist;
  %   PortAvailable = char(extractBetween(PortAsString, 1, 4));
  %   baudRate = 19200;
  %   timeout = 10;
  %   arduino = serialport('COM5', baudRate, 'Timeout', timeout);
  %   configureTerminator(arduino,59,"LF");
end

guiName = 'Ball and Motor Control';
existingGui = findobj('Type', 'figure', 'Name', guiName);
if ~isempty(existingGui)
    figure(existingGui);
else
    Final_GUI(arduino);
end