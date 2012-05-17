function cb_scaleapply
%CB_SCALEAPPLY

%   Author(s): G. Taillefer
%   Copyright 2006-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.8 $  $Date: 2010/01/25 21:37:25 $

me = fxptui.getexplorer;
treenode = initui(me);
if(isempty(treenode)); return; end
try
  SimulinkFixedPoint.Autoscaler.scale(treenode.daobject, 'Apply');
catch fpt_exception
  fxptui.showdialog('scaleapplyfailed', fpt_exception.message);
end
restoreui(me, treenode);

%--------------------------------------------------------------------------
function treenode = initui(me)
treenode = [];
run = 0; 
%if there are no accept checkboxes checked warn and return
results = me.getresults(run);
if(~me.hasproposedfl(run))
    
  if ~isempty(results) && ~isempty(find(results,'ProposedDT','n/a')) 
      fxptui.showdialog('noproposedfl');
  else
      fxptui.showdialog('noproposeddt');
  end
  return;
end

if(isempty(results)); return; end
scaleable = false;
for i = 1:numel(results)
  if(results(i).Accept)
    scaleable = true;
    break;
  end
end
if(~scaleable)
  fxptui.showdialog('notacceptchecked');
  return;
end

treenode = me.imme.getCurrentTreeNode;
if(isRedAlertInScaling(treenode))
   treenode = [];
   return;
end
me.sleep;
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
%treenode = me.imme.getCurrentTreeNode;
treenode.firepropertychange;
%suppress progressbar in BAT
if(~me.istesting)
  me.progressbar = fxptui.createprogressbar(me,DAStudio.message('FixedPoint:fixedPointTool:labelSCALEAPPLY'));
end
pause(2);

%--------------------------------------------------------------------------
function restoreui(me, treenode)
% Update the list view based on the filter selection.
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
appdata = me.getappdata;
if(appdata.inScaling)
  appdata.inScaling = 0;
  mdlname = me.getRoot.daobject.getFullName;
  try
    interface = get_param(mdlname, 'ObjectAPI_FP');
    term(interface);
  catch e %#ok
    %consume error. this to make sure that the scaling engine init gets reset
    %if it hasn't terminated correctly
  end
end
beep;

%---------------------------------------------------------------------------
function isRedAlertInScaling = isRedAlertInScaling(node)
% Check if there are any Red Alerts in the proposals that are in the process of being accepted.

isRedAlertInScaling = false;
me = fxptui.getexplorer;
if(isempty(me) || isempty(node)); return; end
% If any of the results for which proposals are being accepted have red alerts, ask the user
% to check the results because accepting them may lead to an uncompilable model.
res = me.getresults;
hasAlertAndAccept = false;
for i = 1:length(res)
    if ((strcmp(res(i).Alert,'red')  || strcmp(res(i).Alert,'yellow')) && res(i).Accept)
        hasAlertAndAccept = true;
        break;
    end
end
if hasAlertAndAccept   
    BTN_TEST = me.PropertyBag.get('BTN_TEST');
    btn = fxptui.showdialog('scaleapplyattention',BTN_TEST);
    lblYes = DAStudio.message('FixedPoint:fixedPointTool:btnIgnoreAlertAndApply');
    if strcmp(btn,lblYes)
        return;
    else
        isRedAlertInScaling = true;
        return;
    end
end
%---------------------------------------------------------------------------
        
% [EOF]
