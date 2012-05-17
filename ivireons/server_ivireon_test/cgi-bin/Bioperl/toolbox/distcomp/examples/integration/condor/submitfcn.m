function submitfcn(scheduler, job, props, extraCondorSubmitArgs) %#ok Not using job
%SUBMITFCN Submit a Matlab job to a Condor scheduler
%
% See also workerDecodeFunc.
%
% Assign the relevant values to environment variables, starting 
% with identifying the decode function to be run by the worker:
decodeFcn = 'workerDecodeFunc';
if nargin < 4
    extraCondorSubmitArgs = '';
end
% Ask the workers to print debug messages by default by setting MDCE_DEBUG to
% true.
jobEnvVars = {'MDCE_DECODE_FUNCTION', decodeFcn, ...
              'MDCE_STORAGE_LOCATION', props.StorageLocation, ...
              'MDCE_STORAGE_CONSTRUCTOR', props.StorageConstructor, ...
              'MDCE_JOB_LOCATION', props.JobLocation, ...
              'MDCE_DEBUG', 'true'}; 
taskEnvVars = cell(1, numel(props.TaskLocations));
for i = 1:numel(props.TaskLocations)
    taskEnvVars{i} = {'MDCE_TASK_LOCATION', props.TaskLocations{i}};
end
if isempty(scheduler.ClusterMatlabRoot)
    warning('distcomp:condor:NoClusterMatlabRoot', ...
            ['The scheduler''s ClusterMatlabRoot property is empty.\n', ...
             'Using  matlabroot  instead.']);
    clusterMatlabRoot = matlabroot;
else
    clusterMatlabRoot = scheduler.ClusterMatlabRoot;
end
matlabScript = fullfile(clusterMatlabRoot, 'bin', 'matlab');
% ... Do we need the following ??? ...
if ispc
    matlabScript = [matlabScript, '.bat'];
end
matlabArgs = strrep(scheduler.matlabCommandToRun, 'matlab ', '');

% Determine where to save the standard output, standard error and the
% Condor log.
logFiles = cell(1, props.NumberOfTasks);
outFiles = cell(1, props.NumberOfTasks);
errFiles = cell(1, props.NumberOfTasks);
for i = 1:props.NumberOfTasks
    taskLoc = fullfile(scheduler.DataLocation, props.TaskLocations{i});
    logFiles{i} = [taskLoc, '.log'];
    outFiles{i} = [taskLoc, '.out'];
    errFiles{i} = [taskLoc, '.err'];
end

% Create one condor submit file for all the tasks.
script = createCondorSubmitScript(matlabScript, matlabArgs, ...
                                  jobEnvVars, taskEnvVars, ...
                                  errFiles, outFiles, logFiles);
% Submit a Condor job that executes all the tasks:
condorSubmitCommand = ['condor_submit ', script, ' ', extraCondorSubmitArgs];
[s, w] = system(condorSubmitCommand);
% Leave behind the necessary debugging information if the submission failed.
if s ~= 0
    warning('distcomp:condor:SubmitFailed', ...
            ['Call to condor_submit failed with the following message:\n\n', ...
             '    %s\n\n', ...
             'The submit command used was:\n\n    %s\n\n', ...
             'Not deleting the submission file %s.'], ...
             w, condorSubmitCommand, script);
else
    % Display the Condor job number:
    disp(w);
    % Clean up:
    delete(script);
end

function filename = createCondorSubmitScript(matlabScript, matlabArgs, jobEnvVars, taskEnvVars, errFiles, outFiles, logFiles)
%Create a Condor submit script that forwards the correct environment variables
%and executes Matlab.

% We assume that the decode function has been put on the path of the MATLAB
% workers, e.g. by putting it into $MATLABROOT/toolbox/local.

% Double all backslashes so fprintf prints out a single backslash.
matlabScript = strrep(matlabScript, '\', '\\');
matlabArgs = strrep(matlabArgs, '\', '\\');
jobEnvVars = strrep(jobEnvVars, '\', '\\');
for i = 1:numel(taskEnvVars)
    taskEnvVars{i} = strrep(taskEnvVars{i}, '\', '\\');
end
outFiles = strrep(outFiles, '\', '\\');
errFiles = strrep(errFiles, '\', '\\');
logFiles = strrep(logFiles, '\', '\\');

condorHeader = [ 'Universe            = vanilla\n', ...
                 'Executable          = %s\n', ...
                 'Transfer_Executable = false\n', ...
                 'Notification        = Error\n\n\n'];
taskString   = ['Arguments            = %s\n', ...
                'Environment          = %s\n', ...
                'Error                = %s\n', ...
                'Output               = %s\n', ...
                'Log                  = %s\n', ...
                'Queue\n\n'];
filename = tempname;
fid = fopen(filename, 'wt');
fprintf(fid, condorHeader, matlabScript);

for i = 1:numel(taskEnvVars)
    % Create a cell-array of all the environment variables we want to set
    % for the current task, and transform it into a string for the Condor
    % script.
    envString = createCondorEnvString({jobEnvVars{:}, taskEnvVars{i}{:}});
    % Append a clause to the Condor script to queue the current task.
    fprintf(fid, taskString, matlabArgs, envString, errFiles{i}, outFiles{i}, logFiles{i});
end
fclose(fid);

function envString = createCondorEnvString(envVars)
%envStr = createCondorEnvString(envVars)
%  envVars should be a cell arra of even length.  The even entries are 
%  the environment variables, the odd entries are their values.

% In Condor, environment variables are specified in UNIX as
%  Environment = var1=val1;var2=val2;...varn=valn
% and on Windows, the separator is '|' instead of ';', i.e. the format is
%  Environment = var1=val1|var2=val2|...varn=valn

if ispc
    envSep = '|';
else
    envSep = ';';
end
envString = '';
for i = 1:2:numel(envVars)
    envString = [envString, envVars{i}, '=', envVars{i + 1}, envSep];
end
