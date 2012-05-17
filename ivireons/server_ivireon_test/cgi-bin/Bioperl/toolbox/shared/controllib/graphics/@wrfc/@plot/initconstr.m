function initconstr(this, Constr)
%INITCONSTR  Generic initialization of plot constraints.
%
%   Called by view-specific addconstr.

%   Author(s): P. Gahinet, A. Stothert
%   Copyright 1986-2009 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $  $Date: 2009/10/16 06:29:28 $

% Initialize
Viewer = get(this.Axes.Parent,'userdata');
if isa(Viewer,'viewgui.SisoToolViewer')
   sisodb              = Viewer.Parent;
   Constr.EventManager = Viewer.EventManager;
   if numel(sisodb.PlotEditor) > 0
      %Use same text editor and zlevel as sisotool editors
      Constr.Zlevel  = sisodb.PlotEditor(1).zlevel('constraint');
      Constr.EditDlg = plotconstr.tooleditor(sisodb.PlotEditor(1).ConstraintEditor,this);
   else
      %No sisotool editors, use independent text editor and zlevel
      Constr.Zlevel = -1;
   end      
else
   Constr.Zlevel = -1;
   Constr.EventManager = this.Axes.EventManager;
end
Constr.ButtonDownFcn = {@LocalButtonDownFcn, Constr, this};

% Install generic listeners
% RE: Do after prop. init. for trouble-free undo, and before activation to 
%     enable pre-set listener on Activated
Constr.initialize

% Add listeners connecting the constraint to the Editor environment
L1 = [handle.listener(Constr,'DataChanged',{@LocalUpdateLims Viewer this.AxesGrid});...
   handle.listener(Constr.EventManager,'MouseEdit',{@LocalReframe Viewer this.AxesGrid})];
set(L1,'CallbackTarget',this);
L2 = handle.listener(this.Axes,'PostLimitChanged',@LocalRefresh);
set(L2,'CallbackTarget',Constr);
Constr.addlisteners([L1;L2]);

% Add undo/redo fcn handles for the constraint
Constr.undoDeleteInfo.fcnGetData    = @localGetUndoData;
Constr.undoDeleteInfo.fcnUndoDelete = {@localUndoDelete this};
Constr.undoDeleteInfo.fcnRedoDelete = {@localRedoDelete this};
end


function LocalUpdateLims(~,~,Viewer,Axes)
% Side effect of constraint's DataChanged event

if isa(Viewer,'viewgui.SisoToolViewer')
   if strcmp(Viewer.EventManager.MouseEditMode, 'off')
      %Normal mode: update limits
      Axes.send('ViewChanged')
   end
elseif strcmp(Axes.EventManager.MouseEditMode,'off')
   %Normal mode: update limits
   Axes.send('ViewChanged')
end
end

function LocalReframe(~,hData,Viewer,Axes)
% Callback during dynamic mouse edit
% Reframe axes if edited objects are out of scope and limits are auto range

if isa(Viewer,'viewgui.SisoToolViewer')
   WorkingAxes = Viewer.EventManager.SelectedContainer;
else
   WorkingAxes = Axes.EventManager.SelectedContainer;
end
iy = (WorkingAxes==getaxes(Axes));
if any(iy) && (strcmp(Axes.XlimMode,'auto') || strcmp(Axes.YlimMode{iy},'auto'))
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

function LocalRefresh(Constr,~)
% Refreshes constraint display when axes limits change
if ishandle(Constr), render(Constr), end
end

function LocalButtonDownFcn(hSrc,~, Constr, this)
% Sets the ButtonDown callback for constraint objects.
Viewer = get(this.Axes.Parent,'userdata');
if isa(Viewer,'viewgui.SisoToolViewer')
   %Check Viewer is in idle edit mode to allow processing of event
   if ~strcmp(Viewer.EventManager.MouseEditMode,'idle')
      % Redirect buttondown event to constraint
      Constr.mouseevent('bd',hSrc);
   end
else
    % Process directly
    Constr.mouseevent('bd',hSrc);
end
end

function data = localGetUndoData(Constr)

data.Data = Constr.save;
data.Type = Constr.describe('identifier');
end

function localUndoDelete(Plot,undoData)

cEditor = Plot.newconstr(undoData.Type);
hC = cEditor.Requirement.getView(Plot);
hC.PatchColor = Plot.Options.RequirementColor;
hC.load(undoData.Data);
% Add to constraint list (includes rendering)
Plot.addconstr(hC);
% Unselect
hC.Selected = 'off';

%Notify client listeners that new requirement added
ed = plotconstr.constreventdata(Plot,'RequirementAdded');
ed.Data = hC;
Plot.send('RequirementAdded',ed)
end

function localRedoDelete(Plot,redoData)

hAx    = getaxes(Plot.Axes);
CList  = plotconstr.findConstrOnAxis(hAx(1));
allUID = get(CList,{'uID'});
idx = strcmp(allUID,redoData.Data.uID);
delete(CList(idx))
end