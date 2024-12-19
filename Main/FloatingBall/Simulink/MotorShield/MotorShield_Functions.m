classdef MotorShield_Functions < matlab.System ...
    & coder.ExternalDependency ...
    & matlabshared.sensors.simulink.internal.BlockSampleTime

  % Set Motor Speed
  %#codegen
  %#ok<*EMCA>

  properties

  end

  properties(Access = protected)
    Logo = 'IO Device Builder';
  end

  properties (Nontunable)

  end

  properties (Access = private)


  end

  methods
    % Constructor
    function obj = MotorShield_Functions(varargin)
      setProperties(obj,nargin,varargin{:});
    end
  end

  methods (Access=protected)
    function setupImpl(obj)
      if ~coder.target('MATLAB')
        coder.cinclude('MotorShield_Functions.h');
        coder.ceval('setupFunctionMotorShield_Functions');
      end
    end

    function validateInputsImpl(obj,varargin)
      %  Check the input size
      if nargin ~=0

        validateattributes(varargin{1},{'uint8'},{'2d','size',[1,1]},'','Speed');

      end
    end

    function stepImpl(obj ,Speed)

      if isempty(coder.target)
      else
        coder.ceval('stepFunctionMotorShield_Functions', Speed,1);
      end
    end

    function releaseImpl(obj)
      if isempty(coder.target)
      else

      end
    end
  end

  methods (Access=protected)
    %% Define output properties
    function num = getNumInputsImpl(~)
      num = 1;
    end

    function num = getNumOutputsImpl(~)
      num = 0;
    end

    function varargout = getInputNamesImpl(obj)
      varargout{1} = 'Speed';

    end

    function varargout = getOutputNamesImpl(obj)

    end

    function flag = isOutputSizeLockedImpl(~,~)
      flag = true;
    end

    function varargout = isOutputFixedSizeImpl(~,~)

    end

    function varargout = isOutputComplexImpl(~)

    end

    function varargout = getOutputSizeImpl(~)

    end

    function varargout = getOutputDataTypeImpl(~)

    end

    function maskDisplayCmds = getMaskDisplayImpl(obj)
      outport_label = [];
      num = getNumOutputsImpl(obj);
      if num > 0
        outputs = cell(1,num);
        [outputs{1:num}] = getOutputNamesImpl(obj);
        for i = 1:num
          outport_label = [outport_label 'port_label(''output'',' num2str(i) ',''' outputs{i} ''');' ]; %#ok<AGROW>
        end
      end
      inport_label = [];
      num = getNumInputsImpl(obj);
      if num > 0
        inputs = cell(1,num);
        [inputs{1:num}] = getInputNamesImpl(obj);
        for i = 1:num
          inport_label = [inport_label 'port_label(''input'',' num2str(i) ',''' inputs{i} ''');' ]; %#ok<AGROW>
        end
      end
      icon = 'MotorShield_Functions';
      maskDisplayCmds = [ ...
        ['color(''white'');',...
        'plot([100,100,100,100]*1,[100,100,100,100]*1);',...
        'plot([100,100,100,100]*0,[100,100,100,100]*0);',...
        'color(''blue'');', ...
        ['text(38, 92, ','''',obj.Logo,'''',',''horizontalAlignment'', ''right'');',newline],...
        'color(''black'');'], ...
        ['text(52,50,' [''' ' icon ''',''horizontalAlignment'',''center'');' newline]]   ...
        inport_label ...
        outport_label
        ];
    end

    function sts = getSampleTimeImpl(obj)
      sts = getSampleTimeImpl@matlabshared.sensors.simulink.internal.BlockSampleTime(obj);
    end
  end

  methods (Static, Access=protected)
    function simMode = getSimulateUsingImpl(~)
      simMode = 'Interpreted execution';
    end

    function isVisible = showSimulateUsingImpl
      isVisible = false;
    end
  end

  methods (Static)
    function name = getDescriptiveName(~)
      name = 'MotorShield_Functions';
    end

    function tf = isSupportedContext(~)
      tf = true;
    end

    function updateBuildInfo(buildInfo, context)
projectPath = 'C:\Users\Johannes Sutter\Documents\Floating_Ball_2_0';
      coder.extrinsic('codertarget.targethardware.getTargetHardware');
      hCS = coder.const(getActiveConfigSet(bdroot));
      targetInfo = coder.const(codertarget.targethardware.getTargetHardware(hCS));

      % Added this env variable to fetch the comm libraries required only for Arduino target.
      % The env variable is cleared at the end of
      % "GenerateWrapperMakefile.m" file.
      if contains(targetInfo.TargetName,'arduinotarget')
        setenv('Arduino_ML_Codegen_I2C', 'Y');
      end
      buildInfo.addIncludePaths(fullfile(projectPath,'Simulink', 'MotorShield', 'MotorShield_Files'));
      buildInfo.addIncludePaths(fullfile(projectPath,'Simulink', 'MotorShield', 'MotorShield_Files','Wire'));
      buildInfo.addIncludePaths(fullfile(projectPath,'Simulink', 'MotorShield', 'MotorShield_Files','Wire', 'utility'));
      buildInfo.addIncludePaths(fullfile(projectPath,'Simulink', 'MotorShield', 'MotorShield_Files','utility'));
      buildInfo.addIncludePaths(fullfile(projectPath,'Simulink', 'MotorShield', 'MotorShield_Files','Adafruit_BusIO'));
      buildInfo.addIncludePaths(fullfile(projectPath,'Simulink', 'MotorShield', 'MotorShield_Files','Adafruit_BusIO','examples'));

      buildInfo.addIncludePaths(fullfile(projectPath,'Simulink', 'MotorShield'));
      addSourceFiles(buildInfo,'Adafruit_MotorShield.cpp', fullfile(projectPath,'Simulink', 'MotorShield', 'MotorShield_Files'));
      addSourceFiles(buildInfo,'Wire.cpp', fullfile(projectPath,'Simulink', 'MotorShield', 'MotorShield_Files','Wire'));
      addSourceFiles(buildInfo,'twi.c', fullfile(projectPath,'Simulink', 'MotorShield', 'MotorShield_Files','Wire', 'utility'));
      addSourceFiles(buildInfo,'Adafruit_MS_PWMServoDriver.cpp', fullfile(projectPath,'Simulink', 'MotorShield', 'MotorShield_Files','utility'));
      addSourceFiles(buildInfo,'Adafruit_BusIO_Register.cpp', fullfile(projectPath,'Simulink', 'MotorShield', 'MotorShield_Files','Adafruit_BusIO'));
      addSourceFiles(buildInfo,'Adafruit_I2CDevice.cpp', fullfile(projectPath,'Simulink', 'MotorShield', 'MotorShield_Files','Adafruit_BusIO'));
      addSourceFiles(buildInfo,'Adafruit_SPIDevice.cpp', fullfile(projectPath,'Simulink', 'MotorShield', 'MotorShield_Files','Adafruit_BusIO'));
      addSourceFiles(buildInfo,'MotorShield_Functions.cpp', fullfile(projectPath,'Simulink', 'MotorShield'));

    end
  end
end
