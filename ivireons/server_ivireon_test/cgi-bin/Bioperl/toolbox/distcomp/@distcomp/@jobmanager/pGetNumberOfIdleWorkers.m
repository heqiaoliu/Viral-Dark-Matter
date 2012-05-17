function val = pGetNumberOfIdleWorkers(obj, val)
; %#ok Undocumented
%pGetNumberOfIdleWorkers private function to get number of worksers from java object
%
%  VAL = pGetNumberOfIdleWorkers(OBJ, VAL)

%  Copyright 2000-2006 The MathWorks, Inc.

%  $Revision: 1.1.8.4 $    $Date: 2006/06/27 22:37:36 $ 

proxyManager = obj.ProxyObject;
try
    % Get the java tasks from the job
    val = double(proxyManager.getNumIdleWorkers);
catch
    % TODO
end
