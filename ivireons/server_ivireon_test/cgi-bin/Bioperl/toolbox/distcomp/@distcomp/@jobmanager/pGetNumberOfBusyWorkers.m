function val = pGetNumberOfBusyWorkers(obj, val)
; %#ok Undocumented
%pGetNumberOfBusyWorkers private function to get number of workers from java object
%
%  VAL = pGetNumberOfBusyWorkers(OBJ, VAL)

%  Copyright 2000-2006 The MathWorks, Inc.

%  $Revision: 1.1.8.3 $    $Date: 2006/06/27 22:37:35 $ 

proxyManager = obj.ProxyObject;
try
    val = double(proxyManager.getNumBusyWorkers);
catch
    % TODO
end
