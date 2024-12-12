function ball_motor_gui(arduino)

    Timerupdate = 0.5;
    TimeWindow = 20; 

    % Definition of the default parameters for the different controllers
    regulators = struct( ...
        'MotorControl', struct('P', 1.0, 'I', 0.5, 'D', 0.1, 'n', 1), ...
        'Control', struct('P', 2.0, 'I', 1.0, 'D', 0.2, 'n', 5), ...
        'CascadedControl', struct('P', 0.5, 'I', 0.2, 'D', 0.05, 'n', 2) ...
    );
    currentRegulator = 'MotorControl';

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
    ylim(ax1, [0, 500]);
    
    % Plot for the rotations of the motor
    ax2 = axes('Parent', hFig, 'Position', [0.50, 0.39, 0.45, 0.25]);
    xlabel(ax2, 'time in s');
    ylabel(ax2, 'rotations per minute');
    title(ax2, 'Rotations');
    grid(ax2, 'on');
    hold(ax2, 'on');
    motorSpeedPlot = plot(ax2, NaN, NaN, 'g', 'LineWidth', 2);
    ylim(ax2, [0, 1000]);

    % Plot for the voltage applied to the motor
    ax3 = axes('Parent', hFig, 'Position', [0.50, 0.06, 0.45, 0.25]);
    xlabel(ax3, 'time in s');
    ylabel(ax3, 'U in V');
    title(ax3, 'Motor voltage');
    grid(ax3, 'on');
    hold(ax3, 'on');
    voltagePlot = plot(ax3, NaN, NaN, 'm', 'LineWidth', 2);
    ylim(ax3, [0, 10]);

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
                         'String', {'Motor Control', 'Control', 'Cascaded Control'}, ...
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
    kI_text = uicontrol('Style', 'text', 'Position', [10, 140, 50, 20], 'String', 'kI:', ...
              'HorizontalAlignment', 'right', 'FontSize', 10);
    inputI = uicontrol('Style', 'edit', 'Position', [70, 140, 100, 20], ...
                       'String', num2str(regulators.(currentRegulator).I), ...
                       'Callback', @updateRegulatorParameters);
    inputI_out = uicontrol('Style', 'edit', 'Position', [170, 140, 100, 20], ...
                       'String', num2str(regulators.(currentRegulator).I), ...
                       'Callback', @updateRegulatorParameters);

    % Text field for the D value of the controller
    kD_text = uicontrol('Style', 'text', 'Position', [10, 110, 50, 20], 'String', 'kD:', ...
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

    % Start Button
    uicontrol('Style', 'pushbutton', 'String', 'Start', ...
              'Position', [200, 170, 100, 40], 'Callback', @startCallback);
    % Stop Button
    uicontrol('Style', 'pushbutton', 'String', 'Stop', ...
              'Position', [200, 120, 100, 40], 'Callback', @stopCallback);

    % Set Button to apply the set height
    setButton = uicontrol('Style', 'pushbutton', 'String', 'Set', ...
                      'Position', [290, 300, 50, 20], 'Callback', @applyRefHeight);

    % Save Button
    handles.saveButton = uicontrol('Style', 'pushbutton', 'String', 'Save-data', ...
                                   'Position', [320, 120, 100, 40], 'Callback', @saveData);
    % Save changes button to apply the controller settings
    handles.saveChanges = uicontrol('Style', 'pushbutton', 'String', 'Save-changes', ...
                                   'Position', [200, 70, 100, 40], 'Callback', @updatePID);
    % Build and deploy button
    handles.BuildProgram = uicontrol('Style', 'pushbutton', 'String', 'Build&Deploy', ...
                                   'Position', [320, 70, 100, 40], 'Callback', @BuildProgram);

    % Disable the save and save changes button
    set(handles.saveButton, 'Enable', 'off');
    set(handles.saveChanges, 'Enable', 'off');

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

    function startCallback(~, ~)
        writeline(handles.arduino, num2str(handles.refHeight));
        handles = guidata(hFig);
        handles.isRunning = true;
        start(handles.t);
        set(handles.saveButton, 'Enable', 'off');
        guidata(hFig, handles);
    end
    
    function stopCallback(~, ~)
        writeline(handles.arduino, '0'); %Not to change anymore :)
        flush(handles.arduino);
        handles = guidata(hFig);
        handles.isRunning = false;
        stop(handles.t);
        set(handles.saveButton, 'Enable', 'on');
        guidata(hFig, handles);
    end

    function updateRefHeight(src, ~)
        if handles.isRunning
            writeline(handles.arduino, num2str(handles.refHeight));
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
        guidata(hFig, handles);
    end


    function updateRegulatorSelection(src, ~)
        items = {'MotorControl', 'Control', 'CascadedControl'};
        currentRegulator = items{get(src, 'Value')};
        a = items{get(src, 'Value')};
        if strcmp(a, 'MotorControl')
             set(kP_text, 'Visible', 'off');
             set(inputP, 'Visible', 'off');
             set(inputP_out, 'Visible', 'off');
             set(kI_text, 'Visible', 'off');
             set(inputI, 'Visible', 'off');
             set(inputI_out, 'Visible', 'off');
             set(kD_text, 'Visible', 'off');
             set(inputD, 'Visible', 'off');
             set(inputD_out, 'Visible', 'off');
             set(n_text, 'Visible', 'off');
             set(inputn, 'Visible', 'off');
             set(inputn_out, 'Visible', 'off');
             set(refheight_text, 'Visible', 'off');
             set(inputRefHeight, 'Visible', 'off');
             set(rotation_text, 'Visible', 'on');
             set(inputRotation, 'Visible', 'on');             
        elseif strcmp(a, 'Control')
             set(kP_text, 'Visible', 'on');
             set(inputP, 'Visible', 'on');
             set(inputP_out, 'Visible', 'off');
             set(kI_text, 'Visible', 'on');
             set(inputI, 'Visible', 'on');
             set(inputI_out, 'Visible', 'off');
             set(kD_text, 'Visible', 'on');
             set(inputD, 'Visible', 'on');
             set(inputD_out, 'Visible', 'off');
             set(n_text, 'Visible', 'on');
             set(inputn, 'Visible', 'on');
             set(inputn_out, 'Visible', 'off');
             set(refheight_text, 'Visible', 'on');
             set(inputRefHeight, 'Visible', 'on');
             set(rotation_text, 'Visible', 'off');
             set(inputRotation, 'Visible', 'off');  
        else
             set(kP_text, 'Visible', 'on');
             set(inputP, 'Visible', 'on');
             set(inputP_out, 'Visible', 'on');
             set(kI_text, 'Visible', 'on');
             set(inputI, 'Visible', 'on');
             set(inputI_out, 'Visible', 'on');
             set(kD_text, 'Visible', 'on');
             set(inputD, 'Visible', 'on');
             set(inputD_out, 'Visible', 'on');
             set(n_text, 'Visible', 'on');
             set(inputn, 'Visible', 'on');
             set(inputn_out, 'Visible', 'on');
             set(refheight_text, 'Visible', 'on');
             set(inputRefHeight, 'Visible', 'on');
             set(rotation_text, 'Visible', 'off');
             set(inputRotation, 'Visible', 'off'); 
        end
        updateParameterFields();

    end

    function updatePID(~, ~)
        % Get the current values of P, I, D, and n
        P_value = regulators.(currentRegulator).P;
        I_value = regulators.(currentRegulator).I;
        D_value = regulators.(currentRegulator).D;
        n_value = regulators.(currentRegulator).n;
    end

    function updateParameterFields()
            % Aktualisiere die Werte in den Eingabefeldern basierend auf dem ausgewählten Regler
            set(inputP, 'String', num2str(regulators.(currentRegulator).P));
            set(inputI, 'String', num2str(regulators.(currentRegulator).I));
            set(inputD, 'String', num2str(regulators.(currentRegulator).D));
            set(inputn, 'String', num2str(regulators.(currentRegulator).n));
        end

    function updateRegulatorParameters(~, ~)
        regulators.(currentRegulator).P = str2double(get(inputP, 'String'));
        regulators.(currentRegulator).I = str2double(get(inputI, 'String'));
        regulators.(currentRegulator).D = str2double(get(inputD, 'String'));
        regulators.(currentRegulator).n = str2double(get(inputn, 'String'));
    end
    
    function BuildProgram(~, ~)
        rtwbuild('TU8_4_8') %Simulink name to compile in the arduino
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
