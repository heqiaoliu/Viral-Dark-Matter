function [success, msg] = postOptionsDialogApply(hDialog)
%POSTOPTIONSDIALOGAPPLY Callback fired after the dialog has been applied
%   and all widgets with an ObjectProperty have been set.

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2010/03/08 21:43:56 $

success = true;
msg = '';

hSrc  = hDialog.getSource;
name  = hSrc.Register.Name;
props = hSrc.Config.PropertyDb;

% If we are in FrameProcessing check if the user has asked for
% InputSampleTime by comparing the dialogs string with the local strings.
if strcmp(props.findProp('InputProcessing').Value, 'FrameProcessing')
    
    % Get the value from the dialog.
    value = hDialog.getWidgetValue([name 'TimeRangeFrames']);
    
    % Get the localized string and the full ID.
    [ipt_msg, ipt_id] = uiscopes.message('TimeRangeInputSampleTime');
    
    % If the value from the dialog matches the localized string, set the ID
    % for that string into the object.
    if strcmp(value, ipt_msg)
        value = ipt_id;
    end
    props.findProp('TimeRangeFrames').Value = value;
end

% [EOF]
