function dependencyMap = pAddDependenciesFromZipfile(zipfileName, dependencyList, dependencyDir)

%   Copyright 2009 The MathWorks, Inc.

unzip(zipfileName, dependencyDir);
if ischar(dependencyList)
    dependencyList = {dependencyList};
end
dependencyMap = iAddListToPath(dependencyDir, dependencyList);


%--------------------------------------------------------------------------
%
%--------------------------------------------------------------------------
function dependencyMap = iAddListToPath(rootdir, filelist)
% filelist input is a cell array of strings that we need to match up to
% files or directories on the local machine. They might be relative or
% absolute and we need to distinguish.

dependencyMap = cell(numel(filelist), 2);
% Create a cell array of all the paths that we will need to add to the
% current MATLAB path in one go
pathsToAdd = cell(size(filelist));

for i = numel(filelist):-1:1
    % convert '\' to '/' in case the path is coming from a PC - NOTE PC
    % MATLAB can deal with '/' whereas unix cannot deal with '\' so ALWAYS
    % convert to unix.
    name = strrep(filelist{i},'\','/');
    localName = [rootdir filesep name];
    % check for a relative path to a file or directory
    if exist(localName,'dir')
        % it is a relative path to a directory
        pathsToAdd{i} = localName;
    elseif exist(localName,'file')
        % it is a relative path to a file
        pathsToAdd{i} = fileparts(localName);
    else
        % it is an absolute path to a file or directory
        % OR
        % it is a relative path to a directory that was empty.
        % A directory could look empty because either,
        %  - a relative or absolute path to a actual empty directory
        %    was specified as a file dependency, or
        %  - a directory was specified as a file dependency, and all
        %    the files in the directory were also specified as file
        %    dependencies by their absolute path.

        % if the directory name ends in a filesep, then the
        % directory's contents will be placed by UNZIP in rootdir,
        % otherwise the directory will be placed in a subdirectory
        % of the appropriate name

        % Get the last part of the filename - this is everything after
        % the last '/', or the whole string if there are no slashes.
        seplocations = strfind(name,'/');
        if ~isempty(seplocations)
            nameEnd = name(seplocations(end)+1:end);
        else
            nameEnd = name;
        end
        localName = [rootdir filesep nameEnd];
        if name(end) == '/'
            % THIS CODE PATH SHOULD NEVER BE CALLED - whilst setting the
            % file dependencies on the job we are checking to see if the
            % element ends with a file separator and removing it.
            dctSchedulerMessage(1, 'File dependency with trailing file separator found - this was NOT expected.');
            % there was a filesep on the end of the directory name
            pathsToAdd{i} = rootdir;
        elseif exist(localName,'dir')
            % there was no filesep on the end of the directory name
            pathsToAdd{i} = localName;
        elseif exist(localName,'file')
            % it is an absolute file name
            pathsToAdd{i} = rootdir;
        else 
            % To get here the filelist entry can not be found locally.
            % This is probably because it was an empty dir and so didn't
            % get added to the zip file. We need to create it here so
            % any files added to this dir can get updated correctly.
            dctSchedulerMessage(1, 'File dependency can not be found - creating dir %s', localName);
            mkdir(localName);
            pathsToAdd{i} = localName;            
        end
    end
    dependencyMap(i, :) = { filelist{i}  localName };
end
% Remove any empty elements
pathsToAdd(cellfun(@isempty, pathsToAdd)) = [];
[~, index] = unique(pathsToAdd, 'first');
pathsToAdd = pathsToAdd(sort(index));
addpath(pathsToAdd{:});

