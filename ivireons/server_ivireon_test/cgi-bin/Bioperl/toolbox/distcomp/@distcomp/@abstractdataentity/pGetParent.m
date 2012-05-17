function val = pGetParent(obj, val)
; %#ok Undocumented
%pGetParent A short description of the function
%
%  VAL = pGetParent(JOB, VAL)

%  Copyright 2000-2006 The MathWorks, Inc.

val = obj.up;
