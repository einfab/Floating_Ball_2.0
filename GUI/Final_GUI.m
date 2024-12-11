function ball_motor_gui(arduino)

    Timerupdate = 0.2;
    TimeWindow = 20; 

    hFig = figure('Position', [100, 100, 950, 750], 'Name', 'Ball and Motor Control', ...
                  'MenuBar', 'none', 'NumberTitle', 'off', 'Resize', 'off');
    
    ax1 = axes('Parent', hFig, 'Position', [0.1, 0.55, 0.35, 0.4]);
    xlabel(ax1, 'time in s');
    ylabel(ax1, 'height in mm');
    title(ax1, 'Height of the ball');
    grid(ax1, 'on');
    hold(ax1, 'on');
    ballHeightPlot = plot(ax1, NaN, NaN, 'b', 'LineWidth', 2);
    refHeightPlot = plot(ax1, NaN, NaN, 'r--', 'LineWidth', 2);
    ylim(ax1, [0, 500]);
    
    ax2 = axes('Parent', hFig, 'Position', [0.55, 0.55, 0.35, 0.4]);
    xlabel(ax2, 'time in s');
    ylabel(ax2, 'rotations per minute');
    title(ax2, 'Rotations');
    grid(ax2, 'on');
    hold(ax2, 'on');
    motorSpeedPlot = plot(ax2, NaN, NaN, 'g', 'LineWidth', 2);
    ylim(ax2, [0, 10000]);

    ax3 = axes('Parent', hFig, 'Position', [0.55, 0.06, 0.35, 0.4]);
    xlabel(ax3, 'time in s');
    ylabel(ax3, 'U in V');
    title(ax3, 'Motor voltage');
    grid(ax3, 'on');
    hold(ax3, 'on');
    voltagePlot = plot(ax3, NaN, NaN, 'm', 'LineWidth', 2);
    ylim(ax3, [0, 10]);

    uicontrol('Style', 'text', 'Position', [30, 300, 150, 20], 'String', 'Set height (mm):', ...
              'HorizontalAlignment', 'right', 'FontSize', 10);
    inputRefHeight = uicontrol('Style', 'edit', 'Position', [180, 300, 100, 20], 'String', '200', ...
                               'Callback', @updateRefHeight);

    uicontrol('Style', 'text', 'Position', [10, 170, 50, 20], 'String', 'kP:', ...
              'HorizontalAlignment', 'right', 'FontSize', 10);
    inputP = uicontrol('Style', 'edit', 'Position', [70, 170, 100, 20], 'String', '1.0', ...
                       'Callback', @updatePID);
    uicontrol('Style', 'text', 'Position', [10, 140, 50, 20], 'String', 'kI:', ...
              'HorizontalAlignment', 'right', 'FontSize', 10);
    inputI = uicontrol('Style', 'edit', 'Position', [70, 140, 100, 20], 'String', '0.5', ...
                       'Callback', @updatePID);
    uicontrol('Style', 'text', 'Position', [10, 110, 50, 20], 'String', 'kD:', ...
              'HorizontalAlignment', 'right', 'FontSize', 10);
    inputD = uicontrol('Style', 'edit', 'Position', [70, 110, 100, 20], 'String', '0.1', ...
                       'Callback', @updatePID);
    uicontrol('Style', 'text', 'Position', [10, 80, 50, 20], 'String', 'n:', ...
              'HorizontalAlignment', 'right', 'FontSize', 10);
    inputn = uicontrol('Style', 'edit', 'Position', [70, 80, 100, 20], 'String', '1', ...
                       'Callback', @updatePID);

    uicontrol('Style', 'pushbutton', 'String', 'Start', ...
              'Position', [200, 170, 100, 40], 'Callback', @startCallback);
    uicontrol('Style', 'pushbutton', 'String', 'Stop', ...
              'Position', [200, 120, 100, 40], 'Callback', @stopCallback);
    handles.saveButton = uicontrol('Style', 'pushbutton', 'String', 'Save-data', ...
                                   'Position', [320, 120, 100, 40], 'Callback', @saveData);
    handles.saveChanges = uicontrol('Style', 'pushbutton', 'String', 'Save-changes', ...
                                   'Position', [200, 70, 100, 40], 'Callback', @updatePID);
    handles.BuildProgram = uicontrol('Style', 'pushbutton', 'String', 'Build&Deploy', ...
                                   'Position', [320, 70, 100, 40], 'Callback', @BuildProgram);

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
    handles.refHeight = 200;
    handles.P = 1.0;
    handles.I = 0.5;
    handles.D = 0.1;
    handles.arduino = arduino;
    guidata(hFig, handles);

    function startCallback(~, ~)
        writeline(handles.arduino, "Start");
        handles = guidata(hFig);
        handles.isRunning = true;
        start(handles.t);
        set(handles.saveButton, 'Enable', 'off');
        guidata(hFig, handles);
    end

    function stopCallback(~, ~)
        writeline(handles.arduino, "Stop");
        flush(handles.arduino);
        handles = guidata(hFig);
        handles.isRunning = false;
        stop(handles.t);
        set(handles.saveButton, 'Enable', 'on');
        guidata(hFig, handles);
    end

    function updateRefHeight(src, ~)
        handles = guidata(hFig);
        refHeightMM = str2double(get(src, 'String'));
        if isnan(refHeightMM) || refHeightMM < 0 || refHeightMM > 500
            refHeightMM = 200;
            set(src, 'String', '200');
        end
        handles.refHeight = refHeightMM;
        guidata(hFig, handles);
    end

    function updatePID(~, ~)
        handles = guidata(hFig);
        handles.P = str2double(get(inputP, 'String'));
        handles.I = str2double(get(inputI, 'String'));
        handles.D = str2double(get(inputD, 'String'));
        guidata(hFig, handles);
    end
    
    function BuildProgram(~, ~)
        rtwbuild('TU8_4_8')
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
            [time, distance] = SingleRead(arduino);
            if isempty(handles.t_data)
                handles.t_data = 0;
                handles.ballHeightData = 0;
                handles.motorSpeedData = 0;
                handles.voltageData = 0;
            else
                handles.t_data(end+1) = time;
                handles.ballHeightData(end+1) = distance;
                handles.motorSpeedData(end+1) = 2000 + 500 * cos(handles.t_data(end));
                handles.voltageData(end+1) = 5 + 2 * sin(handles.t_data(end));
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
