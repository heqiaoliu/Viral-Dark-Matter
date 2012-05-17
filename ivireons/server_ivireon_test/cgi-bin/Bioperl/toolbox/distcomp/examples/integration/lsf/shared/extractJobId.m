function jobID = extractJobId(cmdOut)
% Extracts the job ID from the bsub command output for LSF

% Copyright 2010 The MathWorks, Inc.
% $Revision: 1.1.6.1 $  $Date: 2010/03/22 03:43:12 $

% The output of bsub will be:
% Job <327> is submitted to default queue <normal>.
jobNumberStr = regexp(cmdOut, 'Job <[0-9]*>', 'once', 'match');
jobID = sscanf(jobNumberStr, 'Job <%d>');
dctSchedulerMessage(0, '%s: Job ID %d was extracted from bsub output %s.', mfilename, jobID, cmdOut);

