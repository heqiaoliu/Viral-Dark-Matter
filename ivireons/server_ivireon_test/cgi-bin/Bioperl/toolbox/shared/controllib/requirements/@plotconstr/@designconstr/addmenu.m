function CMenu = addmenu(Constr, SISOfig)
%ADDMENU  Creates a common right-click context menu for the constraint objects.

%   Author(s): Bora Eryilmaz, A. Stothert
%   Revised:
%   Copyright 1986-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $ $Date: 2010/03/26 17:49:53 $

% Define a right click context menu for the constraint
CMenu = uicontextmenu('Parent', SISOfig,'tag','cMenuConstraint');
%Add menu item to edit constraint
uimenu(CMenu, 'Label', xlate('Edit...'), 'Callback', ...
   {@LocalEdit Constr}, ...
   'visible','on',...
   'Tag','edit');
%Add menu item to delete constraint
uimenu(CMenu, 'Label', xlate('Delete'),  'Callback', ...
   {@LocalDelete Constr}, ...
   'visible', 'on', ...
   'Tag', 'delete');

%Store context menus
Constr.Handles.cMenu = CMenu;
end

% ----------------------------------------------------------------------------%
% Callback Functions
% ----------------------------------------------------------------------------%

% ----------------------------------------------------------------------------%
% Function: LocalEdit
% Edit the constraint
% ----------------------------------------------------------------------------%
function LocalEdit(~, ~, Constr)
Constr.EditDlg.show(Constr.TextEditor);
end

% ----------------------------------------------------------------------------%
% Function: LocalDelete
% Delete the constraint
% ----------------------------------------------------------------------------%
function LocalDelete(~, ~, Constr)
% Delete constraint
EventMgr = Constr.EventManager;

%Create undo/redo functions for constraint deletion
T = ctrluis.ftransaction(xlate('Delete Constraint'));
undoData = feval(Constr.undoDeleteInfo.fcnGetData,Constr);
redoData = undoData;
T.Undo = horzcat(Constr.undoDeleteInfo.fcnUndoDelete, undoData);
T.Redo = horzcat(Constr.undoDeleteInfo.fcnRedoDelete, redoData);

%Remove the constraint
Constr.Data.delete;

% Commit and stack transaction
EventMgr.record(T);
end


