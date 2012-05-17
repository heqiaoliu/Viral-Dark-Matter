function pResetUndoHistory(obj)
; %#ok Undocumented
%Reset the state of the undo history.

%   Copyright 2007 The MathWorks, Inc.

obj.UndoIndex = 0;
obj.UndoList = struct('redo', {}, 'undo', {}, ...
                      'action', {}, 'config', {});
