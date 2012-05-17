function signame = getPortSignalName(signame,blk)
%GETPORTSIGNALNAME Get the SignalName associated with a port.

%   Copyright 2008-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2009/09/28 20:19:05 $

if isempty(signame)
    return;
end

autoscaleExtensions =  SimulinkFixedPoint.AutoscaleExtensions;
autoscaler = autoscaleExtensions.getAutoscaler(blk);
PathItems = autoscaler.getPortMapping(blk, [], str2double(signame));

if ~isempty(PathItems)
    signame = PathItems{1};
end
end

% [EOF]
