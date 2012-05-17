function dlg = getDialogSchema(this, dummy)
%GETDIALOGSCHEMA   Get the dialog information.

%   Author(s): J. Schickler
%   Copyright 2005-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2007/05/23 19:01:33 $

dlg = getDialogSchema(this.CurrentDesigner, dummy);

% If the model is running, we need to disable all non-Tunable widgets.
if isRunning(this)
    dlg = disableNonTunables(dlg);
end

dlg.DisplayIcon = 'toolbox\shared\dastudio\resources\SimulinkModelIcon.png';

% Enable Simulink to shut down the dialog properly.
dlg.CloseMethod       = 'closeCallback';
dlg.CloseMethodArgs   = {'%dialog'};
dlg.CloseMethodArgsDT = {'handle'};
dlg.HelpArgs          = {get(this.Block, 'MaskHelp')};

% -------------------------------------------------------------------------
function b = isRunning(this)

hBlk = get(this, 'Block');
hSys = get(hBlk, 'Parent');

simStatus = get_param(bdroot(hSys), 'SimulationStatus');

b = any(strcmp(simStatus,{'running','paused'}));
    
% -------------------------------------------------------------------------
function dlgStruct = disableNonTunables(dlgStruct)

if isfield(dlgStruct,'Items')
    for ind = 1:length(dlgStruct.Items)
        dlgStruct.Items{ind} = disableNonTunables(dlgStruct.Items{ind});
    end
elseif isfield(dlgStruct,'Tabs')
    for ind = 1:length(dlgStruct.Tabs)
        dlgStruct.Tabs{ind} = disableNonTunables(dlgStruct.Tabs{ind});
    end
elseif isfield(dlgStruct,'Tunable')
    if ~dlgStruct.Tunable
        dlgStruct.Enabled = false;
    end
else
    dlgStruct.Enabled = false;
end

% [EOF]
