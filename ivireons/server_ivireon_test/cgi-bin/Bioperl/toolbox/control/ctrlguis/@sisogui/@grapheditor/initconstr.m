function initconstr(Editor, Constr)
%INITCONSTR  Generic initialization of plot constraints.
%
%   Called by editor-specific addconstr.

%   Author(s): P. Gahinet, A. Stothert
%   Copyright 1986-2009 The MathWorks, Inc. 
%   $Revision: 1.5.4.4 $  $Date: 2009/02/06 14:16:29 $

% Initialize
Constr.EventManager = Editor.EventManager;
Constr.Zlevel = Editor.zlevel('constraint');
Constr.ButtonDownFcn = {@LocalButtonDownFcn, Constr, Editor};
%Constr.TextEditor = plotconstr.tooleditor(Editor.ConstraintEditor,Editor);
Constr.EditDlg = plotconstr.tooleditor(Editor.ConstraintEditor,Editor);

% Install generic listeners
% RE: Do after prop. init. for trouble-free undo, and before activation to 
%     enable pre-set listener on Activated
Constr.initialize

% Add listeners connecting the constraint to the Editor environment
L1 = [handle.listener(Constr,'DataChanged',@LocalUpdateLims);...
   handle.listener(Constr.EventManager,'MouseEdit',@LocalReframe)];
set(L1,'CallbackTarget',Editor);
L2 = handle.listener(Editor.Axes,'PostLimitChanged',@LocalRefresh);
set(L2,'CallbackTarget',Constr);
Constr.addlisteners([L1;L2]);

% Add undo/redo fcn handles for the constraint
Constr.undoDeleteInfo.fcnGetData    = @localGetUndoData;
Constr.undoDeleteInfo.fcnUndoDelete = {@localUndoDelete Editor};
Constr.undoDeleteInfo.fcnRedoDelete = {@localRedoDelete Editor};
end


% --------------------------- Local Functions ----------------------------------%

function LocalUpdateLims(Editor,eventData)
% Side effect of constraint's DataChanged event
if strcmp(Editor.EventManager.MouseEditMode,'off')
   % Normal mode: update limits
   updateview(Editor)
end
end


function LocalReframe(Editor,eventData)
% Callback during dynamic mouse edit
% Reframe axes if edited objects are out of scope and limits are auto range
Axes = Editor.Axes;
WorkingAxes = Axes.EventManager.SelectedContainer;
Data = eventData.Data;
iy = (WorkingAxes==getaxes(Axes));

if any(iy) && (strcmp(Axes.XlimMode,'auto') || strcmp(Axes.YlimMode{iy},'auto'))
    MovePtr = Editor.reframe(WorkingAxes,'xy',Data.XExtent,Data.YExtent);
    if MovePtr
        moveptr(WorkingAxes,'move',Data.X,Data.Y)
    end
end
end

function LocalRefresh(Constr,eventData)
% Refreshes constraint display when axes limits change
if ishandle(Constr), render(Constr), end
end

function LocalButtonDownFcn(hSrc, event, Constr, Editor)
% Sets the ButtonDown callback for constraint objects.
if ~strcmp(Editor.EditMode,'idle')
    % Redirect buttondown event to Editor
    Editor.mouseevent('bd',ancestor(hSrc,'axes'));
else
    % Process locally
    Constr.mouseevent('bd',hSrc);
end
end

function data = localGetUndoData(Constr)

data.Data = Constr.save;
data.Type = Constr.describe('identifier');
end

function localUndoDelete(Editor,undoData)

cEditor = Editor.newconstr(undoData.Type);
% From the constraint editor construct a view
sisodb = Editor.up;
hC = cEditor.Requirement.getView(Editor);
hC.PatchColor = sisodb.Preferences.RequirementColor;
hC.load(undoData.Data);
% Add to constraint list (includes rendering)
Editor.addconstr(hC);
hC.Selected = 'off';

%Notify client listeners that new requirement added
ed = plotconstr.constreventdata(Editor,'RequirementAdded');
ed.Data = hC;
Editor.send('RequirementAdded',ed)
end

function localRedoDelete(Editor,redoData)

hAx    = getaxes(Editor.Axes);
CList  = plotconstr.findConstrOnAxis(hAx(1));
allUID = get(CList,{'uID'});
idx = strcmp(allUID,redoData.Data.uID);
delete(CList(idx))
end