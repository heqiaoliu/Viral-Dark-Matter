function job = batch(scriptName, varargin)
%BATCH Run MATLAB script or function as batch job
% 
%  j = BATCH('aScript') runs the script aScript.m on a worker according to
%  the scheduler defined in the default parallel configuration.  The
%  function returns j, a handle to the job object that runs the script. The
%  script file aScript.m is added to the FileDependencies and copied to the
%  worker.
%
%  j = BATCH(schedObj, 'aScript') is identical to BATCH('aScript') except 
%  that the script runs on a worker using the scheduler identified by the
%  object schedObj.  
%
%  j = BATCH(fcn, N, {x1,..., xn}) runs the function specified by a 
%  function handle or function name, fcn, on a worker according to the 
%  scheduler defined in the default parallel configuration.  The function 
%  returns j, a handle to the job object that runs the function. The 
%  function is evaluated with the given arguments, x1,...,xn, returning 
%  N output arguments.  The function file for fcn is added to the 
%  FileDependencies and copied to the worker.
%
%  j = BATCH(scheduler, fcn, N, {x1,..., xn}) is identical to 
%  BATCH(fcn, N, {x1,..., xn}) except that the function runs on a worker 
%  using the scheduler identified by the object schedObj.  
%  
%  j = BATCH( ..., P1, V1, ..., Pn, Vn) allows additional parameter-value
%  pairs that modify the behavior of the job.  These parameters support batch
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
%   - 'Configuration' - A single string that is the name of a parallel
%     configuration to use to identify the scheduler.  If this option is 
%     omitted, the default configuration is used to identify the scheduler.
%     If you want the configuration's settings applied to the job properties, 
%     you must explicitly specify the configuration, even if using the 
%     default.  To apply properties from the default parallel configuration, 
%     specify it with 
% 
%       BATCH(...,'Configuration', defaultParallelConfig)
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
%  Examples: Run a batch script on a worker:
%   j = batch('script1');
%  
%  Run a batch script, capturing the diary, adding a path to the workers
%  and transferring some required files
%   j = batch('script1', 'CaptureDiary', true, ...
%             'PathDependencies', '\\Shared\Project1\HelperFiles',...
%             'FileDependencies', 'script1helper1 script1helper2');
%   % Wait for the job to finish
%   wait(j)
%   % Display the diary
%   diary(j)
%   % Get the results of running the script in this workspace
%   load(j)
%
%  Run a batch job on a remote cluster using a pool of 8 workers:
%   j = batch('script1', 'matlabpool', 8);
%   
%  Run a batch job on a local worker, which employs two other
%  local workers:
%   j = batch('script1', 'configuration', 'local', 'matlabpool', 2);
%
%  Run a batch function on a remote cluster that generates a 10-by-10 
%  random matrix
%   jm = findResource('scheduler', 'configuration', defaultParallelConfig);
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
%  See Also: distcomp.job/load, distcomp.job/diary distcomp.jobmanager/batch 
%            distcomp.abstractscheduler/batch 

%  Copyright 2007-2010 The MathWorks, Inc.

% $Revision: 1.1.6.11 $  $Date: 2010/05/10 17:02:58 $

% Ensure that we have between 1 and Inf input arguments
% (must have a script name), but don't use standard nargchk so users don't
% get confused between input arguments to batch and nargin/nargout
% required by their function handle.
parallel.internal.cluster.checkNumberOfArguments('input', 1, inf, nargin, mfilename);

% Parse the inputs
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
% change this code, make sure you change the version in @jobmanager/batch.m
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

% Configuration
if isempty(batchHelper.Configuration)
    batchHelper.Configuration = defaultParallelConfig;
end
% Get the scheduler to use on this job
scheduler = distcomp.pGetScheduler(batchHelper.Configuration);

% Actually run batch on the scheduler
try
    job = batchHelper.doBatch(scheduler);
catch err
    % Make all errors appear from batch
    throw(err);
end
