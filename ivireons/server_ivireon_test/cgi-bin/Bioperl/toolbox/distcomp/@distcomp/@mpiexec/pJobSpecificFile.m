function fullName = pJobSpecificFile( scheduler, job, shortPart )
; %#ok Undocumented
% pJobSpecificFile - Choose a job-specific file - assumes file storeage, else uses the temp directory.

% Copyright 2006 The MathWorks, Inc.
% $Revision: 1.1.6.2 $   $Date: 2006/06/27 22:38:09 $

storage = job.pReturnStorage;
if isa( storage, 'distcomp.filestorage' )
    storageDir = storage.StorageLocation;
    jobSubDir  = job.pGetEntityLocation;
    outDir     = fullfile( storageDir, jobSubDir );
else
    outDir     = tempdir;
end
fullName       = fullfile( outDir, sprintf( 'Job%d%s', job.ID, shortPart ) );

