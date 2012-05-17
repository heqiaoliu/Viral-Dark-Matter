function release(obj, aLock) %#ok
; %#ok Undocumented
%RELEASE
%
%  RELEASE(SERIALIZER, LOCK)
    
% Copyright 2007 The MathWorks, Inc.
    
%  $Revision: 1.1.6.1 $    $Date: 2007/12/10 21:27:52 $
    
aLock.release();
aLock.channel.close();