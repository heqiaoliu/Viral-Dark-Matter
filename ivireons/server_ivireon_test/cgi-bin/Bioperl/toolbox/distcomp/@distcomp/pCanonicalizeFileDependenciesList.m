function files = pCanonicalizeFileDependenciesList(files)

%   Copyright 2009 The MathWorks, Inc.

% The canonical version of a list of file dependencies involves removing
% all empty entries, replacing any on the path with their full path form
% and leaving all the rest unchanged.

nonEmptyEntries = ~cellfun('isempty', files);
files = files(nonEmptyEntries);

for i = 1:numel(files)
    % Get working copy of the file we are looking at
    thisFile = files{i};    
    fullPath = which(thisFile);
    % Pick-up tilde on unix here if which has returned nothing
    if isunix && isempty(fullPath) 
        fullPath = iTildeExpansion(thisFile);
    end
    if ~isempty(fullPath)
        % Someone returned something useful
        files{i} = fullPath;
    end
end

files = iAddAuthFilesIfDeployed( files );
% Make sure that no directories end in a file separator as the behaviour of
% zip with absolute or relative paths is different under these circumstances 
files = regexprep(files, [filesep '\s*$'], '');

     
function files = iAddAuthFilesIfDeployed( files )
% IADDAUTHFILESIFDEPLOYED 
if isdeployed
    authFiles = cell( size( files ) );
    numAuthFiles = 0;
    for n = 1:numel( files )
        thisFile = files{n};
        % Does this file have a .auth file?
        % foo.mexext ---> foo_mexext.auth
        [location, name, ext] = fileparts( thisFile );
        possibleAuthFile = fullfile( location, [name, '_', ext(2:end), '.auth'] );
        % If the file exists, we'll add it to the FileDependencies as well.
        if exist( possibleAuthFile , 'file' )
            numAuthFiles = numAuthFiles + 1;
            authFiles{numAuthFiles} = possibleAuthFile;
        end
    end
    files = [files(:); authFiles(1:numAuthFiles)];
end

function fullFilename = iTildeExpansion(filename)
% Does it begin with a '~'?
if isunix && strncmp( filename, '~', 1 )
    % Look for everything from the beginning of the string until either the
    % end of the string or the first path separator (inclusive)
    tildePattern = '^.*?(/|$)';
    % Get the beginning tilde part to call ls on (we know / is pathsep 
    % because isunix test has been done above)
    tildePart = regexp( filename, tildePattern, 'once', 'match');
    % Use ls -d to convert tildePart to fullpath
    tildeFullpath = deblank(ls('-d', tildePart));
    % Finally replace - reuse regexp to mimic exactly the finding part
    fullFilename = regexprep( filename, tildePattern, tildeFullpath, 'once' );
else
    % Like 'which' return '' if we don't know how to replace.
    fullFilename = '';
end