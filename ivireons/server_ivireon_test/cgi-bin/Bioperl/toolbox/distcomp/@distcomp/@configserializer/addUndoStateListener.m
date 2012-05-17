function addUndoStateListener(listener)
; %#ok Undocumented
%Static method that registers the listener for undo notifications.
%   The listener will be notified on the awt event dispatch thread when an
%   undoable action is added to our list, or when an undo or a redo has taken
%   place.

%   Copyright 2007 The MathWorks, Inc.

ser = distcomp.configserializer.pGetInstance();
h = handle(listener);
ser.UndoListeners = [ser.UndoListeners, h];

ser.pFireUndoStateListeners(h);
