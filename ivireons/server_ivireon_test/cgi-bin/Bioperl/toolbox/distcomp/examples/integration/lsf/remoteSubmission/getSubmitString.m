function submitString = getSubmitString(jobName, quotedLogFile, quotedCommand, ...
    additionalSubmitArgs)
%GETSUBMITSTRING Gets the correct bsub command for an LSF scheduler

% Copyright 2010 The MathWorks, Inc.
% $Revision: 1.1.6.1 $  $Date: 2010/03/22 03:43:13 $

% Submit to LSF using bsub.  Note the following:
% "-J " - specifies the job name
% "-o" - specifies where standard output goes to (and standard error, when -e is not specified)
% Note that extra spaces in the bsub command are permitted
submitString = sprintf('bsub -J %s -o %s %s %s', jobName, quotedLogFile, additionalSubmitArgs, quotedCommand);
