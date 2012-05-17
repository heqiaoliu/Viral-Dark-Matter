function val = pSetHasSharedFilesystem( obj, val )
; %#ok Undocumented
%pSetHasSharedFilesystem - disallowed for CCS

%  Copyright 2000-2009 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $    $Date: 2009/04/15 22:58:04 $ 

if obj.Initialized
    error('distcomp:ccsscheduler:InvalidState', 'The HasSharedFilesystem property for an HPC Server scheduler is read-only.');
end
