function callbackDialogDDG(source,tag,dialog) %#ok<INUSD>

%   Author(s): Murad Abu-Khalaf , December 17, 2008
%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.7 $ $Date: 2009/12/28 04:38:19 $

% NOTE: Only the tune button requires a callback. Other widgets status is
% managed via DialogRefresh. Default subsystem callbacks are not needed and
% will not be able to manage Buddy widgets.

blkh = source.getBlock;

%% Tune Button
if strcmp(tag,'TuneButton')
    if (license('test','simulink_control_design')==1)
        h = slctrlguis.pidtuner.getInstance(blkh.Handle);
        if isempty(h)
            slctrlguis.pidtuner.tunerdlg(blkh.Handle);
        else
            h.show;
        end
    else
        DAStudio.error('Simulink:blocks:licenseRequiredForPIDTuner',blkh.getFullName);
    end
end

