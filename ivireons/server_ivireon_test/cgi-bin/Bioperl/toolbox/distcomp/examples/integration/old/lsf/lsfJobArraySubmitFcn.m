function lsfJobArraySubmitFcn(lsf, job, submitProps)

% Copyright 2006-2010 The MathWorks, Inc.

% Set the relevant environment variables for LSF to transfer to the worker 
% MATLAB processes that will get started up.
setenv('MDCE_DECODE_FUNCTION', 'lsfJobArrayDecodeFcn');
setenv('STORAGE_CONSTRUCTOR' , submitProps.StorageConstructor);
setenv('STORAGE_LOCATION'    , submitProps.StorageLocation);
setenv('JOB_LOCATION'        , submitProps.JobLocation);

% Need to get the array of TaskLocations across to each worker. We really 
% only want each worker to see one entry in the TaskLocations - i.e. the one they
% should pick up and use. However, we also don't want to loop on calling bsub
% as that is very slow - so we need a mechanism for transferring all the 
% TaskLocations and indexing based on LSB_JOBINDEX. We are going to do this with 
% environment variables - T1 being the value of TASK_LOCATION on job index 1 and
% so on. See the decode function for the inverses of this encoding to pick up the
% relevant taskLocation based on the LSB_JOBINDEX
for i = 1:submitProps.NumberOfTasks
    varName = sprintf('T%d', i);
    setenv(varName, submitProps.TaskLocations{i});
end

% On unix we need to protect the matlab command in a single quoted string
% but on windows we need to use double quotes (This is because the string
% might contain something like \\server on unix and the shell interprets
% the \\ as an escaped \ rather than \\ unless we use '. 
if ispc
    quote = '"';
else
    quote = '''';
end
% From the submit properties, what is the correct command to ask LSF to
% start on the cluster
matlabCommand = [ quote submitProps.MatlabExecutable quote ' ' submitProps.MatlabArguments ];
% Choose a file for the output. Please note that currently, DataLocation refers
% to a directory on disk, but this may change in the future. NOTE the use of 
% %I in the name of the log files - this is an LSF feature which is replaced by
% the value of LSB_JOBINDEX on the workers
logFile = [quote fullfile(lsf.DataLocation, ...
                    sprintf('Job%d_LsfTask%%I.log', job.ID)), ...
            quote];
% Submit all the tasks in one go using a job array - the far end will pick
% up the task number automatically using the LSB_JOBINDEX environment
% variable. The submit string below says
% -J "name[1-N]" create a job array with 1-N sub tasks
% -o defines where the stdout is redirected to
% Add any other lsf arguments here as required
submitString = sprintf(...
    'bsub -J "%s[1-%d]" -o %s %s'  , ...
    submitProps.JobLocation, ...
    submitProps.NumberOfTasks, ...
    logFile, ...
    matlabCommand);

try
    % Make the shelled out call to bsub.
    [FAILED, out] = system(submitString);
catch err
    FAILED = true;
    out = err.message;
end

if FAILED
    error('distcomp:genericscheduler:UnableToFindService', ...
        'Error executing the LSF script command ''bsub''. The reason given is \n %s', out);
end
