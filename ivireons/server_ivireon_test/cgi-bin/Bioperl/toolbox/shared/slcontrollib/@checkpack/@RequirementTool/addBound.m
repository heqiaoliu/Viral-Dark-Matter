function addBound(this,hReq)
% ADDBOUND add a requirement to the requirement tool
%

% Author(s): A. Stothert 10-Feb-2010
% Copyright 2010 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2010/03/26 17:50:42 $

%Set the requirement data properties to use the visualization
hVis              = this.Application.Visual;
hReq.isLocked     = this.isLocked;
hReq.EventManager = hVis.EventManager;
hReq.EditDlg      = this.hEditDlg;

%Add the new requirement to the requirement editor dialog managed by
%this tool
this.hEditDlg.ConstraintList = [ this.hEditDlg.ConstraintList; ...
   hReq.TextEditor];

% Add undo/redo fcn handles for the constraint
hReq.undoDeleteInfo.fcnGetData    = @localGetUndoData;
hReq.undoDeleteInfo.fcnUndoDelete = {@localUndoDelete this};
hReq.undoDeleteInfo.fcnRedoDelete = {@localRedoDelete this};

% Add callback to prompt user when clicking a locked requirement
hReq.LockedButtonDownFcn = @() localUnlock(this);

%Add listeners to bound to:
% - redraw on axes limit changes etc.
% - remove from our list when deleted
% - update tool dirty state
hAx  = hVis.hPlot;
L1 = [...
   handle.listener(hReq,'DataChanged',{@localDataChanged this}); ...
   handle.listener(hReq.EventManager,'MouseEdit',{@localReframe hAx.AxesGrid})];
set(L1,'CallbackTarget',hAx);
L2 = handle.listener(hAx.Axes,'PostLimitChanged',@localRefreshBound);
set(L2,'CallbackTarget',hReq);
L3 = handle.listener(hReq,'ObjectBeingDestroyed', @(hSrc,hData) localDeleteBound(hSrc,this));
L4 = handle.listener(hReq,'DataChangeFinished', {@localDirtyState this});
%Store the listeners with the requirement
hReq.addlisteners([L1; L2; L3;L4]);
%Draw the new bound
render(hReq);

%Add requirement to list of requirements
this.hReq = [this.hReq; hReq];
end

function localRefreshBound(hC,~)
% Helper function to redraw bound
if ishandle(hC), render(hC), end
end

function localDirtyState(~,~,this)
%Helper function to set tool dirty state

this.isDirty = true;
end

function localReframe(~,hData,Axes)
% Callback during dynamic mouse edit
% Reframe axes if edited objects are out of scope and limits are auto range

%The visualization may have multiple resppack axes, but we assume the 
%requirements are always parented to the first axes
allAxes = Axes.getaxes;
WorkingAxes = allAxes(1);
if (strcmp(Axes.XlimMode{1},'auto') || strcmp(Axes.YlimMode{1},'auto'))
   xExtent = hData.Data.XExtent;
   yExtent = hData.Data.YExtent;
   xLim = WorkingAxes.XLim;
   yLim = WorkingAxes.YLim;
   reframe = ...
      xExtent(1) < xLim(1) || xExtent(2) > xLim(2) || ...
      yExtent(1) < yLim(1) || yExtent(2) > yLim(2);
   if reframe
      Axes.send('ViewChanged')
   end
end
end

function localDataChanged(~,~,this)

hVis = this.Application.Visual;
if strcmp(hVis.hPlot.AxesGrid.EventManager.MouseEditMode,'off')
   %Normal mode: update limits
   hVis.hPlot.AxesGrid.send('ViewChanged')
end

%Mark requirement tool dirty
localDirtyState([],[],this);
end

function localDeleteBound(hReq,this)
%Helper function to manage delete bound events

%Remove from our list of bounds
this.hReq(this.hReq == hReq) = [];
%Remove from the edit dialogs list of bounds
this.hEditDlg.ConstraintList(this.hEditDlg.ConstraintList == hReq.TextEditor) = [];

%Mark requirement tool dirty
localDirtyState([],[],this);
end

function data = localGetUndoData(hReq)

data.Data = hReq.save;
data.Type = hReq.describe('identifier');
data.isEnabled = hReq.getRequirementObject.isEnabled;
end

function localUndoDelete(this,undoData)

hVis = this.Application.Visual;

cEditor = hVis.newconstr(undoData.Type);
% From the constraint editor construct a view
hC = cEditor.Requirement.getView(Editor);
if undoData.isEnabled.isEnabled
   hC.PatchColor = this.Application.Visual.hPlot.Options.DisabledRequirementColor;
else
   hC.PatchColor = this.Application.Visual.hPlot.Options.DisabledRequirementColor;
end
hC.load(undoData.Data);
% Add to constraint list (includes rendering)
hC.addconstr(hC);
hC.Selected = 'off';

%Notify client listeners that new requirement added
%ed = plotconstr.constreventdata(Editor,'RequirementAdded');
%ed.Data = hC;
%Editor.send('RequirementAdded',ed)
end

function localRedoDelete(this,redoData)

hVis = this.Application.Visual;

hAx    = getaxes(hVis.Axes);
CList  = plotconstr.findConstrOnAxis(hAx(1));
allUID = get(CList,{'uID'});
idx = strcmp(allUID,redoData.Data.uID);
delete(CList(idx))
end

function localUnlock(this)
%Helper function to manage requirement click events when the requirement is
%locked.

if this.isLocked
   hP = get_param(this.Application.DataSource.BlockHandle.Parent,'Object');
   if hP.isLinked
      %Protect against unlocking block in linked subsystem
      errordlg(DAStudio.message('SLControllib:checkpack:errUnlockLinkedBlock'), ...
         DAStudio.message('SLControllib:checkpack:actionUnlockBound'));
   else
      btn = questdlg(...
         DAStudio.message('SLControllib:checkpack:txtQuestionUnlockBound'), ...
         DAStudio.message('SLControllib:checkpack:actionUnlockBound'),'Yes','No','Yes');
      if strcmp(btn,'Yes'), this.toggleLockedStatus, end
   end
end
end
