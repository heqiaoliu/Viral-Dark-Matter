function propsSchema = getPropsSchema(hCfg, hDlg)
%GETPROPSSCHEMA Get the propsSchema.

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2010/05/20 03:08:06 $

[proc_lbl, proc] = uiscopes.getWidgetSchema(hCfg, 'InputProcessing', 'combobox', 1, 1);
proc.Entries = {uiscopes.message('FrameProcessing'), uiscopes.message('SampleProcessing')};
proc.DialogRefresh = true;

grid    = uiscopes.getWidgetSchema(hCfg, 'Grid', 'checkbox', 1, 1);
legend  = uiscopes.getWidgetSchema(hCfg, 'Legend', 'checkbox', 2, 1);
% compact = uiscopes.getWidgetSchema(hCfg, 'Compact', 'checkbox', 3, 1);

checkGroup.Type = 'group';
checkGroup.Items = {grid, legend}; %, compact};
checkGroup.LayoutGrid = [3 1];
checkGroup.RowStretch = [0 0 0 1];
checkGroup.RowSpan = [2 2];
checkGroup.ColSpan = [1 3];

mainGroup.Type = 'group';
mainGroup.Items = {proc_lbl, proc, checkGroup};
mainGroup.LayoutGrid = [3 2];
mainGroup.RowStretch = [0 0 1];

mainTab.Name = uiscopes.message('MainTabLabel');
mainTab.Items = {mainGroup};

processingModeValue = uiservices.getWidgetValue(proc, hDlg);
if ischar(processingModeValue) && strcmp(processingModeValue, 'FrameProcessing') || ...
        isnumeric(processingModeValue) && processingModeValue == 0
    [timerange_lbl, timerange] = uiscopes.getWidgetSchema(hCfg, 'TimeRangeFrames', 'combobox', 1, 1);
    [IST_message, IST_ID] = uiscopes.message('TimeRangeInputSampleTime');
    timerange.Entries = {IST_message, uiscopes.message('TimeRangeUserDefined')};
    timeRangeValue = uiservices.getWidgetValue(timerange, hDlg);
    timerange.Editable = true;
    
    % Make sure that the timeRangeValue has a real value.  It can be empty
    % when going from samples to frame processing, because the widget
    % appears to be there, but it is actually the widget from samples.
    if isempty(timeRangeValue)
        timeRangeValue = timerange.Source.Value;
    end
    
    % If the value is the id for the IST set the value in the GUI to
    % the translated string.  Otherwise it is just a string value of a
    % number and no translation needs to be made.
    if strcmp(timeRangeValue, IST_ID)
        timeRangeValue = IST_message;
    end
    
    % Remove the ObjectProperty from the structure.  It will be handled in
    % the postOptionsDialogApply method.
    timerange = rmfield(timerange, 'ObjectProperty');
    
    timerange.Value = timeRangeValue;
    % This does not work with DDG at the moment.  It only takes the first
    % Editable value from when the dialog is launched.
%     timeRangeValue = uiservices.getWidgetValue(timerange, hDlg);
%     if strcmp(timeRangeValue, uiscopes.message('TimeRangeInputSampleTime'))
%         timerange.Editable = false;
%     else
%         timerange.Editable = true;
%     end
%     timerange.DialogRefresh = true;
else
    [timerange_lbl, timerange] = uiscopes.getWidgetSchema(hCfg, 'TimeRangeSamples', 'edit', 1, 1);
end

[timeoffset_lbl, timeoffset] = uiscopes.getWidgetSchema(hCfg, 'TimeDisplayOffset', 'edit', 2, 1);
[minylim_lbl,    minylim]    = uiscopes.getWidgetSchema(hCfg, 'MinYLim', 'edit', 3, 1);
[maxylim_lbl,    maxylim]    = uiscopes.getWidgetSchema(hCfg, 'MaxYLim', 'edit', 4, 1);
[ylabel_lbl,     ylabel]     = uiscopes.getWidgetSchema(hCfg, 'YLabel', 'edit', 5, 1);

axisGroup.Type  = 'group';
axisGroup.Items = {...
    timerange_lbl,  timerange, ...
    timeoffset_lbl, timeoffset, ...
    minylim_lbl,    minylim, ...
    maxylim_lbl,    maxylim, ...
    ylabel_lbl,     ylabel};
axisGroup.LayoutGrid = [6 2];
axisGroup.RowStretch = [0 0 0 0 0 1];

axisTab.Name  = uiscopes.message('AxisPropertiesTabLabel');
axisTab.Items = {axisGroup};

propsSchema.Type = 'tab';
propsSchema.Tabs = {mainTab, axisTab};

% [EOF]
