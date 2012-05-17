function val = pGetGroup(obj, val)
; %#ok Undocumented
%PGETGROUP private function to get worker group from java object
%
%  VAL = PGETGROUP(OBJ, VAL)

%  Copyright 2000-2006 The MathWorks, Inc.

%  $Revision: 1.1.8.3 $    $Date: 2006/06/27 22:39:49 $ 

proxyWorker = obj.ProxyObject;
try
    val = char(proxyWorker.getLookupGroup);
catch
    % TODO
end
