function T = popundo(r)
%POPUNDO  Pops last transaction in Undo stack.

% Copyright 2006 The MathWorks, Inc.

% Get last transaction
T = r.Undo(end);

% Remove it from Undo stack
r.Undo = r.Undo(1:end-1);

% Add it to redo stack
r.Redo = [r.Redo ; T];
