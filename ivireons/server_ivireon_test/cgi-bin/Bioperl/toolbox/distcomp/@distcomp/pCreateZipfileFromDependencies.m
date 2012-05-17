function [zipname, cleanupObject, files] = pCreateZipfileFromDependencies(files)

%   Copyright 2009 The MathWorks, Inc.

% First canonicalize the list
files = distcomp.pCanonicalizeFileDependenciesList(files);

% Then create the zip file
zipname = [tempname '.zip'];
zip(zipname,files);
cleanupObject = onCleanup( @() iCleanUp(zipname) );


function iCleanUp(zipname)
warningState = warning('off', 'MATLAB:DELETE:Permission');
delete(zipname);       
warning(warningState);
% If the zipfile still exists then lets delete it later
if exist(zipname, 'file') && usejava('jvm')
    file = java.io.File(zipname);
    com.mathworks.toolbox.distcomp.util.FileDeleter.getInstance.deleteFileLater(file);
end
