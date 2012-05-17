function taskAccessProxy = pGetTaskAccessProxy(obj)
; %#ok Undocumented
%pGetTaskAccessProxy 
%
%  proxy = pGetTaskAccessProxy(jm)

%  Copyright 2005-2006 The MathWorks, Inc.

%  $Revision: 1.1.10.3 $    $Date: 2006/06/27 22:38:34 $ 

try
    taskAccessProxy = obj.up.pGetTaskAccessProxy;
catch
    taskAccessProxy = [];
end