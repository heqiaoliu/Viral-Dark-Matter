function cb_scalepropose
%CB_SCALEPROPOSE

%   Author(s): G. Taillefer
%   Copyright 2006-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.8 $  $Date: 2009/04/21 03:18:36 $

me = fxptui.getexplorer;
treenode = initui(me);
if(isempty(treenode)); return; end
try
  SimulinkFixedPoint.Autoscaler.scale(treenode.daobject, 'Propose');
catch fpt_exception
    % showdialog can throw an error in testing mode. catch this error, restore
    % the UI and then rethrow the error.
    try
       fxptui.showdialog('scaleproposefailed',fpt_exception);
    catch fpt_exception
       restoreui(me, treenode);
       rethrow(fpt_exception);
    end
    restoreui(me, treenode);
    return;
end
restoreui(me, treenode);
setaccepton(0);
if(hasmarkedred(me) && ~me.istesting)
  fxptui.showdialog('scaleproposeattention');
end

%--------------------------------------------------------------------------
function treenode = initui(me)
treenode = [];
mdl = me.getRoot.daobject;
% Issue a question dialog if the model is in non-normal mode. A user can choose to change it from the dialog.
if ~strcmpi(mdl.SimulationMode,'normal')
    BTN_TEST = me.PropertyBag.get('BTN_TEST');
    BTN_CHANGE_SIM_MODE = DAStudio.message('FixedPoint:fixedPointTool:btnChangeSimModeAndContinue');
    BTN_CANCEL = DAStudio.message('FixedPoint:fixedPointTool:btnCancel');
    btn = fxptui.showdialog('proposedtsimmodewarning', BTN_TEST);
    switch btn 
      case BTN_CHANGE_SIM_MODE
        set(mdl,'SimulationMode','normal');
      case BTN_CANCEL
        return;
      otherwise
    end
end
treenode = me.imme.getCurrentTreeNode;
if(~isDoScaling(treenode))
  treenode = [];
  return;
end

%turn backtrace off while the model is running.
me.userdata.warning.backtrace = warning('backtrace');
warning('off', 'backtrace');
%apply changes before running the simulation
if(~isempty(me.imme.getDialogHandle)&& me.imme.getDialogHandle.hasUnappliedChanges)
  me.imme.getDialogHandle.apply;
end
%disable all actions in the ui
me.setallactions('off');
%update selected system's dialog - we just disabled all actions
treenode.firepropertychange;
% Put the UI to sleep after updating the dialog.
me.sleep;
%suppress progressbar in BAT
if(~me.istesting)
  me.progressbar = fxptui.createprogressbar(me,DAStudio.message('FixedPoint:fixedPointTool:labelSCALEPROPOSE'));
end

%--------------------------------------------------------------------------
function restoreui(me, treenode)
% update the list view based on filter selection
send(me,'UpdateFilterListEvent',handle.EventData(me,'UpdateFilterListEvent'));
me.wake;
me.restoreactionstate;
me.updateactions;
treenode.firepropertychange;
state = me.userdata.warning.backtrace.state;
warning(state, 'backtrace');
if(~me.istesting && ~isempty(me.progressbar))
  me.progressbar.dispose;
end
beep;

%--------------------------------------------------------------------------
function setaccepton(run)
me = fxptui.getexplorer;
if(isempty(me)); return; end
results = me.getresults(run);
if(isempty(results)); return; end

for r = 1:numel(results)
  if(results(r).hasproposedfl) && ...
            ~strcmp(results(r).SpecifiedDT,results(r).ProposedDT)
    %
    % if spec and proposed are the same, then leave accept OFF
    % this has the advantage of not needlessly changing user entered string
    %
    results(r).Accept = true;
  else
    results(r).Accept = false;
  end
end

%--------------------------------------------------------------------------
function isDoScaling = isDoScaling(sys)
isDoScaling = true;
me = fxptui.getexplorer;
if(isempty(me) || isempty(sys)); return; end
%if the user is attempting to scale against fixed point data, ask if that
%is really what they want to do. The normal workflow calls for scaling
%agains floating point data.
results = sys.getChildren;
if(isempty(results)); return; end

aData = SimulinkFixedPoint.getApplicationData(bdroot(sys.daobject.getFullName));

if aData.isUsingSimMinMax

    numSimDT = 0;
    numFixdt = 0;
    
    for r = 1:numel(results)
        
        if(fxptui.str2run(results(r).Run) ~= 0); 
            continue; 
        end
        
        if ~isempty( results(r).SimDT )
            
            numSimDT = numSimDT + 1;
            
            if(results(r).hasfixdt)
                
                numFixdt = numFixdt + 1;
            end
        end
    end

    % Warn if attempting to propose scaling using fixed point data. 
    % It would be reasonable for a floating point model to contain
    % some small used of fixed-point/integer.  To limit "false positive"
    % warnings, the arbitrary threshold of 4% is used.
    % If more than 4% of the data types logging min/max are fixed-point
    % or integer then warn.
    
    if numFixdt > ( 0.04 * numSimDT )
        
        btn = fxptui.showdialog('scalingfixdt');
        lblNo = DAStudio.message('FixedPoint:fixedPointTool:labelNo');
        if(isempty(btn) || strcmp(lblNo, btn))
            isDoScaling = false;
else
            isDoScaling = true;
        end
    end
end

%--------------------------------------------------------------------------
function b = hasmarkedred(me)
b = false;
results = me.getresults;
if(isempty(results)); return; end
alerts = get(results, 'Alert');
if(ischar(alerts))
  alerts = {alerts};
end
b = ismember('red', alerts);

% [EOF]
