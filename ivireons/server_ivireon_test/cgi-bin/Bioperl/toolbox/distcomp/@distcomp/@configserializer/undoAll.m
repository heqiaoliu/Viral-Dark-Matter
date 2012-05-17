function undoAll()
; %#ok Undocumented
%Static method that performs as many undos as possible, or throws an error if no
%undos are possible.

%   Copyright 2007 The MathWorks, Inc.

ser = distcomp.configserializer.pGetInstance();
if ser.UndoIndex == 0
    error('distcomp:configserializer:undoNotAvailable', ...
          'There are no actions to undo.');
end
while ser.UndoIndex > 0
    % Undo the last undo-able action that we have on our list.
    ser.UndoList(ser.UndoIndex).undo();
    % By reducing the index by one, we make it possible to redo the action that we
    % just undid.
    ser.UndoIndex = ser.UndoIndex - 1;
end
ser.pFireUndoStateListeners();
