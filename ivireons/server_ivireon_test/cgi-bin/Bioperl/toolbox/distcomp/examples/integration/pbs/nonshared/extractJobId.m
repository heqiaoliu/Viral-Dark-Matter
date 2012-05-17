function jobID = extractJobId(cmdOut)
% Extracts the job ID from the qsub command output for PBS

% Copyright 2010 The MathWorks, Inc.
% $Revision: 1.1.6.1 $  $Date: 2010/03/22 03:43:15 $


% jobId should be in the following format:
% 123.server-name

% The second piece of the regexp must pick out valid (fully-qualified) server names
jobID = regexp(cmdOut, '[0-9\[\]]+\.[a-zA-Z0-9-\.]*', 'match', 'once');
dctSchedulerMessage(0, '%s: Job ID %s was extracted from qstat output %s.', mfilename, jobID, cmdOut);

