clc
disp("Starting the Floating Ball...")

if exist('baudRate', 'var') == 0
    clear
    serialPort = 'COM3';
    baudRate = 115200;
    timeout = 10;
    arduino = serialport(serialPort, baudRate, 'Timeout', timeout);
    configureTerminator(arduino,59,"LF");
end

guiName = 'Ball and Motor Control';
existingGui = findobj('Type', 'figure', 'Name', guiName);
if ~isempty(existingGui)
    figure(existingGui);
else
    GUI_extended(arduino);
end