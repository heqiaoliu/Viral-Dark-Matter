function pFireUndoStateListeners(obj, listeners)
;%#ok Undocumented
%Notify undo listeners of the undo state.
%   If the listeners array is empty, we use obj.UndoListeners.

%   Copyright 2007 The MathWorks, Inc.

if nargin < 2
    listeners = obj.UndoListeners;
end

if obj.UndoIndex > 0
    undo = obj.UndoList(obj.UndoIndex);
    % The user has performed at least one undoable operation.
    undoAction = undo.action;
    undoConfig = undo.config;
else
    undoAction = com.mathworks.toolbox.distcomp.configurations.ConfigUndoAction.NO_UNDOREDO;
    undoConfig = '';
end

if obj.UndoIndex < length(obj.UndoList)
    % The user has performed at least one undo operation.
    redo = obj.UndoList(obj.UndoIndex + 1);
    redoAction = redo.action;
    redoConfig = redo.config;
else
    redoAction = com.mathworks.toolbox.distcomp.configurations.ConfigUndoAction.NO_UNDOREDO;
    redoConfig = '';
end

for i = 1:length(listeners)
    j = java(listeners(i));
    awtinvoke(j, 'stateChange', undoAction, undoConfig, redoAction, redoConfig);
end
