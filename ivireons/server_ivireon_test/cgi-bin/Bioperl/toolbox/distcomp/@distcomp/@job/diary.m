function diary(job, filename)
%DIARY Display or save text of batch job.
%   DIARY(JOB) displays the command window output from the batch job 
%   in the MATLAB command window. The command window output will only be
%   captured if the batch job had the CaptureDiary property set to true.
%
%   DIARY(JOB, FILENAME) causes a copy of the command window output from
%   the batch job to be appended to the named file.
%
%   See also: BATCH

%  Copyright 2007 The MathWorks, Inc.

% $Revision: 1.1.6.1 $  $Date: 2007/11/09 19:50:27 $

% Bail from here if the job is not a batch job
try 
    distcomp.errorIfNotBatchJob(job);
catch exception
    throw(exception)
end

% No filename supplied then just print out the diary
if nargin == 1
    disp(job.Tasks(1).CommandWindowOutput);
    return
end

if ~( ischar(filename) && isvector(filename) && size(filename, 1) == 1 )
    error('distcomp:job:InvalidArgument', 'The filename input to diary must be a valid 1 x N string array');
end

% Open the diary file
[fid, errMsg] = fopen(filename, 'a');

if fid == -1
    error('distcomp:job:CantAppendToFile', 'Unable to open filename %s for appending.\nReason: %s', filename, errMsg);
end

try
    caughtError = false;
    fwrite(fid, job.Tasks(1).CommandWindowOutput, 'char');
catch exception
    caughtError = true;    
end
fclose(fid);
if caughtError
    rethrow(exception);
end