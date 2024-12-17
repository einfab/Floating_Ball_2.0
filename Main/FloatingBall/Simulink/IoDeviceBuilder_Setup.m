% IoDeviceBuilderSetup
% Startup Function to edit the Absolute Paths needed by the IoDeviceBuilder
function IoDeviceBuilder_Setup
TmpProject = matlab.project.rootProject;
ProjectPath = TmpProject.RootFolder;
clear TmpProject;


%% VL53L1X_Function
filePath = fullfile(ProjectPath, 'Simulink', 'Sensor', 'VL53L1X_Function.m');

lineNumber = 168;
newLineContent = sprintf("projectPath = '%s';", ProjectPath); 


fid = fopen(filePath, 'r');
if fid == -1
    error('The file could not be opened: %s', filePath);
end

fileLines = {};
while ~feof(fid)
    fileLines{end+1} = fgetl(fid); 
end
fclose(fid);

if lineNumber > length(fileLines) || lineNumber < 1
    error('Nonexistent Line Number: %d', lineNumber);
end

fileLines{lineNumber} = newLineContent;

fid = fopen(filePath, 'w');
if fid == -1
    error('The file could not be opened: %s', filePath);
end
fprintf(fid, '%s\n', fileLines{:});
fclose(fid);

disp('VL53L1X_Function.m was changed successfully.');

%% MotorShield_Functions

filePath = fullfile(ProjectPath, 'Simulink', 'MotorShield', 'MotorShield_Functions.m');

lineNumber = 163;
newLineContent = sprintf("projectPath = '%s';", ProjectPath); 


fid = fopen(filePath, 'r');
if fid == -1
    error('The file could not be opened: %s', filePath);
end

fileLines = {};
while ~feof(fid)
    fileLines{end+1} = fgetl(fid); 
end
fclose(fid);

if lineNumber > length(fileLines) || lineNumber < 1
    error('Nonexistent Line Number: %d', lineNumber);
end

fileLines{lineNumber} = newLineContent;

fid = fopen(filePath, 'w');
if fid == -1
    error('The file could not be opened: %s', filePath);
end
fprintf(fid, '%s\n', fileLines{:});
fclose(fid);

disp('MotorShield_Functions.m was changed successfully.');

clear fid fileLines filePath lineNumber newLineContent ProjectPath ans;

disp('The IO Device Builder files were changed successfully.')
end