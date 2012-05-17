function empty(hMgr)
%EMPTY Empty the UndoManager stacks
%   EMPTY(hMGR) Empty the UndoManager stacks.  This should be done whenever
%   an action in the GUI results in the UndoStack being invalid.  For instance,
%   loading a new session will result in an invalid UndoStack.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.2.4.3 $  $Date: 2004/04/13 00:26:54 $

% We don't create an UndoStack object until we need it (an action has been taken).
if isa(hMgr.UndoStack, 'sigutils.overflowstack'),
    empty(hMgr.UndoStack);
end

% We don't create a RedoStack object until we need it (an action has been undone).
if isa(hMgr.RedoStack, 'sigutils.overflowstack'),
    empty(hMgr.RedoStack);
end

% [EOF]
