function undo(hMgr)
%UNDO Perform the undo Action

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.4.4.3 $  $Date: 2008/05/31 23:28:25 $

% Pop the last action off the undo stack
hT = pop(hMgr.UndoStack);

% Undo the last action
undo(hT);

% If it is numeric it hasn't been created yet
if isnumeric(hMgr.RedoStack),
    hMgr.RedoStack = sigutils.overflowstack(hMgr.Limit);
    attachlisteners(hMgr);
end

% Push the last action onto the redo stack
push(hMgr.RedoStack,hT);

% Send the UndoPerformed event
send(hMgr, 'UndoPerformed', handle.EventData(hMgr, 'UndoPerformed'));

% [EOF]
