function empty(hThis,undoPos,redoPos)

% Copyright 2002-2007 The MathWorks, Inc.

% The optional undoPos/redoPos empties the undo stack up to and including the
% specified undoPos/redoPos position.
if nargin>=2 && ~isempty(undoPos)
    hThis.UndoStack(1:undoPos) = [];
else
    hThis.UndoStack = [];
end
if nargin>=3 && ~isempty(redoPos)
    hThis.RedoStack(1:redoPos) = [];
else
    hThis.RedoStack = [];
end

send(hThis,'CommandStackChanged',handle.EventData(hThis,'CommandStackChanged'));