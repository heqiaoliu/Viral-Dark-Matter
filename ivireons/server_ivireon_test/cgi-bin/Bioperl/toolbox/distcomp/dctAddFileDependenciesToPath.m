function dependencyMap = dctAddFileDependenciesToPath(job, dependencyDir)
; %#ok Undocumented

% Copyright 2005-2009 The MathWorks, Inc.

[fileList, zipFileData] = job.pReturnDependencyData;

iCleanupDependencyDir(dependencyDir);

if ~isempty(zipFileData)
    zipfileName = iCreateZipFile(zipFileData, dependencyDir);
    cleanupObject = onCleanup( @() iCleanUp(zipfileName) );
    dependencyMap = distcomp.pAddDependenciesFromZipfile(zipfileName, fileList, dependencyDir);
else
    dependencyMap = cell(0, 2);
end

end %iJobStartup

%--------------------------------------------------------------------------
%
%--------------------------------------------------------------------------
function iCleanupDependencyDir(dependencyDir)
% There appears to be some sort of bug with distributed MATLAB and
% the use of files in /tmp that results in the rmdir statement also
% deleting the zipname file. We have been unable to track this down
% and so will deal with the dependency directory before we create
% the zip file - JLM 25/10/04

% delete the directory if it already exists
try
    if exist(dependencyDir,'dir')
        rmdir(dependencyDir,'s');
    end
catch err
    rethrow(err)
end

end % iCreateDependencyDir

%--------------------------------------------------------------------------
%
%--------------------------------------------------------------------------
function zipname = iCreateZipFile(zipbytes, rootdir)
% WRITEFILES - Take uint8 data read by readFiles and write it to a root
% directory.  

try
    mkdir(rootdir);
catch err
    rethrow(err)
end

zipname = [rootdir filesep 'files.zip'];
fid = fopen(zipname,'w+');
fwrite(fid,zipbytes,'int8');
fclose(fid);
end % iWriteFiles

%--------------------------------------------------------------------------
%
%--------------------------------------------------------------------------
function iCleanUp(zipname)
warningState = warning('off', 'MATLAB:DELETE:Permission');
delete(zipname);       
warning(warningState);
% If the zipfile still exists then lets delete it later
if exist(zipname, 'file') && usejava('jvm')
    file = java.io.File(zipname);
    com.mathworks.toolbox.distcomp.util.FileDeleter.getInstance.deleteFileLater(file);
end
end