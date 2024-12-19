classdef VL53L1X_Function < matlab.System ...
    & coder.ExternalDependency ...
    & matlabshared.sensors.simulink.internal.BlockSampleTime

  % Initialise and read the Sensor. Outputs the distance in mm and an Error bool if initialisation failed.
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
    function obj = VL53L1X_Function(varargin)
      setProperties(obj,nargin,varargin{:});
    end
  end

  methods (Access=protected)
    function setupImpl(obj)
      if ~coder.target('MATLAB')
        coder.cinclude('VL53L1X_Function.h');
        coder.ceval('setupFunctionVL53L1X_Function');
      end
    end

    function validateInputsImpl(obj,varargin)
      %  Check the input size
      if nargin ~=0



      end
    end

    function [Distance,Error] = stepImpl(obj)
      Distance = double(zeros(1,1));
      Error = boolean(zeros(1,1));
      if isempty(coder.target)
      else
        coder.ceval('stepFunctionVL53L1X_Function',coder.ref(Distance),1,coder.ref(Error),1);
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
      num = 0;
    end

    function num = getNumOutputsImpl(~)
      num = 2;
    end

    function varargout = getInputNamesImpl(obj)

    end

    function varargout = getOutputNamesImpl(obj)
      varargout{1} = 'Distance';
      varargout{2} = 'Error';
    end

    function flag = isOutputSizeLockedImpl(~,~)
      flag = true;
    end

    function varargout = isOutputFixedSizeImpl(~,~)
      varargout{1} = true;
      varargout{2} = true;
    end

    function varargout = isOutputComplexImpl(~)
      varargout{1} = false;
      varargout{2} = false;
    end

    function varargout = getOutputSizeImpl(~)
      varargout{1} = [1,1];
      varargout{2} = [1,1];
    end

    function varargout = getOutputDataTypeImpl(~)
      varargout{1} = 'double';
      varargout{2} = 'boolean';
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
      icon = 'VL53L1X_Function';
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
      name = 'VL53L1X_Function';
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


      buildInfo.addIncludePaths(fullfile(projectPath,'Simulink', 'Sensor', 'Sensor_Files'));
      buildInfo.addIncludePaths(fullfile(projectPath,'Simulink', 'Sensor', 'Sensor_Files', 'utility'));

      buildInfo.addIncludePaths(fullfile(projectPath,'Simulink', 'Sensor'));
      addSourceFiles(buildInfo,'VL53L1X.cpp', fullfile(projectPath,'Simulink', 'Sensor', 'Sensor_Files'));
      addSourceFiles(buildInfo,'VL53L1X_Function.cpp',fullfile(projectPath,'Simulink', 'Sensor'));
    end
  end
end
