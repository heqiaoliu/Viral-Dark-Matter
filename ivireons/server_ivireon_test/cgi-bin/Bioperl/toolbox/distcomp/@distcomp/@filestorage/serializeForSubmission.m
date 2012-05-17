function serializeForSubmission(storage, job)
; %#ok Undocumented
%pSerializeForSubmission 
%
%  pSerializeForSubmission(STORAGE, JOB)

%  Copyright 2005-2008 The MathWorks, Inc.

%  $Revision: 1.1.10.4 $    $Date: 2008/03/31 17:07:30 $

% Get the job and task entity locations
jobLocation = job.pGetEntityLocation;
taskLocations = storage.getEntityLocations(jobLocation);
% Remember to prepend the storageLocation
storageLocation = storage.StorageLocation;
% Zip the job up
zip([storageLocation filesep jobLocation '.zip'], ...
    [strcat(jobLocation, storage.Extensions) ; storage.pGetMetadataFilename('')], ...
    storageLocation);
% And the tasks
for i = 1:numel(taskLocations)
    zip([storageLocation filesep taskLocations{i} '.zip'], ...
        strcat(taskLocations{i}, storage.Extensions), ...
        storageLocation);
end
