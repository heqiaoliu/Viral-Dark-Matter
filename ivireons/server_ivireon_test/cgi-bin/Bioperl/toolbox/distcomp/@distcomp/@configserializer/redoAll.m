function redoAll()
; %#ok Undocumented
%Static method that performs as many redo operations as possible, or throws an
%error if no redos are possible.

%   Copyright 2007 The MathWorks, Inc.

ser = distcomp.configserializer.pGetInstance();
if ser.UndoIndex == length(ser.UndoList) 
    error('distcomp:configserializer:redoNotAvailable', ...
          'There are no actions to redo.');
end
while ser.UndoIndex < length(ser.UndoList)
    % Redo the next redo-able action.
    ser.UndoList(ser.UndoIndex + 1).redo();
    % By increasing the index, we make it possible to undo the action that we 
    % just redid.
    ser.UndoIndex = ser.UndoIndex + 1;
end

ser.pFireUndoStateListeners();
