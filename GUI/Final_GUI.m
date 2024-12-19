function ball_motor_gui(arduino)

    Timerupdate = 0.1;
    TimeWindow = 20; 

    % Definition of the default parameters for the different controllers
    regulators = struct( ...
        'PIDControl', struct('P', 2.0, 'I', 1.0, 'D', 0.2, 'n', 5), ...
        'CascadedControl', struct( ...
        'Outer', struct('P', 0.5, 'I', 0.2, 'D', 0.05, 'n', 2), ... % Äußerer Regler
        'Inner', struct('P', 1.0, 'I', 0.5, 'D', 0.1, 'n', 1) ...   % Innerer Regler
        ) ...
    );
    currentRegulator = 'PIDControl';

    % Create the GUI
    hFig = figure('Position', [0, 50, 1500, 750], 'Name', 'Ball and Motor Control', ...
                  'MenuBar', 'none', 'NumberTitle', 'off', 'Resize', 'off');
    
    % Plot for the height of the ball
    ax1 = axes('Parent', hFig, 'Position', [0.50, 0.72, 0.45, 0.25]);
    xlabel(ax1, 'time in s');
    ylabel(ax1, 'height in mm');
    title(ax1, 'Height of the ball');
    grid(ax1, 'on');
    hold(ax1, 'on');
    ballHeightPlot = plot(ax1, NaN, NaN, 'b', 'LineWidth', 2);
    refHeightPlot = plot(ax1, NaN, NaN, 'r--', 'LineWidth', 2);
    ylim(ax1, [0, 10]);
    %ylim(ax1, [0, 500]);
    
    % Plot for the rotations of the motor
    ax2 = axes('Parent', hFig, 'Position', [0.50, 0.39, 0.45, 0.25]);
    xlabel(ax2, 'time in s');
    ylabel(ax2, 'rotations per minute');
    title(ax2, 'Rotations');
    grid(ax2, 'on');
    hold(ax2, 'on');
    motorSpeedPlot = plot(ax2, NaN, NaN, 'g', 'LineWidth', 2);
    ylim(ax2, [0, 10]);
    %ylim(ax2, [0, 1000]);

    % Plot for the voltage applied to the motor
    ax3 = axes('Parent', hFig, 'Position', [0.50, 0.06, 0.45, 0.25]);
    xlabel(ax3, 'time in s');
    ylabel(ax3, 'U in V');
    title(ax3, 'Motor voltage');
    grid(ax3, 'on');
    hold(ax3, 'on');
    voltagePlot = plot(ax3, NaN, NaN, 'm', 'LineWidth', 2);
    ylim(ax3, [0, 10]);
    %ylim(ax3, [0, 10]);

    % Text field for the set height
    rotation_text = uicontrol('Style', 'text', 'Position', [30, 300, 150, 20], 'String', 'Set rotations (rpm):', ...
              'HorizontalAlignment', 'right', 'FontSize', 10);
    inputRotation = uicontrol('Style', 'edit', 'Position', [180, 300, 100, 20], 'String', '200', ...
                               'Callback', @updateRefHeight);

    % Text field for the set height
    refheight_text = uicontrol('Style', 'text', 'Position', [30, 300, 150, 20], 'String', 'Set height (mm):', ...
              'HorizontalAlignment', 'right', 'FontSize', 10);
    inputRefHeight = uicontrol('Style', 'edit', 'Position', [180, 300, 100, 20], 'String', '250', ...
                               'Callback', @updateRefHeight);

    % Drop down menu for the controller selection
    uicontrol('Style', 'text', 'Position', [-50, 648, 200, 40], 'String', 'Select Controller:', ...
              'HorizontalAlignment', 'right', 'FontSize', 12);
    dropdown = uicontrol('Style', 'popupmenu', 'Position', [160, 650, 200, 40], ...
                         'String', {'MotorControl', 'PIDControl', 'CascadedControl'}, ...
                          'FontSize', 12,'Callback', @updateRegulatorSelection);
   
    %Text field for the P value of the controller
    kP_text = uicontrol('Style', 'text', 'Position', [10, 170, 50, 20], 'String', 'kP:', ...
              'HorizontalAlignment', 'right', 'FontSize', 10);
    inputP = uicontrol('Style', 'edit', 'Position', [70, 170, 100, 20], ...
                       'String', num2str(regulators.(currentRegulator).P), ...
                       'Callback', @updateRegulatorParameters);
    inputP_out = uicontrol('Style', 'edit', 'Position', [170, 170, 100, 20], ...
                       'String', num2str(regulators.(currentRegulator).P), ...
                       'Callback', @updateRegulatorParameters);

    % Text field for the I value of the controller
    TI_text = uicontrol('Style', 'text', 'Position', [10, 140, 50, 20], 'String', 'TI:', ...
              'HorizontalAlignment', 'right', 'FontSize', 10);
    inputI = uicontrol('Style', 'edit', 'Position', [70, 140, 100, 20], ...
                       'String', num2str(regulators.(currentRegulator).I), ...
                       'Callback', @updateRegulatorParameters);
    inputI_out = uicontrol('Style', 'edit', 'Position', [170, 140, 100, 20], ...
                       'String', num2str(regulators.(currentRegulator).I), ...
                       'Callback', @updateRegulatorParameters);

    % Text field for the D value of the controller
    TD_text = uicontrol('Style', 'text', 'Position', [10, 110, 50, 20], 'String', 'TD:', ...
              'HorizontalAlignment', 'right', 'FontSize', 10);
    inputD = uicontrol('Style', 'edit', 'Position', [70, 110, 100, 20], ...
                       'String', num2str(regulators.(currentRegulator).D), ...
                       'Callback', @updateRegulatorParameters);
    inputD_out = uicontrol('Style', 'edit', 'Position', [170, 110, 100, 20], ...
                       'String', num2str(regulators.(currentRegulator).D), ...
                       'Callback', @updateRegulatorParameters);

    % Text field for the n value of the D part of the controller
    n_text = uicontrol('Style', 'text', 'Position', [10, 80, 50, 20], 'String', 'n:', ...
              'HorizontalAlignment', 'right', 'FontSize', 10);
    inputn = uicontrol('Style', 'edit', 'Position', [70, 80, 100, 20], ...
                       'String', num2str(regulators.(currentRegulator).n), ...
                       'Callback', @updateRegulatorParameters);
    inputn_out = uicontrol('Style', 'edit', 'Position', [170, 80, 100, 20], ...
                       'String', num2str(regulators.(currentRegulator).n), ...
                       'Callback', @updateRegulatorParameters);

    % Text field for Height Control in the cascaded controller
    HeightControl_text = uicontrol('Style', 'text', 'Position', [155, 190, 100, 20], ...
              'String', 'Height Control', 'HorizontalAlignment', 'right');

    % Text field for Motor Control in the cascaded controller
    MotorControl_text = uicontrol('Style', 'text', 'Position', [55, 190, 100, 20], ...
              'String', 'Motor Control', 'HorizontalAlignment', 'right');

    % Checkbox for the height control in the cascaded controller
    HeightControl = uicontrol('Style', 'checkbox', ...
                   'Position', [210, 210, 50, 30], ...
                   'Callback', @HeightControlCallback);
    
    % Checkbox for the motor control in the cascaded controller
    MotorControl = uicontrol('Style', 'checkbox', ...
                   'Position', [115, 210, 50, 30], ...
                   'Callback', @MotorControlCallback);

    % Start Button
    uicontrol('Style', 'pushbutton', 'String', 'Start', ...
              'Position', [300, 170, 100, 40], 'Callback', @startCallback);
    % Stop Button
    uicontrol('Style', 'pushbutton', 'String', 'Stop', ...
              'Position', [300, 120, 100, 40], 'Callback', @stopCallback);

    % Set Button to apply the set height
    setButton = uicontrol('Style', 'pushbutton', 'String', 'Set', ...
                      'Position', [390, 300, 50, 20], 'Callback', @applyRefHeight);

    % Save Button
    handles.saveButton = uicontrol('Style', 'pushbutton', 'String', 'Save-data', ...
                                   'Position', [450, 120, 100, 40], 'Callback', @saveData);
    % Save changes button to apply the controller settings
    handles.saveChanges = uicontrol('Style', 'pushbutton', 'String', 'Save-changes', ...
                                   'Position', [450, 70, 100, 40], 'Callback', @updatePID);
    % Build and deploy button
    Build_deploy = uicontrol('Style', 'pushbutton', 'String', 'Build&Deploy', ...
                                   'Position', [300, 70, 100, 40],'Visible','off', 'Callback', @BuildProgram);
    % Init button
    Init = uicontrol('Style', 'pushbutton', 'String', 'Init', ...
                                   'Position', [300, 70, 100, 40], 'Callback', @InitProgram);

    % Disable the save and save changes button
    set(handles.saveButton, 'Enable', 'off');

    handles.t = timer('ExecutionMode', 'fixedRate', 'Period', Timerupdate, ...
                      'TimerFcn', @(~, ~) updateData(hFig, arduino));
    handles.isRunning = false;

    handles.ballHeightPlot = ballHeightPlot;
    handles.motorSpeedPlot = motorSpeedPlot;
    handles.voltagePlot = voltagePlot;
    handles.refHeightPlot = refHeightPlot;
    handles.t_data = [];
    handles.ballHeightData = [];
    handles.motorSpeedData = [];
    handles.voltageData = [];
    handles.refHeight = 250;
    handles.P = 1.0;
    handles.I = 0.5;
    handles.D = 0.1;
    handles.arduino = arduino;
    guidata(hFig, handles);

    

    handles.P_ctl_value = 1.0;
    handles.I_ctl_value = 2.5;
    handles.D_ctl_value = 3.3;
    handles.n_ctl_value = 10;
    handles.set_mode = 0; % TODO: Maybe order still needs to be changed
    handles.P_motor_value = 1.50;
    handles.I_motor_value = 2.50;
    handles.D_motor_value = 3.50;
    handles.n_motor_value = 4;



    function startCallback(~, ~)
        %writeline(handles.arduino, num2str(handles.refHeight));
        %Controller Values are multiplied by 1000 to avoid using double (P,I,D)
        Serial_String = horzcat( ...
            num2str(handles.P_motor_value*10),' ',num2str(handles.I_motor_value*10),' ',num2str(handles.D_motor_value*10),' ',num2str(handles.n_motor_value),' ', ...
            num2str(handles.P_ctl_value*10),' ',num2str(handles.I_ctl_value*10),' ',num2str(handles.D_ctl_value*10),' ',num2str(handles.n_ctl_value),' ', ...
            '0',' ',num2str(handles.set_mode),' ',num2str(handles.refHeight),' ','1')
        writeline(handles.arduino, Serial_String);
        %writeline(handles.arduino, "15 45 35 4 55 65 75 8 9 2 3 4");
        handles = guidata(hFig);
        handles.isRunning = true;
        start(handles.t);
        set(handles.saveButton, 'Enable', 'off');
        guidata(hFig, handles);
    end
    
    function stopCallback(~, ~)
        %writeline(handles.arduino, '0'); %Not to change anymore :)
        Serial_String4 = horzcat( ...
            num2str(handles.P_motor_value*10),' ',num2str(handles.I_motor_value*10),' ',num2str(handles.D_motor_value*10),' ',num2str(handles.n_motor_value),' ', ...
            num2str(handles.P_ctl_value*10),' ',num2str(handles.I_ctl_value*10),' ',num2str(handles.D_ctl_value*10),' ',num2str(handles.n_ctl_value),' ', ...
            '0',' ',num2str(handles.set_mode),' ',num2str(handles.refHeight),' ','0')
        writeline(handles.arduino, Serial_String4);
        flush(handles.arduino);
        handles = guidata(hFig);
        handles.isRunning = false;
        stop(handles.t);
        set(handles.saveButton, 'Enable', 'on');
        guidata(hFig, handles);
    end

    function updateRefHeight(src, ~)
        if handles.isRunning
            %writeline(handles.arduino, num2str(handles.refHeight));
        end
        handles = guidata(hFig);
        refHeightMM = str2double(get(src, 'String'));
        if isnan(refHeightMM) || refHeightMM < 0 || refHeightMM > 500
            refHeightMM = 250;
            set(src, 'String', '250');
        end
        guidata(hFig, handles);
    end

    function applyRefHeight(~, ~)
        handles = guidata(hFig);
        refHeightMM = str2double(get(inputRefHeight, 'String'));
        if isnan(refHeightMM) || refHeightMM < 0 || refHeightMM > 500
            refHeightMM = 250; % Standardwert, wenn die Eingabe ungültig ist
            set(inputRefHeight, 'String', '250');
        end
        handles.refHeight = refHeightMM; % Speichern des Referenzwertes
        %writeline(handles.arduino, num2str(handles.refHeight));
             % Get the current values of P, I, D, and n
        if strcmp(currentRegulator, 'CascadedControl')
            handles.P_ctl_value = regulators.(currentRegulator).Outer.P;
            handles.I_ctl_value = regulators.(currentRegulator).Outer.I;
            handles.D_ctl_value = regulators.(currentRegulator).Outer.D;
            handles.n_ctl_value = regulators.(currentRegulator).Outer.n;

            handles.P_motor_value = regulators.(currentRegulator).Inner.P;
            handles.I_motor_value = regulators.(currentRegulator).Inner.I;
            handles.D_motor_value = regulators.(currentRegulator).Inner.D;
            handles.n_motor_value = regulators.(currentRegulator).Inner.n;
            
            handles.set_mode = 0; % TODO: Maybe order still needs to be changed
        elseif strcmp(currentRegulator, 'PIDControl')
            handles.P_motor_value = regulators.(currentRegulator).P;
            handles.I_motor_value = regulators.(currentRegulator).I;
            handles.D_motor_value = regulators.(currentRegulator).D;
            handles.n_motor_value = regulators.(currentRegulator).n;
            handles.set_mode = 1; % TODO: Maybe order still needs to be changed
        else
            handles.set_mode = 2; % TODO: Maybe order still needs to be changed
        end
            %writeline(handles.arduino, "15 45 35 4 55 65 75 8 9 5 6 7");
            Serial_String2 = horzcat( ...
                num2str(handles.P_motor_value*10),' ',num2str(handles.I_motor_value*10),' ',num2str(handles.D_motor_value*10),' ',num2str(handles.n_motor_value),' ', ...
                num2str(handles.P_ctl_value*10),' ',num2str(handles.I_ctl_value*10),' ',num2str(handles.D_ctl_value*10),' ',num2str(handles.n_ctl_value),' ', ...
                '0',' ',num2str(handles.set_mode),' ',num2str(handles.refHeight),' ','1')
            writeline(handles.arduino, Serial_String2);
        guidata(hFig, handles);
    end


    function updateRegulatorSelection(src, ~)
        items = { 'MotorControl','PIDControl', 'CascadedControl'};
        currentRegulator = items{get(src, 'Value')};
        if strcmp(currentRegulator, 'MotorControl')
             set(kP_text, 'Visible', 'off');
             set(inputP, 'Visible', 'off');
             set(inputP_out, 'Visible', 'off');
             set(TI_text, 'Visible', 'off');
             set(inputI, 'Visible', 'off');
             set(inputI_out, 'Visible', 'off');
             set(TD_text, 'Visible', 'off');
             set(inputD, 'Visible', 'off');
             set(inputD_out, 'Visible', 'off');
             set(n_text, 'Visible', 'off');
             set(inputn, 'Visible', 'off');
             set(inputn_out, 'Visible', 'off');
             set(refheight_text, 'Visible', 'off');
             set(inputRefHeight, 'Visible', 'off');
             set(rotation_text, 'Visible', 'on');
             set(inputRotation, 'Visible', 'on'); 
             HeightControl.Visible = 'off';
             MotorControl.Visible =  'off';
             HeightControl_text.Visible = 'off';
             MotorControl_text.Visible = 'off';
        elseif strcmp(currentRegulator, 'PIDControl')
             set(kP_text, 'Visible', 'on');
             set(inputP, 'Visible', 'on');
             set(inputP, 'Enable', 'on');
             set(inputP_out, 'Visible', 'off');
             set(TI_text, 'Visible', 'on');
             set(inputI, 'Visible', 'on');
             set(inputI, 'Enable', 'on');
             set(inputI_out, 'Visible', 'off');
             set(TD_text, 'Visible', 'on');
             set(inputD, 'Visible', 'on');
             set(inputD, 'Enable', 'on');
             set(inputD_out, 'Visible', 'off');
             set(n_text, 'Visible', 'on');
             set(inputn, 'Visible', 'on');
             set(inputn, 'Enable', 'on');
             set(inputn_out, 'Visible', 'off');
             set(refheight_text, 'Visible', 'on');
             set(inputRefHeight, 'Visible', 'on');
             set(rotation_text, 'Visible', 'off');
             set(inputRotation, 'Visible', 'off'); 
             HeightControl.Visible = 'off';
             MotorControl.Visible =  'off';
             HeightControl_text.Visible = 'off';
             MotorControl_text.Visible = 'off';
        else
             set(kP_text, 'Visible', 'on');
             set(inputP, 'Visible', 'on');
             set(inputP_out, 'Visible', 'on');
             set(TI_text, 'Visible', 'on');
             set(inputI, 'Visible', 'on');
             set(inputI_out, 'Visible', 'on');
             set(TD_text, 'Visible', 'on');
             set(inputD, 'Visible', 'on');
             set(inputD_out, 'Visible', 'on');
             set(n_text, 'Visible', 'on');
             set(inputn, 'Visible', 'on');
             set(inputn_out, 'Visible', 'on');
             set(refheight_text, 'Visible', 'on');
             set(inputRefHeight, 'Visible', 'on');
             set(rotation_text, 'Visible', 'off');
             set(inputRotation, 'Visible', 'off'); 
             HeightControl.Visible = 'on';
             MotorControl.Visible =  'on';
             HeightControl_text.Visible = 'on';
             MotorControl_text.Visible = 'on';

             inputP.Enable = 'off';
             inputI.Enable = 'off';
             inputD.Enable = 'off';
             inputn.Enable = 'off';
             inputP_out.Enable = 'off';
             inputI_out.Enable = 'off';
             inputD_out.Enable = 'off';
             inputn_out.Enable = 'off';
             MotorControl.Value = 0;
             HeightControl.Value = 0;
         end
        updateParameterFields();

    end

    function updatePID(~, ~)
        % Get the current values of P, I, D, and n
        if strcmp(currentRegulator, 'CascadedControl')
            handles.P_ctl_value = regulators.(currentRegulator).Outer.P;
            handles.I_ctl_value = regulators.(currentRegulator).Outer.I;
            handles.D_ctl_value = regulators.(currentRegulator).Outer.D;
            handles.n_ctl_value = regulators.(currentRegulator).Outer.n;

            handles.P_motor_value = regulators.(currentRegulator).Inner.P;
            handles.I_motor_value = regulators.(currentRegulator).Inner.I;
            handles.D_motor_value = regulators.(currentRegulator).Inner.D;
            handles.n_motor_value = regulators.(currentRegulator).Inner.n;
            
            handles.set_mode = 0; % TODO: Maybe order still needs to be changed
        elseif strcmp(currentRegulator, 'PIDControl')
            handles.P_motor_value = regulators.(currentRegulator).P;
            handles.I_motor_value = regulators.(currentRegulator).I;
            handles.D_motor_value = regulators.(currentRegulator).D;
            handles.n_motor_value = regulators.(currentRegulator).n;
            handles.set_mode = 1; % TODO: Maybe order still needs to be changed
        else
            handles.set_mode = 2; % TODO: Maybe order still needs to be changed
        end
        Serial_String3 = horzcat( ...
            num2str(handles.P_motor_value*10),' ',num2str(handles.I_motor_value*10),' ',num2str(handles.D_motor_value*10),' ',num2str(handles.n_motor_value),' ', ...
            num2str(handles.P_ctl_value*10),' ',num2str(handles.I_ctl_value*10),' ',num2str(handles.D_ctl_value*10),' ',num2str(handles.n_ctl_value),' ', ...
            '0',' ',num2str(handles.set_mode),' ',num2str(handles.refHeight),' ','1')
        writeline(handles.arduino, Serial_String3);

    end

    function updateParameterFields()
            % Aktualisiere die Werte in den Eingabefeldern basierend auf dem ausgewählten Regler
            if(strcmp(currentRegulator, 'PIDControl'))
            set(inputP, 'String', num2str(regulators.(currentRegulator).P));
            set(inputI, 'String', num2str(regulators.(currentRegulator).I));
            set(inputD, 'String', num2str(regulators.(currentRegulator).D));
            set(inputn, 'String', num2str(regulators.(currentRegulator).n));
            end

            if(strcmp(currentRegulator, 'CascadedControl'))
            set(inputP, 'String', num2str(regulators.(currentRegulator).Inner.P));
            set(inputI, 'String', num2str(regulators.(currentRegulator).Inner.I));
            set(inputD, 'String', num2str(regulators.(currentRegulator).Inner.D));
            set(inputn, 'String', num2str(regulators.(currentRegulator).Inner.n));

            set(inputP_out, 'String', num2str(regulators.(currentRegulator).Outer.P));
            set(inputI_out, 'String', num2str(regulators.(currentRegulator).Outer.I));
            set(inputD_out, 'String', num2str(regulators.(currentRegulator).Outer.D));
            set(inputn_out, 'String', num2str(regulators.(currentRegulator).Outer.n));
            end
        end

    function updateRegulatorParameters(~, ~)
        if(strcmp(currentRegulator, 'PIDControl'))
            regulators.(currentRegulator).P = str2double(get(inputP, 'String'));
            regulators.(currentRegulator).I = str2double(get(inputI, 'String'));
            regulators.(currentRegulator).D = str2double(get(inputD, 'String'));
            regulators.(currentRegulator).n = str2double(get(inputn, 'String'));
        end

        if(strcmp(currentRegulator, 'CascadedControl'))
            regulators.(currentRegulator).Inner.P = str2double(get(inputP, 'String'));
            regulators.(currentRegulator).Inner.I = str2double(get(inputI, 'String'));
            regulators.(currentRegulator).Inner.D = str2double(get(inputD, 'String'));
            regulators.(currentRegulator).Inner.n = str2double(get(inputn, 'String'));

            regulators.(currentRegulator).Outer.P = str2double(get(inputP_out, 'String'));
            regulators.(currentRegulator).Outer.I = str2double(get(inputI_out, 'String'));
            regulators.(currentRegulator).Outer.D = str2double(get(inputD_out, 'String'));
            regulators.(currentRegulator).Outer.n = str2double(get(inputn_out, 'String'));
        end
    end
    
    function BuildProgram(~, ~)
        rtwbuild('FloatingBall') 
    end

    function InitProgram(~, ~)
        IoDeviceBuilder_Setup();
        set(Build_deploy, 'Visible', 'on');
        set(Init, 'Visible', 'off');
     end

    function saveData(~, ~)
        handles = guidata(hFig);
        [file, path] = uiputfile('*.txt', 'Save as');
        if file ~= 0
            data = table(handles.t_data', handles.ballHeightData', handles.motorSpeedData', handles.voltageData', ...
                         'VariableNames', {'time in s', 'Height in mm', 'rotations per minute', 'Voltage (V)'});
            writetable(data, fullfile(path, file), 'Delimiter', '\t');
            disp('Data saved successfully');
        end
    end

    % Callback-Funktion für Height Control
    function HeightControlCallback(src, ~)
        if src.Value == 1 
            MotorControl.Value = 0;
            inputP.Enable = 'off';
            inputI.Enable = 'off';
            inputD.Enable = 'off';
            inputn.Enable = 'off';

            inputP_out.Enable = 'on';
            inputI_out.Enable = 'on';
            inputD_out.Enable = 'on';
            inputn_out.Enable = 'on';

            inputRotation.Visible = 'off';
            rotation_text.Visible = 'off';
            inputRefHeight.Visible = 'on';
            refheight_text.Visible = 'on';
        end
    end

    % Callback-Funktion für Motor Control
    function MotorControlCallback(src, ~)
        if src.Value == 1 
            HeightControl.Value = 0; 
            inputP.Enable = 'on';
            inputI.Enable = 'on';
            inputD.Enable = 'on';
            inputn.Enable = 'on';

            inputP_out.Enable = 'off';
            inputI_out.Enable = 'off';
            inputD_out.Enable = 'off';
            inputn_out.Enable = 'off';

            inputRotation.Visible = 'on';
            rotation_text.Visible = 'on';
            inputRefHeight.Visible = 'off';
            refheight_text.Visible = 'off';
        end
    end



    function updateData(hFig, arduino)
        handles = guidata(hFig);
        while arduino.NumBytesAvailable > 0
            [time, distance, mspeed, voltage] = SingleRead(arduino);
            if isempty(handles.t_data)
                handles.t_data = 0;
                handles.ballHeightData = 0;
                handles.motorSpeedData = 0;
                handles.voltageData = 0;
            else
                handles.t_data(end+1) = time;
                handles.ballHeightData(end+1) = distance;
                handles.motorSpeedData(end+1) = mspeed;
                handles.voltageData(end+1) = voltage;
            end

            if handles.t_data(end) > TimeWindow
                validIndices = handles.t_data >= (handles.t_data(end) - TimeWindow);
                handles.t_data = handles.t_data(validIndices);
                handles.ballHeightData = handles.ballHeightData(validIndices);
                handles.motorSpeedData = handles.motorSpeedData(validIndices);
                handles.voltageData = handles.voltageData(validIndices);
            end
        end

        set(handles.refHeightPlot, 'XData', handles.t_data, 'YData', handles.refHeight * ones(size(handles.t_data)));
        set(handles.ballHeightPlot, 'XData', handles.t_data, 'YData', handles.ballHeightData);
        set(handles.motorSpeedPlot, 'XData', handles.t_data, 'YData', handles.motorSpeedData);
        set(handles.voltagePlot, 'XData', handles.t_data, 'YData', handles.voltageData);

        if handles.t_data(end) > TimeWindow
            xlim(ax1, [handles.t_data(end)-TimeWindow, handles.t_data(end)]);
            xlim(ax2, [handles.t_data(end)-TimeWindow, handles.t_data(end)]);
            xlim(ax3, [handles.t_data(end)-TimeWindow, handles.t_data(end)]);
        else
            xlim(ax1, [0, TimeWindow]);
            xlim(ax2, [0, TimeWindow]);
            xlim(ax3, [0, TimeWindow]);
        end

        guidata(hFig, handles);
    end
end
