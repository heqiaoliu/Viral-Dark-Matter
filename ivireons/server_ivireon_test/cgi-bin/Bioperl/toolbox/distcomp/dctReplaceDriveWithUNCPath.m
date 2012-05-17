function filename = dctReplaceDriveWithUNCPath(filename)
; %#ok Undocumented
%dctReplaceDriveWithUNCPath convert a mapped drive file to a UNC one
%
% UNCFILENAME = dctReplaceDriveWithUNCPath(DRIVEFILENAME)
%
% If DRIVEFILENAME starts with a mapped drive this will be replaced with
% the UNC equivalent otherwise the filename will be left unchanged

% Copyright 2005-2006 The MathWorks, Inc.

% If we are on a PC make sure we convert to a UNC path rather than a
% locally mapped drive as it is unlikely that the far end will have the
% same drive mappings on the local system account
if ~ispc
    return
end
% Does the filename begin with letter:?
driveLetter = regexp(filename, '^[A-Za-z]:', 'match', 'once');
% 
if ~isempty(driveLetter)
    % Reduce to just the drive letter
    driveLetter = driveLetter(1:2);
    % Convert using windows API function to a UNC path
    uncPath = getUncPathFromMappedDrive(driveLetter);
    % Only bother if it actually returns a UNC path
    if ~isempty(uncPath)
        filename = [uncPath filename(3:end)];
    end
end

