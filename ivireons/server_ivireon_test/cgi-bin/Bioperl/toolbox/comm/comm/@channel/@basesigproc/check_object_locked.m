function check_object_locked(h, propStr)
%CHECK_OBJECT_LOCKED

%   Copyright 1996-2007 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2007/09/14 15:58:02 $

if h.ObjectLocked
    error('comm:channel:basesigproc_check_object_locked:ObjectLocked',['Object locked - cannot set ' propStr '.']); 
end