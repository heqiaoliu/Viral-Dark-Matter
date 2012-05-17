function lsfSimpleSubmitFcn(lsf, job, submitProps)

% Copyright 2006-2010 The MathWorks, Inc.

% Set the relevant environment variables for LSF to transfer to the worker 
% MATLAB processes that will get started up. These are needed to tell the 
% workers what decode function to run, and where to find the relevant files 
% on disk
setenv('MDCE_DECODE_FUNCTION', 'lsfSimpleDecodeFcn');
setenv('STORAGE_CONSTRUCTOR' , submitProps.StorageConstructor);
setenv('STORAGE_LOCATION'    , submitProps.StorageLocation);
setenv('JOB_LOCATION'        , submitProps.JobLocation);


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

% Get the tasks for use in the loop
tasks = job.Tasks;

% Loop over every task we have been asked to submit
for i = 1:submitProps.NumberOfTasks

    % Set the environment variable that defines the location of this task
    setenv('TASK_LOCATION', submitProps.TaskLocations{i});

    % Choose a file for the output. Please note that currently, DataLocation refers
    % to a directory on disk, but this may change in the future.
    logFile = [ quote ...
                fullfile(lsf.DataLocation, ...
                        sprintf('Job%d_Task%d.log', job.ID, tasks(i).ID)) ...
                quote ];

    % Submit one task at a time as a LSF job using bsub
    % Add any other lsf arguments here as required
    submitString = sprintf('bsub -o %s %s', logFile, matlabCommand);
    
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

end
