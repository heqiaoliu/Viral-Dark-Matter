function val = pSetClusterSize(obj, val)
; %#ok Undocumented

%  Copyright 2007 The MathWorks, Inc.

if obj.Initialized
    maxClusterSize = com.mathworks.toolbox.distcomp.local.LocalConstants.sMAX_AVAILABLE_LICENSES;
    if val > maxClusterSize || val < 1
        error('distcomp:localscheduler:InvalidClusterSize', ...
            'The ClusterSize for a local scheduler must be between 1 and %d', maxClusterSize);
    end
    obj.LocalScheduler.setMaximumNumberOfWorkers(val);
end
