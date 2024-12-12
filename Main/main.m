clc
disp("Starting the Floating Ball...")


if exist('baudRate', 'var') == 0
    clear
    PortAsString = serialportlist;
    PortAvailable = char(extractBetween(PortAsString, 1, 4));
    baudRate = 19200;
    timeout = 10;
    arduino = serialport(PortAvailable, baudRate, 'Timeout', timeout);
    configureTerminator(arduino,59,"LF");
end

guiName = 'Ball and Motor Control';
existingGui = findobj('Type', 'figure', 'Name', guiName);
if ~isempty(existingGui)
    figure(existingGui);
else
    Final_GUI(arduino);
end