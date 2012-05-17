function locationString = pSetStorageLocation(obj, locationString)
; %#ok Undocumented
%pSetStorageLocation set the actual location of file storage on the disk
%
% pathToLocation = pSetStorageLocation(fileStorage, pathToLocation)

%  Copyright 2005-2010 The MathWorks, Inc.

%  $Revision: 1.1.10.7 $    $Date: 2010/01/25 21:30:56 $

% Check that we have been given an array of characters
if ~ischar(locationString) || size(locationString, 1) ~= 1
    error('distcomp:filestorage:InvalidArgument', 'The location property of a file store must be a string');
end

% Check that we have a valid directory
if ~exist(locationString, 'dir')
    error('distcomp:filestorage:InvalidArgument', ...
        [' The DataLocation of a scheduler must be an \n accessible directory on the current machine''s \n' ...
         ' filesystem. The value supplied (%s) \n is not a valid directory'], locationString);
end

% If we are on a PC make sure we convert to a UNC path rather than a
% locally mapped drive as it is unlikely that the far end will have the
% same drive mappings on the local system account
if ispc
    driveLetter = regexp(locationString, '^[A-Za-z]:', 'match', 'once');    
    if ~isempty(driveLetter)
        % Reduce to just the drive letter
        driveLetter = driveLetter(1:2);
        % Convert using windows API function to a UNC path
        uncPath = getUncPathFromMappedDrive(driveLetter);
        % Only bother if it actually returns a UNC path
        if ~isempty(uncPath)
            locationString = [uncPath locationString(3:end)];
        end
    end
end

% Ensure that the directory is absolute, and not dependent on cdir. We do
% this by changing to it and getting pwd, which is always an absolute path.
% This also gives us the oppertunity to test if we can write a file, and
% hence test our privilege level.
cdir = pwd;
try
    % Default is that the location is read-only - we will test this and
    % change if necessary
    obj.IsReadOnly = true;
    % Turn off to deal with path notification warnings on windows.
    warnState = warning('off', 'MATLAB:dispatcher:pathWarning');
    % This cd will fail if the user doesn't have 'rx' like permissions to
    % the directory
    cd(locationString);
    aCleanup = onCleanup(@() iRevertCWDandWarningState(cdir, warnState));
    % Replace with pwd if it doesn't start with a '/'
    if ~ismember(locationString(1), {'/' '\'})
        % Grab the full directory listing
        locationString = pwd;
    end
    % Let's also try writeing a file to see if we have the correct
    % permission. Would be nice to warn the user that it isn't valid
    % Let's try to get a name that is unique using a Uuid since tempname isn't good
    % enough
    uniquepart   = char( net.jini.id.UuidFactory.generate );
    testFilename = sprintf( 'dct_test_file.%s.test', uniquepart );
    try
        % Only delete the file if it doesn't exist already - unlikely!
        DO_DELETE = ~exist(testFilename, 'file');
        % Try opening the file for append
        fid = fopen(testFilename, 'a+');
        if fid < 0
            error('distcomp:filestorage:InvalidFilePermissions', 'Unable to open file');
        end
        fclose(fid);
        if DO_DELETE
            delete(testFilename);
        end
        % If we successfully wrote a testfile then this is not a read only
        % storage
        obj.IsReadOnly = false;
        % Since we know we can write to the storage location we should look at the
        % current contents to ensure that there we don't accidentally reuse an ID
        % that partially exists.
        obj.myLastJobValue = iGetNextAvailableJobValue(obj.JobLocationString);
    catch %#ok<CTCH>
        if obj.WarnOnPermissionError
            warning('distcomp:filestorage:InvalidFilePermissions', ...
                ['Unable to write to requested directory.\n' ...
                'Perhaps you do not have the correct access permissions.\n'...
                'You will be unable to store any job and tasks here']);
        end
        % Default value for myLastJobValue if we have a read-only location
        obj.myLastJobValue = 0;
    end
catch %#ok<CTCH>
    if obj.WarnOnPermissionError
        warning('distcomp:filestorage:InvalidFilePermissions', ...
            'Unable to change to requested directory. Perhaps you do not have the correct access permissions');
    end
    locationString = '';
    % Default value for myLastJobValue if we have a read-only location
    obj.myLastJobValue = 0;
end
% Change back to the original directory we started in
clear aCleanup

rootMetadataFile = [locationString filesep obj.MetadataFilename];
% Check for the existence of the metadata file and that it is a valid
% matlab file
obj.RootMetadataFileExists = false;
if exist(rootMetadataFile, 'file')
    try
        dummy = load(rootMetadataFile); %#ok<NASGU>
        obj.RootMetadataFileExists = true;
    catch %#ok<CTCH>
        if obj.WarnOnPermissionError
            % Likely that it wasn't a matlab file and that either something has
            % got corrupted or that there was a different file of the same name
            warning('distcomp:filestorage:CorruptFile', ...
                'Unable to read the required metadata file \n %s \n', ...
                rootMetadataFile);
        end
    end
end

%--------------------------------------------------------------------------
%
%--------------------------------------------------------------------------
function iRevertCWDandWarningState(origCWD, warnState)
warning(warnState);
try
    cd(origCWD);
catch %#ok<CTCH>
end

%--------------------------------------------------------------------------
%
%--------------------------------------------------------------------------
function value = iGetNextAvailableJobValue(jobType)
% Default return
value = 0;
try
    % Find all the objects that are of the type job
    files = dir([jobType '*']);
    % Get just the names
    names = {files.name};
    % Return early if there are no names found
    if isempty(names)
        return
    end
    % Find a string of one or more numbers [0-9]+ that is preceded by the string
    % ^Job and followed by either end of line or a '.' character. Only return the 
    % string match which should be either
    %   Numeric characters if it actually matched
    %   Empty strings if it didn't match
    names = regexp(names, ['(?<=^' jobType ')[0-9]+(?=($|\.))'], 'match', 'once');
    % This is likely to have duplicates (of both strings and empty strings) 
    % so reduce to uniqueness
    names = unique(names);
    % And remove the first if it is empty. This is all the strings that
    % didn't match the regexp above - note that as a result of calling unique
    % it can only be the first that is empty
    if isempty(names{1})
        names(1) = [];
    end
    % Return early if there are no names found
    if isempty(names)
        return
    end
    % Convert the numbers to double 
    numbers = cellfun(@(str)sscanf(str, '%d'), names);
    value = max(numbers);
    % Just in case this is empty make sure that we do return a scalar
    % double value as in our contract
    if isempty(value)
        value = 0;
    end
catch %#ok<CTCH>
end
