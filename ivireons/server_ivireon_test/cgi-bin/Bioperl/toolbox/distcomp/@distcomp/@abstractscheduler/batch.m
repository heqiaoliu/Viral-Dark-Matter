function job = batch(obj, scriptName, varargin)
%batch Run MATLAB script or function as batch job
% 
%  j = BATCH(scheduler, 'aScript') runs the script aScript.m on a worker
%  using the identified scheduler.  The function returns j, a handle to the
%  job object that runs the script. The script file aScript.m is added to
%  the FileDependencies and copied to the worker.  If the scheduler
%  object's configuration property is not empty, the configuration is
%  applied to the job and task that run the script.
%
%  j = BATCH(scheduler, fcn, N, {x1,..., xn}) runs the function specified by a 
%  function handle or function name, fcn, on a worker using the identified 
%  scheduler.  The function returns j, a handle to the job object that runs 
%  the function. The function is evaluated with the given arguments, x1,...,xn, 
%  returning N output arguments.  The function file for fcn is added to 
%  the FileDependencies and copied to the worker.  If the scheduler
%  object's configuration property is not empty, the configuration is
%  applied to the job and task that run the script.
%  
%  j = BATCH( ..., P1, V1, ..., Pn, Vn) allows additional parameter-value
%  pairs that modify the behavior of the job.   These parameters support batch
%  for functions and scripts, unless otherwise indicated.  The accepted 
%  parameters are:
%  
%   - 'Workspace' - A 1-by-1 struct to define the workspace on the worker
%     just before the script is called. The field names of the struct
%     define the names of the variables, and the field values are assigned
%     to the workspace variables. By default this parameter has a field for
%     every variable in the current workspace where batch is executed.  
%     This parameter supports only the running of scripts.
%  
%   - 'PathDependencies' - A string or cell array of strings that defines    
%     paths to be added to the workers' MATLAB path before the script or 
%     function is executed. 
%  
%   - 'FileDependencies' - A string or cell array of strings.  Each string
%     in the list identifies either a file or a folder, which is
%     transferred to the worker. If specified as a string then the list is
%     space delimited. By default the script being run is always added
%     to the list of files sent to the worker.
%  
%   - 'CurrentDirectory' - A string to indicate in what folder the
%     script executes. There is no guarantee that this folder exists on
%     the worker. The default value for this property is the cwd
%     of MATLAB when the batch command is executed. If the string for this 
%     argument is '.', there is no change in folder before batch execution.
%  
%   - 'CaptureDiary' - A boolean flag to indicate that diary output should 
%     be retrieved from the function call.  See the DIARY function for how 
%     to return this information to the client.  The default is true.
%  
%   - 'Matlabpool' - A nonnegative scalar integer that defines the number of
%     labs to make into a MATLAB pool for the job to run on. A value of N
%     for the property Matlabpool is equivalent to adding a call to
%     matlabpool N into the script or function. The default is 0, which 
%     causes the script or function to run on only the single worker without 
%     a MATLAB pool. 
%  
%  Examples: 
%  Run a batch script on a worker:
%   jm = findResource('scheduler', 'configuration', defaultParallelConfig);
%   j = batch(jm, 'script1');
%  
%  Run a batch script, capturing the diary, adding a path to the workers
%  and transferring some required files.
%   j = batch(jm, 'script1', 'CaptureDiary', true, ...
%             'PathDependencies', '\\Shared\Project1\HelperFiles',...
%             'FileDependencies', 'script1helper1 script1helper2');
%   % Wait for the job to finish 
%   wait(j) 
%   %Display the diary 
%   diary(j) 
%   % Get the results of running the script in this workspace 
%   load(j)
%
%  Run a batch script on a remote cluster using a pool of 8 workers:
%   j = batch(jm, 'script1', 'matlabpool', 8);
%
%  Run a batch function on a remote cluster that generates a 10-by-10 
%  random matrix
%   j = batch(jm, @rand, 1, {10, 10});
%   % Wait for the job to finish
%   wait(j)
%   % Display the diary
%   diary(j)
%   % Get the results of running the job into a cell array
%   r = getAllOutputArguments(j)
%   % Get the generated random number from r
%   r{1}
%   
%  See Also: batch findResource, distcomp.jobmanager/matlabpool

%  Copyright 2010 The MathWorks, Inc.

%  $Revision: 1.1.6.4 $  $Date: 2010/05/10 17:03:16 $

% Ensure that we have between 2 and Inf input arguments
% (must have a script name), but don't use standard nargchk so users don't
% get confused between input arguments to batch and nargin/nargout
% required by their function handle.
parallel.internal.cluster.checkNumberOfArguments('input', 2, inf, nargin, mfilename);

% Get the name of the object that we wish to appear in the error
% identifiers and messages (i.e. "jobmanager" for distcomp.jobmanager and
% "localscheduler" for distcomp.localscheduler.  This is required because
% the @jobmanager/batch.m file is copied to @abstractscheduler.
className = class(obj);
% strip off any package names
className = strread(className, '%s', 'delimiter', '.');
objectNameToUseForErrors = className{end};

% Parse the arguments in
try
    batchHelper = parallel.internal.cluster.BatchHelper(scriptName, varargin);
catch err
    % Make all errors appear from batch
    throw(err);
end

% Deal with the Workspace and configuration Set the WorkspaceIn to the
% caller if one wasn't supplied Note that this code has to exist here
% because multiple evalin calls cannot be nested.  This code can't even be
% put into a script, because evalin('caller') from the script just gets
% this function's workspace and not the caller of this function. If you
% change this code, make sure you change the version in batch.m
% as well.
if batchHelper.needsCallerWorkspace
    where = 'caller';
    % No workspace supplied - we need to make our own from the calling workspace
    vars = evalin(where, 'whos');
    workspace = cell2struct(repmat({[]}, numel(vars), 1), {vars.name}, 1);
    pctFieldsToRemove = {};
    % Loop over each variable in the calling workspace and assign it into part
    % of the workspace structure
    for i = 1:numel(vars)
        thisName =  vars(i).name;
        thisValue = evalin(where, thisName);
        % DO NOT send across PCT objects as we know they don't serialize
        % correctly
        if isa(thisValue, 'distcomp.object')
            pctFieldsToRemove{end + 1} = thisName; %#ok<AGROW>
        else
            workspace.(thisName) = thisValue;
        end
    end
    % Are there any fields to remove?
    if ~isempty(pctFieldsToRemove)
        workspace = rmfield(workspace, pctFieldsToRemove);
    end      
    batchHelper.setCallerWorkspace(workspace);
end

% Check that a configuration is not set in the args
if ~isempty(batchHelper.Configuration)
    error(sprintf('distcomp:%s:InvalidArgument', objectNameToUseForErrors), ...
        'The batch method of a %s object does not accept a configuration.', objectNameToUseForErrors);
end
batchHelper.Configuration = obj.Configuration;

% Actually run batch on the scheduler
try
    job = batchHelper.doBatch(obj);
catch err
    % Make all errors appear from batch
    throw(err);
end
