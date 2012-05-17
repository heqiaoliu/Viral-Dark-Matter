 function newFile  = browseCallback(val, ext, text)

%   Copyright 2009-2010 The MathWorks, Inc.


currPath = path;
currWD = pwd;

currFile = '';
currDir = '';

if ~isempty(val)
    [ currDir, currName]  = fileparts(val);
    if ~isempty(currDir)
        addpath(currDir);
    end

    currFile = which(currName);
end

if isempty(currFile) || strcmp(currFile, default) || strcmp(currFile, 'built-in') || strcmp(currFile, 'variable')
    currFile = '';
    currDir = '';
end

if ~isempty(currDir)
    cd(currDir);
end
[filename, pathname] = uigetfile( ext, text, currFile);
cd(currWD);
path(currPath);
newFile = '';
if ~isequal(filename,0) && ~isequal(pathname,0)
    newFile = fullfile(pathname, filename);
    newFile = strrep(newFile, [ pwd filesep ], '');

end

