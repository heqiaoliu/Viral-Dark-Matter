classdef BatchHelper < handle
% Helper Class for activities related to batch

%  Copyright 2010 The MathWorks, Inc.

%  $Revision: 1.1.6.4 $  $Date: 2010/05/03 16:03:41 $

    properties (Constant)
        % The job's Tag property
        JobTag = 'Created_by_batch';
    end
    
    properties
        % Note that configuration may need to be set by the 
        % batch function, hence it is publicly accessible.
        Configuration = '';
    end

    properties (Constant, GetAccess = private)
        EmptyScriptTaskStruct = struct('ScriptName', '', 'WorkspaceIn', struct([]));
        EmptyFunctionTaskStruct = struct('FunctionToRun', [],'NumArgsOut', [], 'ArgsIn', {});
        % Are we going to allow users to specfy an array of scripts/functions to run?
        AllowVectorizedBatch = false;
    end

    properties (Constant, GetAccess = private)
        InvalidScriptOrFunctionError = parallel.internal.cluster.BatchHelper.getInvalidScriptOrFunctionError;
    end
    
    properties (Access = private)
        % The parameters that users can specify via P-V pairs to batch.
        % Note that we need to know whether or not the user actually
        % specified all of these parameters so we can pass them to 
        % createJob and createTask correctly.
        % Args related only to batch - note that Configuration is publicly
        % accessible
        PoolSize = 0;
        UserSpecifiedPoolSize = false;
        WorkerCWD = '';
        UserSpecifiedWorkerCWD = false;
        % Args related to jobs
        JobName = '';
        UserSpecifiedJobName = false;
        FileDependencies = {};
        UserSpecifiedFileDependencies = false;
        PathDependencies = {};
        UserSpecifiedPathDependencies = false;
        % Args related to tasks
        % NB Default for CaptureDiary is true
        CaptureDiary = true;
        UserSpecifiedCaptureDiary = false;

        UserSpecifiedConfiguration = false;
        UserSpecifiedWorkspace = false;

        % Other properties
        IsRunScript = false;
        % A structure to store the tasks themselves
        TasksToRun;
    end
    
    % Public get/set methods
    methods
        function set.Configuration(obj, configName)
            % Check the that the configuration is actually exists
            % before setting it.  If the configName was an empty string, then 
            % just set it.
            if isempty(configName) && ischar(configName)
                obj.Configuration = configName;
                return;
            end
            if ~iIsString(configName)
                error('distcomp:batch:InvalidArgument', ...
                    'Configuration must be a string.');
            end
            if  ~any(strcmpi(configName, getDistcompConfigurationNames))
                error('distcomp:config:NoSuchConfiguration', ...
                    ['''%s'' is not a valid configuration name.\n'...
                    'Use [conf, allConf] = defaultParallelConfig to see all your configurations.'], ...
                    configName);
            end
            obj.Configuration = configName;
        end
    end
    
    % Public methods
    methods 
        % -------------------------------------------------------------------------
        % constructor
        % -------------------------------------------------------------------------
        function obj = BatchHelper(scriptOrFunctionToRun, args)
            import parallel.internal.cluster.BatchHelper;

            % After the call to checkIfScriptSupplied, we know that scriptOrFunctionToRun 
            % must be one of the following (otherwise it would have errored):
            % If a script:
            %   a string,
            %   an array of strings, 
            %   a cell array of strings.  
            %
            % If a function:
            %   a string, 
            %   a function handle, 
            %   a cell array of function handles, 
            %   an array of strings, 
            %   a cell array of strings,
            %   a cell array of strings and function handles.
            possibleNargout = [];
            if ~isempty(args)
                possibleNargout = args{1};
            end
            obj.IsRunScript = obj.checkIfScriptSupplied(scriptOrFunctionToRun, possibleNargout);

            % If running a function, then we need to have at least 1 arg - the 
            % number of output arguments for the task
            if ~obj.IsRunScript && isempty(args)
                error('distcomp:batch:InvalidInput', ...
                    'Number of output arguments must be specified when calling batch with a function.');
            end
            
            % Convert scriptOrFunctionToRun to a cell array
            if ~iscell(scriptOrFunctionToRun) 
                if ischar(scriptOrFunctionToRun)
                    scriptOrFunctionToRun = cellstr(scriptOrFunctionToRun);
                else
                    scriptOrFunctionToRun = {scriptOrFunctionToRun};
                end
            end

            if obj.IsRunScript
                obj.parseScriptInputs(scriptOrFunctionToRun, args);
            else
                obj.parseFunctionInputs(scriptOrFunctionToRun, args);
            end
        end
        
        % -------------------------------------------------------------------------
        % needsCallerWorkspace
        % -------------------------------------------------------------------------
        % Do we need the caller workspace to be set for the single script task?
        function needsWorkspace = needsCallerWorkspace(obj)
            % The only scenario in which we need the caller workspace
            % is if there is only 1 task to run, and that task happens 
            % to be a script and there is no workspace associated with it, and that
            % empty workspace was not user specified.
            needsWorkspace = obj.IsRunScript && (numel(obj.TasksToRun) == 1) && ...
                isempty(obj.TasksToRun(1).WorkspaceIn) && ~obj.UserSpecifiedWorkspace;
        end
        
        % -------------------------------------------------------------------------
        % setCallerWorkspace
        % -------------------------------------------------------------------------
        % Set the task's workspace.  This is only supported if there we are running 
        % scripts, there is only 1 task and that task currently does not have a workspace.
        function setCallerWorkspace(obj, workspaceIn)
            if ~obj.needsCallerWorkspace
                error('distcomp:batch:CallerWorkspaceNotSupported', ...
                    'The batch tasks do not require a caller workspace to be set.');
            end
           if ~isstruct(workspaceIn)
               error('distcomp:batch:InvalidInput', ...
                   'The caller workspace for batch must be a structure.');
            end
            obj.TasksToRun(1).WorkspaceIn = workspaceIn;
        end

        % -------------------------------------------------------------------------
        % doBatch
        % -------------------------------------------------------------------------
        % Actually creates and submits the job for the batch command/method
        % to the provided scheduler.  
        function job = doBatch(obj, sched)
            % Decide which job constructor to use.
            if obj.PoolSize > 0
                jobConstructor = @createMatlabPoolJob;
            else
                jobConstructor = @createJob;
            end
            % Create a normal DCT job with the appropriate PoolSize
            jobPVPairs = obj.getCreateJobInputs;
            job = jobConstructor(sched, jobPVPairs{:});
            
            % If anything fails from here we need to destroy the job as it won't be
            % passed back to the user
            try
                [functionToRun, numArgsOut, allArgsIn, taskPVPairs] = obj.getCreateTaskInputs();
                % Create a task that will call executeScript
                job.createTask(functionToRun, numArgsOut, allArgsIn, taskPVPairs{:});
                % Submit the job
                job.submit;
            catch exception
                % Any error - we need to destroy the job
                [~, undoc] = pctconfig();
                if ~undoc.preservejobs
                    job.destroy    
                end
                rethrow(exception)
            end
        end

        % -------------------------------------------------------------------------
        % doDebugDisplay
        % -------------------------------------------------------------------------
        % For debug purposes only.  Display all the properties in a nice 
        % format.  Use a custom method name so as not to override the 
        % default display behaviour (since this displays private
        % properties)
        function doDebugDisplay(obj)
            fprintf('\tProperty\t\tUserSpec?\tValue\n');
            fprintf('\t--------\t\t---------\t-----\n');
            fprintf('\tConfiguration\t\t%d\t\t%s\n',  obj.UserSpecifiedConfiguration, obj.Configuration);
            fprintf('\tPoolSize\t\t%d\t\t%d\n', obj.UserSpecifiedPoolSize, obj.PoolSize);
            fprintf('\tWorkerCWD\t\t%d\t\t%s\n', obj.UserSpecifiedWorkerCWD, obj.WorkerCWD);
            fprintf('\tJobName\t\t\t%d\t\t%s\n', obj.UserSpecifiedJobName, obj.JobName);
            fprintf('\tFileDependencies\t%d\t\t%s\n', obj.UserSpecifiedFileDependencies, sprintf('%s ', obj.FileDependencies{:}));
            fprintf('\tPathDependencies\t%d\t\t%s\n', obj.UserSpecifiedPathDependencies, sprintf('%s ', obj.PathDependencies{:}));
            fprintf('\tCaptureDiary\t\t%d\t\t%d\n', obj.UserSpecifiedCaptureDiary, obj.CaptureDiary);
            
            fprintf('\n\tIsRunScript: %d\n', obj.IsRunScript);
            fprintf('\t%d Tasks:\n\n', numel(obj.TasksToRun))
            
            if obj.IsRunScript
                fprintf('\tScriptName\tWorkspace Fields\n');
                fprintf('\t----------\t----------------\n');
            else
                fprintf('\tFunction\tnargout\tnargin\n');
                fprintf('\t--------\t-------\t------\n');
            end

            for ii = 1:numel(obj.TasksToRun)
                task = obj.TasksToRun(ii);
                if obj.IsRunScript
                    wkspacefields = fields(task.WorkspaceIn);
                    fprintf('\t%s\t%s\n', task.ScriptName, sprintf('%s ', wkspacefields{:}));
                else
                    functionName = task.FunctionToRun;
                    if isa(functionName, 'function_handle')
                        functionName = func2str(functionName);
                    end
                    fprintf('\t%s\t%d\t%d\n', functionName, task.NumArgsOut, numel(task.ArgsIn));
                end
            end
        end
    end
    
    methods (Access = private)
        % -------------------------------------------------------------------------
        % parseFunctionInputs
        % -------------------------------------------------------------------------
        % Parse the input args to batch when the first argument represents the functions
        % that need to run.
        function parseFunctionInputs(obj, functionsToRun, args)
            % If the input to batch was a function handle(or array of function handles), 
            % then args{1} = nargout (or array of nargouts)
            % and args{2} = cell array of input arguments, or the start of the P-V pairs to batch
            % We allow the following:
            % 1 function + 1 nargout + 1 nargin
            % 1 function + 1 nargout + 1..n nargin
            % n functions + n nargout + n nargin
             
            % If we get into here, we already know that args{1} is a valid nargout argument
            % (it is checked in the constructor)
            numArgsOut = args{1};
            % Always remove the nargout from the args
            argIndexToRemove = 1;
            % Now check if the next arg is an input argument array
            functionInputArgs = {};
            if length(args) > 1
                functionInputArgs = args{2};
                if iIsString(functionInputArgs)
                    % User didn't specify any input arguments, and arg(2) is actually the first of the P-V pairs
                    % so set the input args to an empty cell.
                    functionInputArgs = {};
                else
                    % Remove both the nargout and argsin from the args
                    argIndexToRemove = 1:2;
                end
            end

            inputArgumentsError = MException('distcomp:batch:InvalidArgument', ...
                'Input arguments parameter to batch must be a cell array of vector cell arrays, or a vector cell array');
            if ~iscell(functionInputArgs)
                throw(inputArgumentsError);
            end

            % Check the functionsToRun, numArgsOut and functionInputArgs for consistency.
            isVectorized = ~isempty(functionInputArgs) && all(cellfun(@iscell, functionInputArgs(:)));
            
            % Check the functionInputArgs
            if isVectorized
                obj.errorIfVectorizedBatchNotAllowed;
                if ~all(cellfun(@isvector, functionInputArgs(:)) | cellfun(@isempty, functionInputArgs(:)))
                    throw(inputArgumentsError);
                end
            else
                if ~(isvector(functionInputArgs) || isempty(functionInputArgs))
                    throw(inputArgumentsError);
                end
                % Convert to a 1 x 1 cell array
                functionInputArgs = {functionInputArgs};
            end

            % Check functionsToRun
            if numel(functionsToRun) == 1
                % Make functionsToRun the same size as functionInputArgs
                functionsToRun = repmat(functionsToRun, size(functionInputArgs));
            else
                % Check functionsToRun is the same size as functionInputArgs
                if ~isequal(size(functionsToRun), size(functionInputArgs))
                    error('distcomp:batch:InvalidArgument', ...
                        'Cell array of input functions must be the same size as the cell array of input arguments');
                end
            end
            
            % Check numArgsOut
            if numel(numArgsOut) == 1
                % Make numArgsOut the same size as functionInputArgs
                numArgsOut = repmat(numArgsOut, size(functionInputArgs));
            else
                if ~isequal(size(numArgsOut), size(functionInputArgs))
                    % Check numArgsOut is the same size as functionInputArgs
                    error('distcomp:job:InvalidArgument', ...
                        'NumberOfOutputArguments must be the same size as the cell array of input arguments');
                end
            end

            % Remove the relevant arguments from the args
            args(argIndexToRemove) = [];
            % Now parse the rest of the (common) arguments.
            obj.parseCommonInputs(args);

            % Pre-allocate the tasks structure
            obj.TasksToRun = repmat(obj.EmptyFunctionTaskStruct, numel(functionsToRun), 1);
            % Sort out the args for the tasks
            for ii = 1:numel(functionsToRun)
                obj.TasksToRun(ii).FunctionToRun = functionsToRun{ii};
                obj.TasksToRun(ii).NumArgsOut = numArgsOut(ii);
                obj.TasksToRun(ii).ArgsIn = functionInputArgs{ii};
            end
            
            % Make sure the scripts are added to the filedependencies and job name
            obj.addFileDependenciesAndJobName(functionsToRun);

            % And check that matlabpool is set to 0 if we are in vectorized mode
            if isVectorized && obj.UserSpecifiedPoolSize && (obj.PoolSize > 0)
                error('distcomp:batch:InvalidInput', ...
                    'The matlabpool argument to batch must be 0 or unspecified when running vectorized functions');
            end
        end
        
        % -------------------------------------------------------------------------
        % parseScriptInputs
        % -------------------------------------------------------------------------
        % Parse the input args to batch when the first argument represents the scripts
        % that need to run.
        function parseScriptInputs(obj, scriptsToRun, args)
            % We can have one of the following: 
            % 1 script + 0..1 workspaces = 1 task, or nTasks = nScripts
            % 1 script + 2..n workspaces = 2..n tasks, or nTasks = nWorkspaces
            % n scripts + n workspaces = n tasks, or nTasks = nScripts
            
            % Find the workspace PV pair
            workspaceIndex = find(strcmpi('Workspace', args));
            workspaceValue = struct([]);
            argIndexToRemove = [];
            if ~isempty(workspaceIndex)
                % We found a workspace p, now see if we can find the v
                if numel(args) <= workspaceIndex
                    error('distcomp:batch:InvalidPVPair', ...  
                        'The ''Workspace'' property must have a value.');
                end
                workspaceValue = args{workspaceIndex+1};
                obj.UserSpecifiedWorkspace = true;
                
                if ~isstruct(workspaceValue)
                   error('distcomp:batch:InvalidInput', ...
                       'The workspace argument to batch must be a structure or a structure array');
                end
                % Remove the workspace PV pair from the args
                argIndexToRemove = workspaceIndex:workspaceIndex+1;
            end
            
            numScriptsSupplied = numel(scriptsToRun);
            numWorkspaces = numel(workspaceValue);
            isVectorized = (numScriptsSupplied > 1) || (numWorkspaces > 1);
            if isVectorized
                obj.errorIfVectorizedBatchNotAllowed;
            end

            % Check for consistency between scripts and workspaces
            % If more than 1 script was specified, then there must be a corresponding
            % number of workspaces.  Note that it is OK to have 1 script, but multiple
            % workspaces.
            if (numScriptsSupplied > 1) && ~isequal(size(workspaceValue), size(scriptsToRun))
               error('distcomp:batch:InvalidInput', ...
                   'The workspace argument to batch must be the same size as the array of script names.');
            end
            if (numScriptsSupplied == 1) && (numWorkspaces > numScriptsSupplied)
                % One script, multiple workspaces, so make the script name the same size as the
                % workspaces
                scriptsToRun = cellstr(repmat(scriptsToRun, size(workspaceValue)));
            end
            
            % Remove the relevant arguments from the args
            args(argIndexToRemove) = [];
            % Now parse the rest of the (common) arguments.
            obj.parseCommonInputs(args);

            % Pre-allocate the tasks structure
            obj.TasksToRun = repmat(obj.EmptyScriptTaskStruct, numel(scriptsToRun), 1);
            % Set the argument info for all the tasks.
            for ii = 1:numel(scriptsToRun)
                obj.TasksToRun(ii).ScriptName = scriptsToRun{ii};
                if ~isempty(workspaceValue)
                    obj.TasksToRun(ii).WorkspaceIn = workspaceValue(ii);
                end
            end

            % Make sure the scripts are added to the filedependencies and job name
            obj.addFileDependenciesAndJobName(scriptsToRun);

            % And check that matlabpool is set to 0 if we are in vectorized mode
            if isVectorized && obj.UserSpecifiedPoolSize && (obj.PoolSize > 0)
                error('distcomp:batch:InvalidInput', ...
                    'The matlabpool argument to batch must be 0 or unspecified when running vectorized scripts');
            end
        end
        
        % -------------------------------------------------------------------------
        % parseCommonInputs
        % -------------------------------------------------------------------------
        % Parses the args that are common to both functions and scripts.
        % Note that this does not check for consistency between arguments (e.g.
        % that matlabpool size cannot be > 0 if there is an array of scripts/functions)
        function parseCommonInputs(obj, args)
            % NB The order of the allowedProps is important because of the switch statement
            % below.  IF YOU ADD MORE PROPERTIES HERE, MAKE SURE THE ORDER MATCHES WITH
            % THE SWITCH STATEMENT.
            allowedProps = {'Configuration' 'FileDependencies' 'PathDependencies', ...
                'CurrentDirectory' 'CaptureDiary' 'Matlabpool'};
            
            % Convert the args to a parseable format
            [allProps, allValues] = parallel.internal.convertToPVArrays(args{:});

            % Check that each property is unique amongst the allowed parameters
            for i = 1:numel(allProps)
                thisProp  = allProps{i};
                thisValue = allValues{i};
                % Find this property name in each of the sets of properties
                indexInProps  = find(strncmpi(thisProp, allowedProps, numel(thisProp)));

                if isempty(indexInProps)
                    error('distcomp:batch:InvalidInput', ...
                        '%s is not a valid property input to batch', thisProp);
                elseif numel(indexInProps) > 1
                    error('distcomp:batch:InvalidInput', ...
                        ['%s is an ambiguous property input to batch since it ' ...
                        'matches multiple valid property names'], thisProp);
                end
                % We know that only one property was matched by thisProp and
                % thus that one of the indexInProps holds a single value
                switch indexInProps
                    case 1 %configuration
                        if ~iIsString(thisValue)
                            error('distcomp:batch:InvalidInput', ...
                                'The Configuration argument to batch must be a string');
                        end
                        obj.Configuration = thisValue;
                        obj.UserSpecifiedConfiguration = true;
                    case 2 %filedependencies
                        % Treat this as a whitespace delimited list of string
                        if iIsString(thisValue)
                            % Split the string on whitespace chars.  Note that strread will
                            % interpret multiple spaces correctly.
                            thisValue = strread(thisValue, '%s', 'delimiter', ' ');
                        elseif ~( iscell(thisValue) && all(cellfun(@iIsString, thisValue)) )
                                error('distcomp:batch:InvalidInput', ...
                                    'The FileDependencies argument to batch must be a space delimited string or a cell array of string');
                        end
                        obj.FileDependencies = thisValue;
                        obj.UserSpecifiedFileDependencies = true;
                    case 3 %pathdependencies
                        if iIsString(thisValue)
                            % Wrap a single string in a cell array for convenience
                            thisValue = {thisValue};
                        elseif ~( iscell(thisValue) && all(cellfun(@iIsString, thisValue)) )
                            error('distcomp:batch:InvalidInput', ...
                                'The PathDependencies argument to batch must be a cell array of string');
                        end                        
                        obj.PathDependencies = thisValue;
                        obj.UserSpecifiedPathDependencies = true;
                    case 4 %currentdirectory
                        if ~iIsString(thisValue)
                            error('distcomp:batch:InvalidInput', ...
                                'The CurrentDirectory argument to batch must be a string');
                        end
                        obj.WorkerCWD = thisValue;
                        obj.UserSpecifiedWorkerCWD = true;
                    case 5 %capturediary
                        if ~( islogical(thisValue) && isscalar(thisValue) )
                            error('distcomp:batch:InvalidInput', ...
                                'The CaptureDiary argument to batch must be a scalar logical');
                        end
                        obj.CaptureDiary = thisValue;
                        obj.UserSpecifiedCaptureDiary = true;
                    case 6 %matlabpool
                        if ~( isnumeric(thisValue) && isscalar(thisValue) && ...
                            isfinite(thisValue) && thisValue == abs(fix(thisValue)) )
                            error('distcomp:batch:InvalidInput', ...
                                'The Matlabpool argument to batch must be a nonnegative scalar integer');
                        end
                        obj.PoolSize = thisValue;
                        obj.UserSpecifiedPoolSize = false;
                    otherwise
                        error('distcomp:batch:InternalError', ...
                            'InternalError: %s is not a valid property name', thisProp);
                end
            end
            
            % CurrentDirectory
            if isempty(obj.WorkerCWD) && ~obj.UserSpecifiedWorkerCWD
                % If the user hasn't specified anything we will send over pwd
                obj.WorkerCWD = pwd;
            end
        end        
        
        % -------------------------------------------------------------------------
        % addFileDependenciesAndJobName
        % -------------------------------------------------------------------------
        % Adds the functions/scripts to the file dependencies and sets the job name
        % if it is not already set.
        function addFileDependenciesAndJobName(obj, functionsOrScripts)
            % Add the name of the functions/scripts being run to the FileDependencies - but check
            % that they exist first otherwise the job creation will error.  Also check that
            % the file doesn't already exist in the file dependencies.
            for ii = 1:numel(functionsOrScripts)
                filename = functionsOrScripts{ii};
                if isa(filename, 'function_handle')
                    filename = func2str(filename);
                end
                assert(ischar(filename), 'distcomp:batch:InternalError', 'Function or script name should be a string.');
                if exist(filename, 'file') && ~any(strcmpi(obj.FileDependencies, filename))
                    obj.FileDependencies{end+1} = filename;
                end
                % Set the name of the job to be the name of the first function or script, unless it has already been
                % set by the user.
                if (ii == 1) && ~obj.UserSpecifiedJobName && isempty(obj.JobName)
                    obj.JobName = filename;
                end
            end
        end
        
        % -------------------------------------------------------------------------
        % getCreateJobInputs
        % -------------------------------------------------------------------------
        % Determines the correct job constructor and creates the PV-pairs that 
        % should be used with that constructor
        function pvPairs = getCreateJobInputs(obj)
            % It is OK to set the Tag first because this it is not a
            % configurable property, so there is no danger of the
            % configuration changing this value.
            pvPairs = {'Tag', obj.JobTag};
            % Configuration must be before the remaining properties, otherwise
            % values set in the configuration will override any user-specified ones.
            if obj.UserSpecifiedConfiguration || ~isempty(obj.Configuration)
                pvPairs = [pvPairs, 'Configuration', obj.Configuration];
            end
            % Only add the other job-related properties if the user specified them, or they are not 
            % empty (i.e. we set them).  This helps us distinguish between the case where values
            % are empty because the user did not specify them, or if the user explicitly set them
            % to empty.
            if obj.UserSpecifiedJobName || ~isempty(obj.JobName)
                pvPairs = [pvPairs, 'Name', obj.JobName];
            end
            if obj.UserSpecifiedFileDependencies || ~isempty(obj.FileDependencies)
                pvPairs = [pvPairs, 'FileDependencies', {obj.FileDependencies}];
            end
            if obj.UserSpecifiedPathDependencies || ~isempty(obj.PathDependencies)
                pvPairs = [pvPairs, 'PathDependencies', {obj.PathDependencies}];
            end
            if obj.PoolSize > 0
                pvPairs = [pvPairs, 'MaximumNumberOfWorkers', obj.PoolSize+1, ...
                                    'MinimumNumberOfWorkers', obj.PoolSize+1];
            end
        end
        
        % -------------------------------------------------------------------------
        % getCreateTaskInputs
        % -------------------------------------------------------------------------
        % Converts TasksToRun into arguments that can be passed into the job.createTask method
        function [functionToRun, numArgsOut, allArgsIn, pvPairs] = getCreateTaskInputs(obj)
            % NB Configuration must be specified first in the list, otherwise
            % values set in the configuration will override any user-specified ones.
            pvPairs = {};
            if obj.UserSpecifiedConfiguration || ~isempty(obj.Configuration)
                pvPairs = [pvPairs, 'Configuration', obj.Configuration];
            end
            % Always add CaptureDiary - default value for this is true.  It
            % will only be false if the user actually specified it.
            pvPairs = [pvPairs, 'CaptureCommandWindowOutput', obj.CaptureDiary];
            
            % Use vectorized task creation since all tasks will use
            % the same task function.
            allArgsIn = repmat({{}}, numel(obj.TasksToRun), 1);
            if obj.IsRunScript
                functionToRun = @parallel.internal.cluster.executeScript;
                % Always 1 argout for executeScript
                numArgsOut = 1;
                for ii = 1:numel(obj.TasksToRun)
                    allArgsIn{ii} = {obj.TasksToRun(ii).ScriptName, obj.TasksToRun(ii).WorkspaceIn, obj.WorkerCWD};
                end
            else
                functionToRun = @parallel.internal.cluster.executeFunction;
                numArgsOut = zeros(numel(obj.TasksToRun), 1);
                for ii = 1:numel(obj.TasksToRun)
                    % Make sure the nargout from executeFunction is the same as
                    % the user requested from the function to run
                    numArgsOut(ii) = obj.TasksToRun(ii).NumArgsOut;
                    allArgsIn{ii} = {obj.TasksToRun(ii).FunctionToRun, obj.TasksToRun(ii).NumArgsOut, ...
                        obj.TasksToRun(ii).ArgsIn, obj.WorkerCWD};
                end
            end
        end
    end

    methods (Static, Access = private)
        % -------------------------------------------------------------------------
        % errorIfVectorizedBatchNotAllowed
        % -------------------------------------------------------------------------
        function errorIfVectorizedBatchNotAllowed
            if ~parallel.internal.cluster.BatchHelper.AllowVectorizedBatch
                ex = MException('distcomp:batch:VectorizedBatchNotAllowed', ...
                    'Batch cannot be used to run multiple scripts or functions.');
                throwAsCaller(ex);
            end
        end

        % -------------------------------------------------------------------------
        % getInvalidScriptOrFunctionError
        % -------------------------------------------------------------------------
        % This is called by the InvalidScriptOrFunctionError constant property.  
        % Do not call this method directly.
        function errorToThrow = getInvalidScriptOrFunctionError
            if parallel.internal.cluster.BatchHelper.AllowVectorizedBatch
                message = ['The script or function that will be called on the worker '...
                    'must be a single string or function handle, or an array of strings or function handles.'];
            else
                message = ['The script or function that will be called on the worker '...
                'must be a single string or function handle.'];
            end
            errorToThrow = MException('distcomp:batch:InvalidArgument', message);
        end

        % -------------------------------------------------------------------------
        % checkIfScriptSupplied
        % -------------------------------------------------------------------------
        % Is the supplied function/script to batch actually a function or script?
        function isScript = checkIfScriptSupplied(scriptOrFunctionToRun, possibleNargout)
            import parallel.internal.cluster.BatchHelper;

            switch class(scriptOrFunctionToRun)
                case 'function_handle'
                    % Is a single function handle
                    isScript = false;
                case 'char'
                    % Could be a function name or script name, so check if 
                    % the nargout value is a potential nargout
                    isScript = ~BatchHelper.isValidNargOutArgument(possibleNargout);
                case 'cell'
                    if ~BatchHelper.AllowVectorizedBatch
                        throw(BatchHelper.InvalidScriptOrFunctionError);
                    end
                    % Could be an array of script names, an array of function handles or
                    % an array of function names
                    
                    % Get class of all input tasks to run
                    taskClass = cellfun(@class, scriptOrFunctionToRun, 'uniformOutput', false);
                    % All tasks to run must be function handles or chars
                    if ~all(ismember(taskClass(:), {'function_handle', 'char'}))
                        throw(BatchHelper.InvalidScriptOrFunctionError);
                    end

                    % If any of the tasks are function handles, then we must be running
                    % functions.  Otherwise, check if the nargout value is a potential
                    % nargout.
                    if any(ismember(taskClass(:), 'function_handle'))
                        isScript = false;
                    else
                        isScript = ~BatchHelper.isValidNargOutArgument(possibleNargout);
                    end
                otherwise
                    throw(BatchHelper.InvalidScriptOrFunctionError);
            end
        end
        
        % -------------------------------------------------------------------------
        % isValidNargOutArgument
        % -------------------------------------------------------------------------
        % Can we interpret the supplied numArgsOut argument as the number of arguments out?
        % We need it to be an array of non-negative numbers.
        function OK = isValidNargOutArgument(numArgsOut)
            OK = true;
            if isempty(numArgsOut) || ~isnumeric(numArgsOut) || any(numArgsOut(:)) < 0
                OK = false;
            end
        end
    end
end


% -------------------------------------------------------------------------
% iIsString
% -------------------------------------------------------------------------
function OK = iIsString(str)
OK = ischar(str) && isvector(str) && size(str, 1) == 1;
end

