function pushundo(r,T)
%PUSHUNDO  Pushes transaction onto Undo stack.

% Copyright 2006-2008 The MathWorks, Inc.

% Defaults 
UndoStackDepth = 20;

% Clear Redo stack
if length(r.Redo)
    delete(r.Redo);
    r.Redo = [];
end
    
% Add transaction to bottom of Undo stack
UndoStack = [r.Undo;T];

% Truncate Undo stack
if length(UndoStack)>UndoStackDepth
    delete(UndoStack(1));
    UndoStack = UndoStack(2:end,:);
end

% Update property (triggers menu label update)
r.Undo = UndoStack;
