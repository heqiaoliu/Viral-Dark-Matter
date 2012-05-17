function storage = makeFileStorageObject(location)
%makeFileStorageObject 
%
%  STORAGE = makeFileStorageObject(LOCATION)

%  Copyright 2005-2008 The MathWorks, Inc.

%  $Revision: 1.1.10.2 $    $Date: 2008/03/31 17:08:31 $


pcStart = 'PC{';
pcEnd   = '}:';
unixStart = ':UNIX{';
unixEnd   = '}:';
% The location will be of the form PC{...}:UNIX{...} - thus use lazy (.*?)
% matching for the pc as :} cannot be part of the windows path but greedy
% matching for the unix as it could just be part of the path
pcLocation   = regexp(location, ['^' pcStart '.*?' pcEnd], 'match');
unixLocation = regexp(location, [ unixStart '.*' unixEnd], 'match');
% Was the input of this form? We also accept a simple string which is just a
% directory
if isempty(pcLocation) && isempty(unixLocation)
    xPlatformLocation = location;
else
    % Strip start and end parts off the strings
    pcLocation   = pcLocation{1}(numel(pcStart)+1:end-numel(pcEnd));
    unixLocation = unixLocation{1}(numel(unixStart)+1:end-numel(unixEnd));
    % Make the structure to hold this information
    xPlatformLocation = struct('pc', pcLocation, 'unix', unixLocation);
end
% Return the location 
storage = distcomp.filestorage(xPlatformLocation);
