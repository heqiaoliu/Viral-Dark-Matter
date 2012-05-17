function h = explorer(varargin)
% EXPLORER constructor
%
%   Author(s): G. Taillefer
%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.19 $  $Date: 2010/05/20 02:18:21 $

mdlname = '';
%keep track of the incoming sleep state. it will be true if called while
%demo is loading and if the ui was closed from the file menu or 'x'
if nargin > 0
  mdlname = varargin{1};
end
h = fxptui.getexplorer;
%if an instance of explorer exists and no args were passed return this
%instance (mimic a singleton pattern)
if(isempty(mdlname) && ~isempty(h))
  return;
end

%if explorer doesn't exist create one
if(isempty(h))
    title = sprintf('%s %s',DAStudio.message('FixedPoint:fixedPointTool:labelInitializeFPT'),...
                    'Fixed-Point Tool'); % product title should not be translated/localized. 
    pb = fxptui.createprogressbar(title);
    %create a dataset for this explorer (backend)
    %create tree with the model at root
    root = fxptui.blkdgmnode(mdlname);
    %create a fxptui.explorer(ROOT, TITLE, SHOW?)
    h = fxptui.explorer(root, 'Fixed-Point Tool',0);
   
    %create a place to store results (UI)
    h.userdata.warning.backtrace.state = '';
    h.PropertyBag = java.util.HashMap;

    %build UI
    creatui(h);
    
    % Add custom property names for the properties
    locAddCustomPropNames(h);
    %if  explorer exists and the model == root, return
    %listen for the explorer being closed via command line ie: delete(me)
    if isempty(h.listeners)
        h.listeners = handle.listener(h, 'ObjectBeingDestroyed', @(s,e)cleanup(h));
    else
        h.listeners(end+1) = handle.listener(h, 'ObjectBeingDestroyed', @(s,e)cleanup(h));
    end
    h.listeners(end+1) = handle.listener(h,'METreeSelectionChanged',@(s,e) locUpdateListView(h));
    
    %add listeners to new root
    addrootlisteners(h);
    hupdatedata(h);
    syncstatuswithengine(h);
    pb.dispose;
elseif(strcmpi(h.getRoot.daobject.getFullName, mdlname))
    hupdatedata(h);
    syncstatuswithengine(h);
    %if  explorer exists and the model != root, swap out the root
else
    title = sprintf('%s %s',DAStudio.message('FixedPoint:fixedPointTool:labelInitializeFPT'),...
                    'Fixed-Point Tool'); % product title should not be translated/localized. 
    pb = fxptui.createprogressbar(title);
    locChangerootui(h,mdlname);
    pb.dispose;
end

%--------------------------------------------------------------------------
function syncstatuswithengine(h)
enginestatus = h.getRoot.daobject.SimulationStatus;
switch enginestatus
  case 'running'
    locStart(h);
    locContinue(h);
  case 'paused'
    locPause(h);
  otherwise
end


%--------------------------------------------------------------------------
function locStart(h)
if(~strcmp('done', h.status) || h.getappdata.inScaling); return; end
try
    %apply changes on the FPT dialog before running the simulation
    if(~isempty(h.imme.getDialogHandle) && h.imme.getDialogHandle.hasUnappliedChanges)
        h.imme.getDialogHandle.apply;
    end
    %set explorer status to running
    h.status = 'initializing';
    %turn backtrace off while the model is running.
    h.userdata.warning.backtrace = warning('backtrace');
    warning('off', 'backtrace')
    %turn off all menu and toolbar actions except pause and stop
    h.setallactions('off');
    % Pause/Stop button is disabled for external mode
    if ~strcmpi('external',h.getRoot.daobject.SimulationMode)
        h.getaction('PAUSE').Enabled = 'on';
        h.getaction('STOP').Enabled = 'on';
    end
    %update enabledness of dialog buttons
    node = h.imme.getCurrentTreeNode;
    if(isa(node, 'fxptui.subsysnode'))
        node.firepropertychange;
    end
    %clear figure axes
    h.clearfigureaxes;
catch fpt_exception
    h.status = 'done';
    rethrow(fpt_exception);
end

%--------------------------------------------------------------------------
function locPause(h)
switch h.status
  case 'running'
    h.status = 'paused';
    h.getaction('START').Enabled = 'on';
    h.getaction('PAUSE').Enabled = 'off';
    h.getaction('STOP').Enabled = 'on';
  otherwise
end

%--------------------------------------------------------------------------
function locContinue(h)
switch h.status
  case {'initializing', 'paused'}
    h.status = 'running';
    h.getaction('START').Enabled = 'off';
    if(strcmp('SIM', h.getRoot.daobject.ModelReferenceTargetType))
      h.getaction('PAUSE').Enabled = 'off';
      h.getaction('STOP').Enabled = 'off';
    else
      h.getaction('PAUSE').Enabled = 'on';
      h.getaction('STOP').Enabled = 'on';
    end
  otherwise
end

%--------------------------------------------------------------------------
function locTerminating(h)
if(~strcmpi('normal', h.getRoot.daobject.SimulationMode)); return; end
if (strcmpi('running',h.status) || strcmpi('paused',h.status))
    %RunTime is updated in the dataset.
   h.sleep;
else
    return;
end

%--------------------------------------------------------------------------
function locStop(h)
% If not in 'Normal' simulation mode, don't update data - just reset the state of the sim buttons.
if(~strcmpi('normal', h.getRoot.daobject.SimulationMode))
    switch h.status
        case {'running','paused'}
          h.getaction('STOP').Enabled = 'off';
          h.getaction('START').Enabled = 'on';
          h.getaction('PAUSE').Enabled = 'off';
      otherwise
    end
end
%if something caused this to get called other than what we expected ignore
%it. ex: when autoscaling runs, this callback gets invoked while it is
%running and causes data corruption and action state problems.
switch h.status
  case {'running', 'paused'}
    hupdatedata(h);
  case 'compfailed'
    %if the model doesn't compile restore state and return
    locRestore(h);
    beep;
  case 'initializing'
    locRestore(h);
  otherwise
end

%--------------------------------------------------------------------------
function hupdatedata(h)
try
  %collect results, update ui and restore action state
  h.collectdata;
  h.updatedata;
  locRestore(h);
  h.updateactions;
catch fpt_exception
  %restore actionstate and me.status and then let me know why we errored
  locRestore(h);
  %it would be nice if we had an assert keyword here
  rethrow(fpt_exception);
end

%--------------------------------------------------------------------------
function locCompFailed(h)
%if(~strcmp('normal', h.getRoot.daobject.SimulationMode)); return; end
if(~strcmp('running', h.status))
  return;
end
h.status = 'compfailed';

%--------------------------------------------------------------------------
function locRestore(h)
h.status = 'done';
h.restoreactionstate;
%restore the state of backtrace when the model stops running
state = h.userdata.warning.backtrace.state;
warning(state, 'backtrace')
%update enabledness of dialog buttons
node = h.imme.getCurrentTreeNode;
if(isa(node, 'fxptui.subsysnode'))
  node.firepropertychange;
end

%--------------------------------------------------------------------------
function locUpdatLogSignal(h)
children = h.getRoot.getChildren;
for idx = 1:numel(children)
  children(idx).firepropertychange;
end

%--------------------------------------------------------------------------
function cleanup(h)
% Clean up the explorer object. The results have already been deleted in the ModelClose callback and
% the root has also been unpopulated.

% In the case the FPT is deleted via a call to delete(), and the model is
% not closed, clear the results and unpopulate the root. If the model is
% closed first, the ModelClose callback takes care of cleaning up the
% explorer.
if ~h.getRoot.isClosing
   h.clearresults;
   root = h.getRoot;
   root.unpopulate;
   delete(h.imme);
end
dlg = h.getautoscaledialog;
%make sure we're deleting an object and not an empty handle
if(isa(dlg, 'DAStudio.Dialog'))
  delete(dlg);
end

%-------------------------------------------------------------------------
function locChangerootui(h,mdlname)
% Set the root of the FPT to the new model.

% Change the root
oldroot = h.getRoot;
% Delete listeners attached to the old root
idx = [];
for i = 1:numel(h.listeners)
    if isequal(h.listeners(i).SourceObject,oldroot.daobject) 
        delete(h.listeners(i));  
        idx = [idx i];        %#ok<AGROW>
    end
end
h.listeners(idx) = [];
newroot = fxptui.blkdgmnode(mdlname);
h.setRoot(newroot);
% Unpopulate after setting the newroot - G469179
oldroot.unpopulate;
delete(oldroot);
newroot.firehierarchychanged;
%add listeners to new root
addrootlisteners(h);
hupdatedata(h);
syncstatuswithengine(h);

%--------------------------------------------------------------------------
function addrootlisteners(h)
h.listeners(end+1) = handle.listener(h.getRoot.daobject, 'EngineSimStatusInitializing',  @(s,e)locStart(h));
h.listeners(end+1) = handle.listener(h.getRoot.daobject, 'EngineSimStatusTerminating',  @(s,e)locTerminating(h));
h.listeners(end+1) = handle.listener(h.getRoot.daobject, 'EngineSimStatusRunning',  @(s,e)locContinue(h));
h.listeners(end+1) = handle.listener(h.getRoot.daobject, 'EngineSimStatusPaused',  @(s,e)locPause(h));
h.listeners(end+1) = handle.listener(h.getRoot.daobject, 'EngineSimStatusStopped',  @(s,e)locStop(h));
h.listeners(end+1) = handle.listener(h.getRoot.daobject, 'EngineCompFailed',  @(s,e)locCompFailed(h));
autoscalesupport = SimulinkFixedPoint.getApplicationData(h.getRoot.daobject.getFullName);
h.listeners(end+1) = handle.listener(autoscalesupport, findprop(autoscalesupport, 'ResultsLocation'), 'PropertyPostSet', @(s,e)locUpdatLogSignal(h));
h.listeners(end+1) = handle.listener(autoscalesupport, findprop(autoscalesupport, 'SafetyMarginforSimMinMax'), 'PropertyPostSet', @(s,e)locUpdatLogSignal(h));
h.listeners(end+1) = handle.listener(autoscalesupport, findprop(autoscalesupport, 'SafetyMarginforDesignMinMax'), 'PropertyPostSet', @(s,e)locUpdatLogSignal(h));
%-------------------------------------------------------------------------
function locAddCustomPropNames(h)

h.addPropDisplayNames({...
    'OvfWrap','OverflowWraps',...
    'OvfSat', 'Saturations',...
                   });


%-------------------------------------------------------------------------
function locUpdateListView(h)
% Update list view for filter selection when tree node selection is
% changed.

send(h,'UpdateFilterListEvent', handle.EventData(h,'UpdateFilterListEvent'));

%-----------------------------------------------------------------------


% [EOF]
