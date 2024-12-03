function ball_motor_gui(arduino)
    hFig = figure('Position', [100, 100, 800, 600], 'Name', 'Ball and Motor Control', 'MenuBar', 'none', 'NumberTitle', 'off', 'Resize', 'off');
    ax1 = axes('Parent', hFig, 'Position', [0.1, 0.55, 0.35, 0.4]);
    xlabel(ax1, 'time in s');
    ylabel(ax1, 'heigth in m');
    title(ax1, 'Heigth of the ball');
    grid(ax1, 'on');
    hold(ax1, 'on');
    ballHeightPlot = plot(ax1, NaN, NaN, 'b', 'LineWidth', 2);
    refHeightPlot = plot(ax1, NaN, NaN, 'r--', 'LineWidth', 2);
    ylim(ax1, [0, 0.5]);
    ax2 = axes('Parent', hFig, 'Position', [0.55, 0.55, 0.35, 0.4]);
    xlabel(ax2, 'time in s');
    ylabel(ax2, 'rotations per minute');
    title(ax2, 'Rotations');
    grid(ax2, 'on');
    hold(ax2, 'on');
    motorSpeedPlot = plot(ax2, NaN, NaN, 'g', 'LineWidth', 2);
    ylim(ax2, [0, 10000]);
    voltageText = uicontrol('Style', 'text', 'Position', [600, 160, 160, 30], 'String', 'Voltage: 0 V', 'FontSize', 12, 'BackgroundColor', 'white');
    uicontrol('Style', 'text', 'Position', [30, 220, 150, 20], 'String', 'Set Heigth (mm):', 'HorizontalAlignment', 'right', 'FontSize', 10);
    inputRefHeight = uicontrol('Style', 'edit', 'Position', [180, 220, 100, 20], 'String', '200', 'Callback', @updateRefHeight);
    uicontrol('Style', 'text', 'Position', [10, 120-56, 50, 20], 'String', 'P:', 'HorizontalAlignment', 'right', 'FontSize', 10);
    inputP = uicontrol('Style', 'edit', 'Position', [70, 120-56, 100, 20], 'String', '1.0', 'Callback', @updatePID);
    uicontrol('Style', 'text', 'Position', [10, 90-56, 50, 20], 'String', 'I:', 'HorizontalAlignment', 'right', 'FontSize', 10);
    inputI = uicontrol('Style', 'edit', 'Position', [70, 90-56, 100, 20], 'String', '0.5', 'Callback', @updatePID);
    uicontrol('Style', 'text', 'Position', [10, 60-56, 50, 20], 'String', 'D:', 'HorizontalAlignment', 'right', 'FontSize', 10);
    inputD = uicontrol('Style', 'edit', 'Position', [70, 60-56, 100, 20], 'String', '0.1', 'Callback', @updatePID);
    handles.saveButton = uicontrol('Style', 'pushbutton', 'String', 'Save', 'Position', [600, 50, 100, 40], 'Callback', @saveData);
    set(handles.saveButton, 'Enable', 'off');
    handles.t = timer('ExecutionMode', 'fixedRate', 'Period', 0.1, 'TimerFcn', @(~, ~) updateData(hFig,arduino));
    handles.isRunning = false;
    handles.ballHeightPlot = ballHeightPlot;
    handles.motorSpeedPlot = motorSpeedPlot;
    handles.voltageText = voltageText;
    handles.refHeightPlot = refHeightPlot;
    handles.t_data = [];
    handles.ballHeightData = [];
    handles.motorSpeedData = [];
    handles.voltageData = [];
    handles.refHeight = 0.2;
    handles.P = 1.0;
    handles.I = 0.5;
    handles.D = 0.1;
    guidata(hFig, handles);
    uicontrol('Style', 'pushbutton', 'String', 'Start', 'Position', [180, 60, 100, 40], 'Callback', @startCallback);
    uicontrol('Style', 'pushbutton', 'String', 'Stop', 'Position', [180, 10, 100, 40], 'Callback', @stopCallback);

    function startCallback(~, ~)
        handles = guidata(hFig);
        handles.isRunning = true;
        start(handles.t);
        set(handles.saveButton, 'Enable', 'off');
        guidata(hFig, handles);
    end

    function stopCallback(~, ~)
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
        handles.refHeight = refHeightMM / 1000;
        guidata(hFig, handles);
    end

    function updatePID(~, ~)
        handles = guidata(hFig);
        handles.P = str2double(get(inputP, 'String'));
        handles.I = str2double(get(inputI, 'String'));
        handles.D = str2double(get(inputD, 'String'));
        guidata(hFig, handles);
    end

    function saveData(~, ~)
        handles = guidata(hFig);
        [file, path] = uiputfile('*.txt', 'save as');
        if file ~= 0
            data = table(handles.t_data', handles.ballHeightData', handles.motorSpeedData', 'VariableNames', {'time in s', 'Height in m', 'rotations per minute'});
            writetable(data, fullfile(path, file), 'Delimiter', '\t');
            disp('Data saved sucessfully');
        end
    end

    function updateData(hFig, arduino)
        handles = guidata(hFig);
        try
            [time, distance] = SingleRead(arduino);
        catch
            disp('Serial Communication error');
            return;
        end


        if isempty(handles.t_data)
            handles.t_data = 0;
            handles.ballHeightData = 0;
            handles.motorSpeedData = 0;
        else
            handles.t_data(end+1) = time;
            handles.ballHeightData(end+1) = distance/1000;
            handles.motorSpeedData(end+1) = 2000 + 500 * cos(handles.t_data(end));
        end
        maxPoints = 1000;
        if length(handles.t_data) > maxPoints
            handles.t_data = handles.t_data(end-maxPoints+1:end);
            handles.ballHeightData = handles.ballHeightData(end-maxPoints+1:end);
            handles.motorSpeedData = handles.motorSpeedData(end-maxPoints+1:end);
        end
        set(handles.refHeightPlot, 'XData', handles.t_data, 'YData', handles.refHeight * ones(size(handles.t_data)));
        set(handles.ballHeightPlot, 'XData', handles.t_data, 'YData', handles.ballHeightData);
        set(handles.motorSpeedPlot, 'XData', handles.t_data, 'YData', handles.motorSpeedData);

        timeWindow = 20;



        if handles.t_data(end) > timeWindow
            xlim(handles.ballHeightPlot.Parent, [handles.t_data(end)-timeWindow, handles.t_data(end)]);
            xlim(handles.motorSpeedPlot.Parent, [handles.t_data(end)-timeWindow, handles.t_data(end)]);
        else
            xlim(handles.ballHeightPlot.Parent, [0, timeWindow]);
            xlim(handles.motorSpeedPlot.Parent, [0, timeWindow]);
        end
        voltage = 5;
        set(handles.voltageText, 'String', sprintf('Voltage: %.2f V', voltage));
        guidata(hFig, handles);
    end
end
