function string = pMakeTaskIDString(lsf, tasks)
; %#ok Undocumented
%pMakeTaskIDString make the LSF job array string for the correct task ID
%
% If a task has been destroyed prior to be submitted then it is possible
% that the list of filenames we will use is not appropriate to the job
% index array. Thus we need to ensure that the list of indices we pass to
% lsf is correct.

%  Copyright 2005-2008 The MathWorks, Inc.

%  $Revision: 1.1.10.4 $    $Date: 2008/03/31 17:07:43 $ 

numTasks = numel(tasks);
% We know that ID's are monotonically increasing so firstly lets check if
% no tasks have been deleted - probably the most common case
if tasks(end).ID == numTasks
    string = sprintf('1-%d', numTasks);
    return
end

% Get all the IDs as a cell array
IDs = get(tasks, {'ID'});
[IDs, index] = sort([IDs{:}]);

% Check that the IDs were originally in a monotonic order
if ~isequal(index, 1:numel(index))
    % Should never get here
    error('distcomp:lsfscheduler:InvalidState', 'Invalid Task order detected - please destroy the job and start again');
end

% The format of the string is 1-N1,N2,N3-N4,N5,N6 ...

% Deduce the difference between subsequent ID's
deltaIDs = diff(IDs);
% Define a cell array to hold the output - starts of ranges will be the
% first in a series of diffs of 1.
out = cell(numTasks, 1);
% Ensure we start with a range and not in a range
lastDiff = 2;
% Loop over each diff
for i = 1:numel(deltaIDs)
    % Get this ID and the difference to the next
    thisID = IDs(i);
    thisDiff = deltaIDs(i);
    if thisDiff > 1
        % If the diff to the next is more than 1 then we are either at the
        % end of a range or on a singleton number, so simply print the
        % number followed by a comma
        out{i} = sprintf('%d,', thisID);        
    elseif thisDiff == 1
        % If the diff is one is this the start of a range or are we in a
        % range. If the last wasn't 1 then this is the start of a range
        if lastDiff > 1
            out{i} = sprintf('%d-', thisID);
        end
    else 
        % Should never get here
        error('distcomp:lsfscheduler:InvalidState', 'Duplicate Task ID''s found');
    end
    % Remember the last difference
    lastDiff = thisDiff;
end
% Finally always add the last number, irrespective of what has happened
out{numTasks} = sprintf('%d', IDs(numTasks));
% Now remove all the empty cells
out(cellfun('isempty', out)) = [];
% And concatenate the whole lot together.
string = strcat(out{:});

