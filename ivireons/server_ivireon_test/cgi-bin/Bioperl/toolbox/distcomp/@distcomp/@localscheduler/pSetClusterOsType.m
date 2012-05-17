function val = pSetClusterOsType(obj, val)
; %#ok Undocumented

%  Copyright 2006 The MathWorks, Inc.

%  $Revision: 1.1.6.1 $    $Date: 2006/12/06 01:35:17 $

if obj.Initialized
    error('distcomp:localscheduler:InvalidArgument', 'You cannot set the ClusterOsType property of a localscheduler object');
end