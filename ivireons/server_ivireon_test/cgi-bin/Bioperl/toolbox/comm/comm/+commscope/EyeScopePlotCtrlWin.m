classdef EyeScopePlotCtrlWin < hgsetget & imported.commgui.abstractGUI
    %EyeScopePlotCtrlWin Construct a plot controls window manager for EyeScope
    %
    %   Warning: This undocumented function may be removed in a future release.
    
    % Copyright 2008 The MathWorks, Inc.
    % $Revision: 1.1.6.5 $  $Date: 2009/01/05 17:45:16 $
    
    %===========================================================================
    % Private properties
    properties (SetAccess = private, GetAccess = private)
        EyeObj              % The handle of the eye diagram object this GUI
        % controls.  This is the active (selected) eye
        % object of the single eye diagram view.
        MainGuiHandle       % Handle of the eye diagram GUI object
        
        MainGuiListener     % Listener for the main GUI window
        Rendered = false    % Flag to determine if the window is rendered
        WidgetHandles
    end
    
    %===========================================================================
    % Public methods
    methods
        function this = EyeScopePlotCtrlWin(hGui, eyeObj)
            % Constructor for the plot control window object
            
            % Store the handle of the eye diagram object.  Note that since this
            % is the handle, all the changs we make to the EyeObj will be
            % reflected in the original eye diagram object.
            this.EyeObj = eyeObj;
            
            % Store the handle to the main GUI window
            this.MainGuiHandle = hGui;
            
            % Add listener to the main GUI window.  If the main GUI is closed,
            % we should close this window too.
            addlistener(hGui, 'ObjectBeingDestroyed', ...
                @(src,evnt)mainGuiListener(this));
        end
        
        %-----------------------------------------------------------------------
        function render(this)
            % Render the plot controls window
            
            % Get size and spacing information
            labels = {'Plot type:', ...
                'Color scale:', ...
                'Minimum plot PDF range:', ...
                'Maximum plot PDF range:', ...
                'Plot time offset (s):'};
            sz = guiSizes(this, labels);
            
            % Create the window
            hFig = figure('Position', [0 0 sz.WindowWidth sz.WindowHeight],...
                'CreateFcn', {@movegui,'center'},...
                'Color', get(0, 'defaultuicontrolbackgroundcolor'),...
                'IntegerHandle', 'off',...
                'MenuBar', 'none',...
                'Name', 'Eye Diagram Plot Controls',...
                'NumberTitle', 'off',...
                'Resize', 'off',...
                'NextPlot', 'new',...
                'HandleVisibility', 'on',...
                'Tag', 'ManageWindow',...
                'Visible', 'on');
            this.Parent = hFig;

            % Store the handle to the main GUI window
            setappdata(hFig, 'GuiObject', this.MainGuiHandle);
            
            activeEyeObj = this.EyeObj;
            if isempty(activeEyeObj)
                noObject = 1;
                enableFlag = 'off';
            else
                noObject = 0;
                enableFlag = 'on';
            end
            
            % Plot type label
            height = sz.lh;
            width = sz.PlotTypeLabelWidth;
            x = sz.PlotTypeLabelX;
            y = sz.PlotTypeLabelY;
            handles.PlotTypeLabel = uicontrol(...
                'Parent', hFig,...
                'FontSize', get(0,'defaultuicontrolFontSize'),...
                'HorizontalAlignment', 'left',...
                'Position', [x y width height],...
                'String', 'Plot type:',...
                'Style', 'text',...
                'Tag', 'PlotTypeLabel');
            
            % Plot type popup menu
            height = sz.lh;
            width = sz.PlotTypeWidth;
            x = sz.PlotTypeX;
            y = sz.PlotTypeY;
            
            % Get the Plot Type strings and current value
            [value enumTypeStrings] = getPlotTypeStringIndex(activeEyeObj);
            handles.PlotType = uicontrol(...
                'Parent',hFig,...
                'Callback',{@(hsrc,edata)pucbPlotType(hsrc,this)},...
                'FontSize',get(0,'defaultuicontrolFontSize'),...
                'HorizontalAlignment','right',...
                'Position', [x y width height],...
                'String', enumTypeStrings,...
                'Value', value,...
                'BackgroundColor',[1 1 1],...
                'Style','popupmenu',...
                'Tag','PlotType', ...
                'Enable', enableFlag);
            
            % Color scale label
            height = sz.lh;
            width = sz.ColorScaleLabelWidth;
            x = sz.ColorScaleLabelX;
            y = sz.ColorScaleLabelY;
            
            handles.ColorScaleLabel = uicontrol(...
                'Parent', hFig,...
                'FontSize', get(0,'defaultuicontrolFontSize'),...
                'HorizontalAlignment', 'left',...
                'Position', [x y width height],...
                'String', 'Color scale:',...
                'Style', 'text',...
                'Tag', 'ColorScaleLabel');
            
            % Color scale popup menu
            height = sz.lh;
            width = sz.ColorScaleWidth;
            x = sz.ColorScaleX;
            y = sz.ColorScaleY;
            % Get the Color Scale strings and current value
            [value enumTypeStrings] = getColorScaleStringIndex(activeEyeObj);
            handles.ColorScale = uicontrol(...
                'Parent',hFig,...
                'Callback',{@(hsrc,edata)pucbColorScale(hsrc,this)},...
                'FontSize',get(0,'defaultuicontrolFontSize'),...
                'HorizontalAlignment','right',...
                'Position', [x y width height],...
                'String', enumTypeStrings,...
                'Value', value,...
                'BackgroundColor',[1 1 1],...
                'Style','popupmenu',...
                'Tag','ColorScale', ...
                'Enable', enableFlag);
            
            % Plot time offset label
            height = sz.lh;
            width = sz.PlotTimeOffsetLabelWidth;
            x = sz.PlotTimeOffsetLabelX;
            y = sz.PlotTimeOffsetLabelY;
            handles.PlotTimeOffsetLabel = uicontrol(...
                'Parent', hFig,...
                'FontSize', get(0,'defaultuicontrolFontSize'),...
                'HorizontalAlignment', 'left',...
                'Position', [x y width height],...
                'String', 'Plot time offset (s):',...
                'Style', 'text',...
                'Tag', 'PlotTimeOffsetLabel');
            
            % Plot time offset edit box
            height = sz.lh;
            width = sz.PlotTimeOffsetWidth;
            x = sz.PlotTimeOffsetX;
            y = sz.PlotTimeOffsetY;
            if noObject
                value = 0;
            else
                value = num2str(activeEyeObj.PlotTimeOffset);
            end
            handles.PlotTimeOffset = uicontrol(...
                'Parent',hFig,...
                'Callback',{@(hsrc,edata)ebcbPlotTimeOffset(hsrc,this)}, ...
                'FontSize',get(0,'defaultuicontrolFontSize'),...
                'HorizontalAlignment','right',...
                'Position', [x y width height],...
                'String', value,...
                'BackgroundColor',[1 1 1],...
                'Style','edit',...
                'Tag','PlotTimeOffset', ...
                'Enable', enableFlag);
            
            % Minimum plot PDF range label
            height = sz.lh;
            width = sz.MinPlotPDFLabelWidth;
            x = sz.MinPlotPDFLabelX;
            y = sz.MinPlotPDFLabelY;
            handles.MinPlotPDFLabel = uicontrol(...
                'Parent', hFig,...
                'FontSize', get(0,'defaultuicontrolFontSize'),...
                'HorizontalAlignment', 'left',...
                'Position', [x y width height],...
                'String', 'Minimum plot PDF range:',...
                'Style', 'text',...
                'Tag', 'MinPlotPDFLabel');
            
            % Minimum plot PDF range
            height = sz.lh;
            width = sz.MinPlotPDFWidth;
            x = sz.MinPlotPDFX;
            y = sz.MinPlotPDFY;
            if noObject
                value = 0;
            else
                value = num2str(activeEyeObj.PlotPDFRange(1));
            end
            handles.MinPlotPDF = uicontrol(...
                'Parent',hFig,...
                'Callback',{@(hsrc,edata)ebcbPlotPDFRange(hsrc,this,1)},...
                'FontSize',get(0,'defaultuicontrolFontSize'),...
                'HorizontalAlignment','right',...
                'Position', [x y width height],...
                'String', value,...
                'BackgroundColor',[1 1 1],...
                'Style','edit',...
                'Tag','MinPlotPDF', ...
                'Enable', enableFlag);
            
            % Maximum plot PDF range label
            height = sz.lh;
            width = sz.MaxPlotPDFLabelWidth;
            x = sz.MaxPlotPDFLabelX;
            y = sz.MaxPlotPDFLabelY;
            handles.MaxPlotPDFLabel = uicontrol(...
                'Parent', hFig,...
                'FontSize', get(0,'defaultuicontrolFontSize'),...
                'HorizontalAlignment', 'left',...
                'Position', [x y width height],...
                'String', 'Maximum plot PDF range:',...
                'Style', 'text',...
                'Tag', 'MaxPlotPDFLabel');
            
            % Maximum plot PDF range
            height = sz.lh;
            width = sz.MaxPlotPDFWidth;
            x = sz.MaxPlotPDFX;
            y = sz.MaxPlotPDFY;
            if noObject
                value = 0;
            else
                value = num2str(activeEyeObj.PlotPDFRange(2));
            end
            handles.MaxPlotPDF = uicontrol(...
                'Parent',hFig,...
                'Callback',{@(hsrc,edata)ebcbPlotPDFRange(hsrc,this,2)},...
                'FontSize',get(0,'defaultuicontrolFontSize'),...
                'HorizontalAlignment','right',...
                'Position', [x y width height],...
                'String', value,...
                'BackgroundColor',[1 1 1],...
                'Style','edit',...
                'Tag','MaxPlotPDF', ...
                'Enable', enableFlag);
            
            % Plot time offset slider bar
            height = sz.lh;
            x = sz.PlotTimeSliderX;
            width = sz.PlotTimeSliderWidth;
            y = sz.PlotTimeSliderY;
            
            [value maxTimeOffset sliderSteps] = calcSliderSettings(this);
            handles.PlotTimeOffsetSlider = uicontrol(...
                'Parent',hFig,...
                'Units','pixels',...
                'BackgroundColor',[0.9 0.9 0.9],...
                'Callback',{@(hsrc,edata)ebcbPlotTimeOffsetSlider(hsrc,this)},...
                'FontSize',get(0,'defaultuicontrolFontSize'),...
                'Position', [x y width height],...
                'Value', value,...
                'Min', -maxTimeOffset,...
                'Max', maxTimeOffset,...
                'SliderStep', sliderSteps,...
                'Style','slider',...
                'Tag','PlotTimeOffsetSlider', ...
                'Interruptible', 'off', ...
                'Enable', enableFlag);
            
            % Plot time offset slider bar left label
            height = sz.lh;
            x = sz.PlotTimeSliderLLX;
            minValue = get(handles.PlotTimeOffsetSlider, 'Min');
            [y e u] = engunits(minValue);
            minValueStr = sprintf('%d (%ss)', y, u);
            width = largestuiwidth({minValueStr});
            y = sz.PlotTimeSliderLLY;
            handles.PlotTimeOffsetSliderLL = uicontrol(...
                'Parent',hFig,...
                'FontSize',get(0,'defaultuicontrolFontSize'),...
                'Position', [x y width height],...
                'String', minValueStr,...
                'Style','text',...
                'Tag','PlotTimeOffsetSliderLL');
            
            % Plot time offset slider bar right label
            height = sz.lh;
            maxValue = get(handles.PlotTimeOffsetSlider, 'Max');
            [y e u] = engunits(maxValue);
            maxValueStr = sprintf('%d (%ss)', y, u);
            width = largestuiwidth({maxValueStr});
            x = sz.PlotTimeSliderRLX - width;
            y = sz.PlotTimeSliderRLY;
            handles.PlotTimeOffsetSliderRL = uicontrol(...
                'Parent',hFig,...
                'FontSize',get(0,'defaultuicontrolFontSize'),...
                'Position', [x y width height],...
                'String', maxValueStr,...
                'Style','text',...
                'Tag','PlotTimeOffsetSliderRL');
            
            % Store the widget handles
            this.WidgetHandles = handles;
            
            % Enable/disable plot controls based on plot type
            if ~noObject
                updatePlotCtrlAccess(this)
            end
            
            this.Rendered = true;
            
            addlistener(hFig, ...
                'ObjectBeingDestroyed', @(src,evnt)selfListener(this));
        end
    
    %-----------------------------------------------------------------------
    function update(this, eyeObj)
        % Update the plot controls window
        
        % Save the handle of the eye diagram object
        this.EyeObj = eyeObj;
        
        % First check if the plot control window is rendered
        if this.Rendered
            
            if isempty(eyeObj)
                noObject = 1;
                enableFlag = 'off';
            else
                noObject = 0;
                enableFlag = 'on';
            end
            
            if isRendered(this)
                % Get the widget handles
                handles = this.WidgetHandles;
                
                value = getColorScaleStringIndex(eyeObj);
                set(handles.ColorScale, 'Enable', enableFlag);
                set(handles.ColorScale, 'Value', value);
                
                % Plot time offset edit box
                if noObject
                    value = 0;
                else
                    value = num2str(eyeObj.PlotTimeOffset);
                end
                set(handles.PlotTimeOffset, 'Enable', enableFlag);
                set(handles.PlotTimeOffset, ...
                    'String', value);
                
                % Minimum plot PDF range
                if noObject
                    value = 0;
                else
                    value = num2str(eyeObj.PlotPDFRange(1));
                end
                set(handles.MinPlotPDF, 'Enable', enableFlag);
                set(handles.MinPlotPDF, 'String', value);
                
                % Maximum plot PDF range
                if noObject
                    value = 0;
                else
                    value = num2str(eyeObj.PlotPDFRange(2));
                end
                set(handles.MaxPlotPDF, 'Enable', enableFlag);
                set(handles.MaxPlotPDF, 'String', value);
                
                % Plot time offset slider bar
                [value maxTimeOffset sliderSteps] = calcSliderSettings(this);
                set(handles.PlotTimeOffsetSlider, 'Enable', enableFlag);
                set(handles.PlotTimeOffsetSlider, ...
                    'Value', value,...
                    'Min', -maxTimeOffset,...
                    'Max', maxTimeOffset,...
                    'SliderStep', sliderSteps);
                
                % Update slider bar left label
                minValue = get(handles.PlotTimeOffsetSlider, 'Min');
                [y e u] = engunits(minValue);
                minValueStr = sprintf('%d (%ss)', y, u);
                pos = get(handles.PlotTimeOffsetSliderLL, 'Position');
                width = largestuiwidth({minValueStr});
                pos(3) = width;
                set(handles.PlotTimeOffsetSliderLL, ...
                    'Position', pos,...
                    'String', minValueStr);
                
                % Update slider bar right label
                maxValue = get(handles.PlotTimeOffsetSlider, 'Max');
                [y e u] = engunits(maxValue);
                maxValueStr = sprintf('%d (%ss)', y, u);
                pos = get(handles.PlotTimeOffsetSliderRL, 'Position');
                width = largestuiwidth({maxValueStr});
                pos(3) = width;
                set(handles.PlotTimeOffsetSliderRL, ...
                    'Position', pos,...
                    'String', maxValueStr);
                
                % Plot type popup menu.  Since this choice effects enabling of other
                % widgets, do this last
                value = getPlotTypeStringIndex(eyeObj);
                set(handles.PlotType, 'Enable', enableFlag);
                set(handles.PlotType, 'Value', value);
                
                if ~isempty(eyeObj)
                    % Enable/disable plot controls based on plot type
                    updatePlotCtrlAccess(this)
                end
            end
        end
    end
    
    %-----------------------------------------------------------------------
    function bringToFront(this)
        % Bring the figure window to the front
        figure(this.Parent)
    end
    
    %-----------------------------------------------------------------------
    function close(this)
        % Close the plot controls window
        close(this.Parent)
        this.Rendered = false;
    end
    
    %-----------------------------------------------------------------------
    function flag = isRendered(this)
        flag = this.Rendered;
    end
    end
    
    %===========================================================================
    % Private methods
    methods
        function sz = guiSizes(this, labels)
            %guiSizes Get sizes for the plot control window.
            
            % Get the standard size information and add eye scope specific sizing
            sz = baseGuiSizes(this);
            
            % Set the font parameters
            sz = setFontParams(this, sz);
            
            % Determine required height
            height = 2*sz.vcf + 7*sz.lh + 6*sz.vcc + (sz.vcc + sz.sbTweak);
            
            % Determine required width
            labelWidth = largestuiwidth(labels);
            width = round(labelWidth*1.8) + 2*sz.hcf + sz.hel;
            boxWidth = round(labelWidth*1.8) - labelWidth;
            
            % Set window size
            sz.WindowWidth = width;
            sz.WindowHeight = height;
            
            % Determine slider bar and label locations
            sz.PlotTimeSliderLLX = sz.hcf;
            sz.PlotTimeSliderLLY = sz.vcf;
            sz.PlotTimeSliderRLX = sz.WindowWidth - sz.hcf;
            sz.PlotTimeSliderRLY = sz.vcf;
            % RLX will be determined based on the size of the label during
            % rendering
            sz.PlotTimeSliderX = sz.PlotTimeSliderLLX;
            sz.PlotTimeSliderY = sz.PlotTimeSliderLLY ...
                + sz.vcc + sz.sbTweak + sz.lh;
            sz.PlotTimeSliderWidth = sz.WindowWidth - 2*sz.hcf;
            
            % Determine plot time offset text box location
            sz.PlotTimeOffsetWidth = boxWidth;
            sz.PlotTimeOffsetY = sz.PlotTimeSliderY...
                + sz.lh + sz.vcc;
            sz.PlotTimeOffsetLabelX = sz.PlotTimeSliderLLX;
            sz.PlotTimeOffsetX = sz.PlotTimeOffsetLabelX + labelWidth + sz.hel;
            sz.PlotTimeOffsetLabelWidth = width;
            sz.PlotTimeOffsetLabelY = sz.PlotTimeOffsetY;
            
            % Determine maximum plot pdf range location
            sz.MaxPlotPDFWidth = boxWidth;
            sz.MaxPlotPDFY = sz.PlotTimeOffsetLabelY...
                + sz.lh + sz.vcc;
            sz.MaxPlotPDFLabelX = sz.PlotTimeSliderLLX;
            sz.MaxPlotPDFX = sz.MaxPlotPDFLabelX + labelWidth + sz.hel;
            sz.MaxPlotPDFLabelWidth = width;
            sz.MaxPlotPDFLabelY = sz.MaxPlotPDFY;
            
            % Determine minimum plot pdf range location
            sz.MinPlotPDFWidth = boxWidth;
            sz.MinPlotPDFY = sz.MaxPlotPDFLabelY...
                + sz.lh + sz.vcc;
            sz.MinPlotPDFLabelX = sz.PlotTimeSliderLLX;
            sz.MinPlotPDFX = sz.MinPlotPDFLabelX + labelWidth + sz.hel;
            sz.MinPlotPDFLabelWidth = width;
            sz.MinPlotPDFLabelY = sz.MinPlotPDFY;
            
            % Determine color scale location
            sz.ColorScaleWidth = boxWidth;
            sz.ColorScaleLabelY = sz.MinPlotPDFLabelY...
                + sz.lh + sz.vcc;
            sz.ColorScaleY = sz.ColorScaleLabelY + sz.lblTweak;
            sz.ColorScaleLabelX = sz.PlotTimeSliderLLX;
            sz.ColorScaleX = sz.ColorScaleLabelX + labelWidth + sz.hel;
            sz.ColorScaleLabelWidth = width;
            
            % Determine plot type location
            sz.PlotTypeWidth = boxWidth;
            sz.PlotTypeLabelY = sz.ColorScaleLabelY...
                + sz.lh + sz.vcc + sz.lblTweak;
            sz.PlotTypeY = sz.PlotTypeLabelY + sz.lblTweak;
            sz.PlotTypeLabelX = sz.PlotTimeSliderLLX;
            sz.PlotTypeX = sz.PlotTypeLabelX + labelWidth + sz.hel;
            sz.PlotTypeLabelWidth = width;
        end
        
        %-----------------------------------------------------------------------
        function mainGuiListener(this)
            % Listener function for main GUI window close event.  Close this
            % window too.
            if isRendered(this)
                close(this.Parent)
            end
        end
        
        %-----------------------------------------------------------------------
        function selfListener(this)
            % Listener function for self figure window close event.  Set
            % rendered to false.
            this.Rendered = false;
        end
        
        %-----------------------------------------------------------------------
        function updatePlotCtrlAccess(this)
            %UPDATEPLOTCTRLACCESS Update plot control access settings
            %   UPDATEPLOTCTRLACCESS(H) enables or disables plot controls based
            %   on the selected plot type.
            
            % Get the handles
            handles = this.WidgetHandles;
            selectionIdx = get(handles.PlotType, 'Value');
            options = get(handles.PlotType, 'String');
            
            % Disable/enable plot controls based on the selection
            switch options{selectionIdx}
                case '2D Color'
                    % Enable all
                    set(handles.ColorScale, 'Enable', 'on');
                    set(handles.MinPlotPDF, 'Enable', 'on');
                    set(handles.MaxPlotPDF, 'Enable', 'on');
                    
                case '3D Color'
                    % Enable ColorScale
                    set(handles.ColorScale, 'Enable', 'on');
                    % Disable PlotPDFRange
                    set(handles.MinPlotPDF, 'Enable', 'off');
                    set(handles.MaxPlotPDF, 'Enable', 'off');
                    
                case '2D Line'
                    % Disable all
                    set(handles.ColorScale, 'Enable', 'off');
                    set(handles.MinPlotPDF, 'Enable', 'off');
                    set(handles.MaxPlotPDF, 'Enable', 'off');
            end
        end
        
        %-----------------------------------------------------------------------
        function [value maxTimeOffset sliderSteps] = calcSliderSettings(this)
            %CALCSLIDERSETTINGS <short description>
            %   OUT = CALCSLIDERSETTINGS(ARGS) <long description>
            
            activeEyeObj = this.EyeObj;
            if isempty(activeEyeObj)
                value = 0;
                maxTimeOffset = 0.5;
                Fs = 1;
            else
                maxTimeOffset = activeEyeObj.SymbolsPerTrace...
                    /activeEyeObj.SymbolRate / 2;
                Fs = activeEyeObj.SamplingFrequency;
                value = activeEyeObj.PlotTimeOffset;
            end
            
            sliderSteps = [1/(Fs*2*maxTimeOffset) 10/(Fs*2*maxTimeOffset)];
        end
        
    end % methods
    %---------------------------------------------------------------------------
end % classdef

%===============================================================================
% Helper/Callback functions

function pucbPlotType(hsrc, hPlotCtrl)
% Callback function for the plot type popup menu

% Get the options and selection index
options = get(hsrc, 'String');
selectionIdx = get(hsrc, 'Value');

% Get the active eye diagram object
activeEyeObj = hPlotCtrl.EyeObj;

% Get the main GUI handle
hGui = hPlotCtrl.MainGuiHandle;

% If the selection has not changed, proceed
if ~strcmp(activeEyeObj.PlotType, options{selectionIdx})
    % Set the eye diagram object PlotType property
    try
        % Store the previous value and set to the new value.  We will return to
        % the previous value if an error occurs.
        prevValue = get(activeEyeObj, 'PlotType');
        set(activeEyeObj, 'PlotType', options{selectionIdx});
        
        % Enable/disable plot controls based on plot type
        updatePlotCtrlAccess(hPlotCtrl)
        
        % Update the axes width to fit 3D and 2D figures properly
        updateAxesWidth(hGui.SingleEyeScopeFace);
        
        % Indicate that the scope is dirty, i.e. a property has changed
        set(hGui, 'Dirty', 1);
    catch me
        % Reset to the previous value
        set(activeEyeObj, 'PlotType', prevValue);
        idx = getPlotTypeStringIndex(activeEyeObj);
        set(hsrc, 'Value', idx);
        commscope.notifyError(hPlotCtrl.Parent, me);
    end
end
end
%-------------------------------------------------------------------------------
function pucbColorScale(hsrc, hPlotCtrl)
% Callback function for the color scale popup menu

% Get the options and selection index
options = get(hsrc, 'String');
selectionIdx = get(hsrc, 'Value');

% Get the active eye diagram object
activeEyeObj = hPlotCtrl.EyeObj;

% If the szelection has not changed, proceed
if ~strcmp(activeEyeObj.ColorScale, options{selectionIdx})
    % Set the eye diagram object ColorScale property
    set(activeEyeObj, 'ColorScale', options{selectionIdx})
    
    % Indicate that the scope is dirty, i.e. a property has changed
    set(hPlotCtrl.MainGuiHandle, 'Dirty', 1);
end
end
%-------------------------------------------------------------------------------
function ebcbPlotTimeOffset(hsrc, hPlotCtrl)
% Callback function for the Plot Time Offset edit box

% Get the entered value
valueStr = get(hsrc, 'String');
value = str2double(valueStr);

% Get the handles structure
handles = hPlotCtrl.WidgetHandles;

% Get the old value
oldValue = get(handles.PlotTimeOffsetSlider, 'Value');

% Get the main GUI handle
hGui = hPlotCtrl.MainGuiHandle;

try
    % Get the active eye object
    activeEyeObj = hPlotCtrl.EyeObj;
    % Save the warning state and turn off plot time offset warnings
    warnState = warning('query', 'all');
    [lastWarnMsg lastWarnId] = lastwarn;
    warnId1 = 'comm:commscope:eyediagram:PlotTimeOffsetRounding';
    warnId2 = 'comm:commscope:eyediagram:PlotTimeOffsetWrapping';
    warning('off', warnId1);
    warning('off', warnId2);
    % Set the new value
    set(activeEyeObj, 'PlotTimeOffset', value);
    
    % If there was a warning, prompt using a warning dialog box
    [warnMsg warnId] = lastwarn;
    if ( strcmp(warnId, warnId1) || strcmp(warnId, warnId2) )
        warning(hGui, warnMsg);
        
        % Get the modified value
        value = get(activeEyeObj, 'PlotTimeOffset');
        valueStr = num2str(value);
        set(hsrc, 'String', valueStr);
    end
    lastwarn(lastWarnMsg, lastWarnId);
    
    % Update the plot time offset slider bar
    % If this is the first time we are rendering this window, we should not update
    if ~isempty(handles)
        % Set the slider value
        set(handles.PlotTimeOffsetSlider, 'Value', value);
        
        % If range changed
        if any(oldValue ~= value)
            % Indicate that the scope is dirty, i.e. a property has changed
            set(hGui, 'Dirty', 1);
        end
    end
catch me
    commscope.notifyError(hPlotCtrl.Parent, me);
    % Restore to the previous value
    set(hsrc, 'String', sprintf('%g', oldValue));
end

% Restore the warning state
warning(warnState);
end
%-------------------------------------------------------------------------------
function ebcbPlotTimeOffsetSlider(hsrc, hPlotCtrl)
% Callback function for the Plot Time Offset slider bar

% Get the entered value
value = get(hsrc, 'Value');

% Store the warning state
[warnmsg, warnid] = lastwarn;

% Set the new value.  Set the warning for rounded offset value off.
activeEyeObj = hPlotCtrl.EyeObj;

% Save the warning state and turn off plot time offset warnings
warnState = warning('query', 'all');
warning('off', 'comm:commscope:eyediagram:PlotTimeOffsetRounding');
warning('off', 'comm:commscope:eyediagram:PlotTimeOffsetWrapping');
set(activeEyeObj, 'PlotTimeOffset', value);
% Restore the warning state
warning(warnState);

% In case time offset was rounded, use the rounded value
value = get(activeEyeObj, 'PlotTimeOffset');
set(hsrc, 'Value', value);

% Restore the warning state
lastwarn(warnmsg, warnid);

% Update plot time offset edit box
handles = hPlotCtrl.WidgetHandles;
% If this is the first time we are rendering this window, we should not update
if ~isempty(handles)
    valueStr = sprintf('%g', value);
    set(handles.PlotTimeOffset, 'String', valueStr);
    
    % Indicate that the scope is dirty, i.e. a property has changed
    set(hPlotCtrl.MainGuiHandle, 'Dirty', 1);
end
end
%-------------------------------------------------------------------------------
function ebcbPlotPDFRange(hsrc, hPlotCtrl, minOrMax)
% Callback function for the MAximum Plot PDF Range edit box

% Get the main GUI handle
hGui = hPlotCtrl.MainGuiHandle;

% Get the entered value
valueStr = get(hsrc, 'String');
maxRange = str2double(valueStr);

% Get the old range
activeEyeObj = hPlotCtrl.EyeObj;
range = get(activeEyeObj, 'PlotPDFRange');

% Set the new value
range(minOrMax) = maxRange;
try
    oldRange = get(activeEyeObj, 'PlotPDFRange');
    
    set(activeEyeObj, 'PlotPDFRange', range);
    
    % Range changed
    if any(oldRange ~= range)
        % Indicate that the scope is dirty, i.e. a property has changed
        set(hGui, 'Dirty', 1);
    end
catch me
    commscope.notifyError(hPlotCtrl.Parent, me);
    % Reset to the previous value
    set(hsrc, 'String', sprintf('%g', oldRange(minOrMax)));
end
end

%-----------------------------------------------------------------------
function [idx enumTypeStrings] = getPlotTypeStringIndex(hEye)
%GETPLOTTYPESTRINGINDEX Get the index of the plot type string.
%   [IDX ENUMTYPESTRINGS] = GETPLOTTYPESTRINGINDEX(THIS, PLOTTYPESTR)
%   returns IDX, the index of the PLOTTYPESTR, defined in the enum
%   type ScaleType.  ENUMTYPESTRINGS contains a complete list of the
%   defined enum types.

% Get the plot type string index based on the PlotTypeEnum definition
enumType = findtype('PlotTypeEnums');
if isempty(enumType)
    % If PlotTypeEnum has not been declared yet, then we should
    % create a dummy eye diagram object to declare the enum type the
    % first time.
    dummyHandle = commscope.eyediagram;
    delete(dummyHandle);
    enumType = findtype('PlotTypeEnums');
end
enumTypeStrings = get(enumType, 'Strings');

% Determine the index
if isempty(hEye)
    % Return default
    idx = 1;
else
    idx = strmatch(hEye.PlotType, enumTypeStrings);
end
end

%-----------------------------------------------------------------------
function [idx enumTypeStrings] = getColorScaleStringIndex(hEye)
%GETCOLORSCALESTRINGINDEX Get the index of the color scale string.
%   [IDX ENUMTYPESTRINGS] = GETCOLORSCALESTRINGINDEX(THIS, COLORSCALESTR)
%   returns IDX, the index of the COLORSCALESTR, defined in the enum
%   type ScaleType.  ENUMTYPESTRINGS contains a complete list of the
%   defined enum types.

% Get the plot type string index based on the ScaleType definition
enumType = findtype('ScaleType');
enumTypeStrings = get(enumType, 'Strings');

% Determine the index
if isempty(hEye)
    % Return default
    idx = 1;
else
    idx = strmatch(hEye.ColorScale, enumTypeStrings);
end
end
%-------------------------------------------------------------------------------
% [EOF]