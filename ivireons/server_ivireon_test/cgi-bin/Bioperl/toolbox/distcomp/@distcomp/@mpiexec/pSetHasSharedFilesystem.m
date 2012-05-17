function val = pSetHasSharedFilesystem( obj, val )
; %#ok Undocumented
%pSetHasSharedFilesystem - always returns true for mpiexec

%  Copyright 2000-2006 The MathWorks, Inc.
%  $Revision: 1.1.10.3 $    $Date: 2006/06/27 22:38:10 $ 

if ~val
    warning( 'distcomp:mpiexec:sharedfilesystem',...
             'MPIEXEC only supports shared file systems' );
end
val = true;