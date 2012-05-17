function val = pGetParent(task, val)
; %#ok Undocumented
%pGetParent A short description of the function
%
%  VAL = pGetParent(TASK, VAL)

%  Copyright 2000-2006 The MathWorks, Inc.

val = task.up;
