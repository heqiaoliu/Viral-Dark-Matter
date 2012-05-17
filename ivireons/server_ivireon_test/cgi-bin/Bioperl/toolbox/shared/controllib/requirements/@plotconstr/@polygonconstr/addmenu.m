function CMenu = addmenu(Constr, SISOfig)
%ADDMENU  Creates a common right-click context menu for the constraint
%objects.
 
% Author(s): A. Stothert 02-May-2008
% Copyright 2008-2010 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2010/03/26 17:50:05 $

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
%Add menu item to split constraint
uimenu(CMenu, 'Label', xlate('Split'), 'Callback', ...
   {@localSplit Constr Constr.Data}, ...
   'visible', 'off',...
   'tag', 'split');
%Add menu item to flip constraint
uimenu(CMenu, 'Label', xlate('Flip'), 'Callback', ...
   {@localFlip Constr Constr.Data}, ...
   'visible', 'off', ...
   'tag', 'flip');
%Add menu item to glue left end of constraint
uimenu(CMenu, 'Label', xlate('Join left'), 'Callback', ...
   {@localJoin Constr 'left' Constr.Data}, ...
   'tag', 'left',...
   'checked', 'off', ...
   'visible', 'off');
%Add menu item to glue right end
uimenu(CMenu, 'Label', xlate('Join right'), 'Callback', ...
   {@localJoin Constr 'right' Constr.Data}, ...
   'tag', 'right',...
   'checked', 'off', ...
   'visible','off');
%Add menu item to extend constraint to infinity
uimenu(CMenu, ...
   'Label', xlate('Extend to inf'), ...
   'Callback', {@localExtendToInf Constr Constr.Data}, ...
   'tag', 'extend', ...
   'checked', 'off', ...
   'visible', 'off')

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

%Remove the selected edge
DeleteAll = numel(Constr.SelectedEdge)==size(Constr.getX,1);
if DeleteAll
   %Create undo/redo function when whole constraint is deleted
   T = ctrluis.ftransaction(xlate('Delete Constraint'));
   undoData = feval(Constr.undoDeleteInfo.fcnGetData,Constr);
   redoData = undoData;
   T.Undo = horzcat(Constr.undoDeleteInfo.fcnUndoDelete, undoData);
   T.Redo = horzcat(Constr.undoDeleteInfo.fcnRedoDelete, redoData);

   delete(Constr.Data)
else
   % Start recording
   T = ctrluis.ftransaction(xlate('Delete Constraint'));
   UndoData = struct(...
      'xCoords', Constr.getData('xCoords'), ...
      'yCoords', Constr.getData('yCoords'), ...
      'Weight',  Constr.getData('Weight'), ...
      'Linked',  Constr.getData('Linked'));
   T.Redo = {@localRedoDelete Constr Constr.SelectedEdge};
   T.Undo = {@localUndoDelete Constr UndoData}; 

   Constr.Data.removeEdge(Constr.SelectedEdge)
end

% Commit and stack transaction
EventMgr.record(T);
end

%--------------------------------------------------------------------------
function localFlip(~,~,this,ObjToRecord)

EventMgr = this.EventManager;
% Start recording
T = ctrluis.transaction(ObjToRecord,'Name',xlate('Flip Constraint'),...
    'OperationStore','on','InverseOperationStore','on');

%Toggle bound from upper to lower or vice versa
switch this.Type;
   case 'lower'
      this.Type = 'upper';
   case 'upper'
      this.Type = 'lower';
end
%Notify listeners of data source change
this.Data.send('DataChanged');

% Commit and stack transaction
EventMgr.record(T);
end

%--------------------------------------------------------------------------
function localSplit(~, ~, this, ObjToRecord)

EventMgr = this.EventManager;
% Start recording
T = ctrluis.transaction(ObjToRecord,'Name',xlate('Split segment'),...
    'OperationStore','on','InverseOperationStore','on');

%Call abstract method to split constraint
this.Data.splitEdge;

% Commit and stack transaction
EventMgr.record(T);
end

%--------------------------------------------------------------------------
function localJoin(~, ~, this, WhichEnd, ObjToRecord)

EventMgr = this.EventManager;
% Start recording
T = ctrluis.transaction(ObjToRecord,'Name',xlate('Join segment'),...
    'OperationStore','on','InverseOperationStore','on');

% Call  method to join ends
this.Data.join(WhichEnd,this.Orientation);

% Commit and stack transaction
EventMgr.record(T);
end

%--------------------------------------------------------------------------
function localExtendToInf(~,~, this, ObjToRecord)

EventMgr = this.EventManager;
% Start recording
T = ctrluis.transaction(ObjToRecord,'Name',xlate('Extend to inf'),...
    'OperationStore','on','InverseOperationStore','on');

% Call method to extend the edges 
this.Data.extend;
 
% Commit and stack transaction
EventMgr.record(T);
end

%--------------------------------------------------------------------------
function localUndoDelete(Constr, UndoData)

flds = fieldnames(UndoData);
for idx = 1:numel(flds)
   Constr.setData(flds{idx},UndoData.(flds{idx}));
end
%Notify listeners data changed
Constr.send('DataChanged')
end

%--------------------------------------------------------------------------
function localRedoDelete(Constr, iElement)

Constr.SelectedEdge = iElement;
delete(Constr)
end