function cb_simulation(action)
% SIMULATION

%   Author(s): G. Taillefer
%   Copyright 2006-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.6 $  $Date: 2009/11/13 04:18:43 $

persistent BTN_SIM;
persistent BTN_CANCEL;
me = fxptui.getexplorer;
bd = me.getRoot;
if(~isa(bd, 'fxptui.blkdgmnode'))
	return;
end
mdl = bd.daobject;
if(~isa(mdl, 'Simulink.BlockDiagram'))
	return;
end

% Issue a question dialog if the model is in non-normal mode. A user can
% choose to change it from the dialog.
if (~strcmpi(mdl.SimulationMode,'normal') && isLoggingEnabled(bd)  && strcmpi(mdl.SimulationStatus,'stopped'))
    BTN_TEST = me.PropertyBag.get('BTN_TEST');
    BTN_CHANGE_SIM_MODE = DAStudio.message('FixedPoint:fixedPointTool:btnChangeSimModeAndContinue');
    BTN_CANCEL = DAStudio.message('FixedPoint:fixedPointTool:btnCancel');
    btn = fxptui.showdialog('simmodewarning', BTN_TEST);
    switch btn 
      case BTN_CHANGE_SIM_MODE
        set(mdl,'SimulationMode','normal');
      case BTN_CANCEL
        return;
      otherwise
    end
end

% % Check if the active run has any proposedFLs
if me.hasproposedfl(0) && me.hasunacceptedfl(0) && strcmpi(mdl.SimulationStatus,'stopped')
    if isempty(BTN_SIM)
        BTN_SIM = DAStudio.message('FixedPoint:fixedPointTool:btnIgnoreandSimulate');
    end
    if isempty(BTN_CANCEL)
        BTN_CANCEL = DAStudio.message('FixedPoint:fixedPointTool:btnCancel');
    end
    BTN_TEST = me.PropertyBag.get('BTN_TEST');    
    btn = fxptui.showdialog('ignoreproposalsandsimwarning', BTN_TEST);
    if ~strcmp(btn,BTN_SIM)
        return;
    end
end

switch action
  case 'start',
    if strcmpi(mdl.SimulationStatus, 'paused'),
        cmd = 'continue';
    else
        cmd = 'start';
    end
  case 'pause',
    cmd = 'pause';
  case 'stop'
    cmd = 'stop';
end
try
    %G385962 - avoid seg-v when running sim in external mode
    if(~strcmpi(mdl.SimulationMode, 'External'))
  	set_param(mdl.Name, 'simulationcommand', cmd);
    end
catch e %#ok
    me.restoreactionstate;
end

%---------------------------------------------------
function b = isLoggingEnabled(root)

if ~strcmpi(root.daobject.MinMaxOverflowLogging,'UseLocalSettings') && ~strcmpi(root.daobject.MinMaxOverflowLogging,'ForceOff')
    b = true;
    return;
else
    % Find all subsystems under the root model
    ch = find(root.daobject,'-isa','Simulink.SubSystem');
    b = ~isempty(ch.find({'MinMaxOverflowLogging','MinMaxAndOverflow'},'-or',{'MinMaxOverflowLogging','Overflow'}));
end

%--------------------------------------------------
        
        



% [EOF]
