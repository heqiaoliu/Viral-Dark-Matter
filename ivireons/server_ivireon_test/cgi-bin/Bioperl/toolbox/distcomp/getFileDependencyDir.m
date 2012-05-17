function dependencyDirectory = getFileDependencyDir
%getFileDependencyDir get the directory into which FileDependencies are written
%
% dependencyDirectory = getFileDependencyDir returns a string which is
% the local directory into which FileDependencies are written. This
% function will return an empty array if not called on a worker matlab
%
% Example:
%     % Find the current FileDependency directory 
%     ddir = getFileDependencyDir;
%     % Change to that directory to invoke an executable 
%     cdir = cd(ddir);
%     % Invoke the executable
%     [OK, output] = ]system('myexecutable');
%     % Change back to the original directory
%     cd(cdir);
%
% See also getCurrentJobmanager, getCurrentWorker, 
%          getCurrentJob, getCurrentTask, FileDependencies

%  Copyright 2006-2008 The MathWorks, Inc.

%  $Revision: 1.1.6.2 $    $Date: 2008/03/31 17:07:02 $ 

try
    root = distcomp.getdistcompobjectroot;
    dependencyDirectory = root.DependencyDirectory;
catch
    warning('distcomp:getFileDependencyDir:InvalidState', 'Unexpected error trying to invoke getFileDependencyDir');
    dependencyDirectory = '';
end
