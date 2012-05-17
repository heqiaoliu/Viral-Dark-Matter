function val = pGetClusterSize(obj, val)
; %#ok Undocumented
%pGetClusterSize private function to get total number of workers from java object
%
%  VAL = pGetClusterSize(OBJ, VAL)

%  Copyright 2007 The MathWorks, Inc.

%  $Revision: 1.1.6.2 $    $Date: 2008/02/02 13:00:21 $

proxyManager = obj.ProxyObject;
try
    % Read the service info from the job manager
    serviceInfo = proxyManager.getServiceInfo;
    % Add the number of idle and number of busy workers.
    val = double(serviceInfo.getNumBusyWorkers) + double(serviceInfo.getNumIdleWorkers);
catch err
    throw(distcomp.handleJavaException(obj, err));
end
