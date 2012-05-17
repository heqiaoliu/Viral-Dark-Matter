function val = pGetName(obj, val)
; %#ok Undocumented
%PGETNAME private function to get jobmanager name from java object
%
%  VAL = PGETNAME(OBJ, VAL)

%  Copyright 2000-2006 The MathWorks, Inc.

%  $Revision: 1.1.8.3 $    $Date: 2006/06/27 22:39:56 $ 

proxyWorker = obj.ProxyObject;
try
    val = char(proxyWorker.getName);
catch
	% TODO
end
