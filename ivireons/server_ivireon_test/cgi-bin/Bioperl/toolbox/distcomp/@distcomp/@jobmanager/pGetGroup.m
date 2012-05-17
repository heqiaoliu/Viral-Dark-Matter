function val = pGetGroup(obj, val)
; %#ok Undocumented
%PGETGROUP private function to get jobmanager group from java object
%
%  VAL = PGETGROUP(OBJ, VAL)

%  Copyright 2000-2006 The MathWorks, Inc.

%  $Revision: 1.1.8.3 $    $Date: 2006/06/27 22:37:27 $ 

proxyManager = obj.ProxyObject;
try
    val = char(proxyManager.getLookupGroup);
catch
    % TODO
end
