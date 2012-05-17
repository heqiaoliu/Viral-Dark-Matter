function val = pGetHostname(obj, val)
; %#ok Undocumented
%PGETHOSTNAME private function to get hostname from java object
%
%  VAL = PGETHOSTNAME(OBJ, VAL)

%  Copyright 2000-2006 The MathWorks, Inc.

%  $Revision: 1.1.8.3 $    $Date: 2006/06/27 22:39:51 $ 

proxyWorker = obj.ProxyObject;
try
    val = char(proxyWorker.getHostName);
catch
    % TODO
end