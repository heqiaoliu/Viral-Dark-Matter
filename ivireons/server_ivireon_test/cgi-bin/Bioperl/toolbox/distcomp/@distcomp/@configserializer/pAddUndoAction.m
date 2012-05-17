function pAddUndoAction(obj, undoAction)
;%#ok Undocumented
%Add an undoable action to the action list.

%   Copyright 2007 The MathWorks, Inc.

if isempty(obj.UndoListeners)
    % Don't keep track of undo unless we've been asked to. 
    return;
end
obj.UndoList(obj.UndoIndex + 1) = undoAction;
obj.UndoIndex = obj.UndoIndex + 1;
% Adding an undoable action means that we can't redo any of the subsequent
% actions.
obj.UndoList(obj.UndoIndex + 1:end) = [];

% Never store more than 50 undo actions.
if obj.UndoIndex > 50
    obj.UndoIndex = obj.UndoIndex - 1;
    obj.UndoList(1) = [];
end
obj.pFireUndoStateListeners();

