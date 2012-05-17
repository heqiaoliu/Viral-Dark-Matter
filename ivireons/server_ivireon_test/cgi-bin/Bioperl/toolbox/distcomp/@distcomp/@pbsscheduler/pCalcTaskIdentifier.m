function [taskIdString, arrayID] = pCalcTaskIdentifier( pbs, task, data ) %#ok<INUSL>
; %#ok Undocumented

% Work out the task identifier string - could be 123[45].SERVER, or it could
% be simply 123.SERVER

% Copyright 2007 The MathWorks, Inc.
% $Revision: 1.1.6.1 $   $Date: 2007/11/09 19:50:51 $

taskID = task.ID;

% Calculate the list of submitted tasks with IDs less than the current one
allTasks = 1:taskID;
submittedTasks = setdiff( allTasks, data.skippedTaskIDs );

% Which element in the array of tasks is this one?
arrayID = find( submittedTasks == taskID, 1, 'first' );

if isempty( arrayID )
    % Only get here if the taskID is in the skippedTaskIDs list
    error( 'distcomp:pbsscheduler:jobArrayInconsistency', ...
           'Internal error - couldn''t calculate array index for task ID %d (Skip: %s)', ...
           taskID, sprintf( '%d ', data.skippedTaskIDs ) );
end

if data.usingJobArray
    % Just one job ID
    jobID   = data.pbsJobIds{1};
    taskIdString = strrep( jobID, '[]', sprintf( '[%d]', arrayID ) );
else
    if arrayID > length( data.pbsJobIds )
        error( 'distcomp:pbsscheduler:jobArrayInconsistency', ...
               'Internal error - invalid task index' );
    end
    taskIdString = data.pbsJobIds{arrayID};
end
    