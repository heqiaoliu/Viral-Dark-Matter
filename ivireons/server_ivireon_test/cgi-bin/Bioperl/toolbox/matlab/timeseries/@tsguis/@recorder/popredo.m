function T = popredo(r)
%POPREDO  Pops last transaction in Redo stack.

% Copyright 2006 The MathWorks, Inc.

% Get last undone transaction
T = r.Redo(end);

% Remove it from Redo stack
r.Redo = r.Redo(1:end-1);

% Add it to Undo stack
r.Undo = [r.Undo ; T];
