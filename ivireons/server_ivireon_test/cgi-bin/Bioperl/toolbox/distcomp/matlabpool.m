function varargout = matlabpool(varargin)
%MATLABPOOL Open or close a pool of MATLAB sessions for parallel computation
%   MATLABPOOL enables the parallel language features within the MATLAB
%   language (e.g., parfor) by starting a parallel job that connects this
%   MATLAB client session with a number of labs.
%
%   SYNTAX
%
%     MATLABPOOL
%     MATLABPOOL OPEN
%     MATLABPOOL OPEN <poolsize>
%     MATLABPOOL OPEN CONF
%     MATLABPOOL OPEN CONF <poolsize>
%     MATLABPOOL('OPEN', ... 'FileDependencies', FILEDEPENDENCIES)
%     MATLABPOOL <poolsize>
%     MATLABPOOL CONF
%     MATLABPOOL CONF <poolsize>
%     MATLABPOOL(schedObj)
%     MATLABPOOL(schedObj, 'OPEN')
%     MATLABPOOL(schedObj, 'OPEN', ...)
%     MATLABPOOL(schedObj, poolsize)
%     MATLABPOOL CLOSE
%     MATLABPOOL CLOSE FORCE
%     MATLABPOOL CLOSE FORCE CONF
%     MATLABPOOL SIZE
%     MATLABPOOL('ADDFILEDEPENDENCIES', FILEDEPENDENCIES)
%     MATLABPOOL UPDATEFILEDEPENDENCIES
%
%   MATLABPOOL or MATLABPOOL OPEN starts a worker pool using the default
%   configuration with the pool size specified by that configuration. You
%   can also specify the pool size using MATLABPOOL OPEN <poolsize>, but note
%   that most schedulers have a maximum number of processes that they can start.
%
%   MATLABPOOL OPEN CONF or MATLABPOOL OPEN CONF <poolsize> starts a worker
%   pool using the Parallel Computing Toolbox user configuration CONF rather
%   than the default configuration to locate a scheduler. If the pool size is
%   specified, it will override the maximum and minimum number of workers
%   specified in the configuration.
%
%   MATLABPOOL('OPEN', ... , 'FileDependencies', FILEDEPENDENCIES) starts a worker
%   pool and concatenates the cell array FILEDEPENDENCIES with the FileDependencies
%   specified in the configuration. Note that 'FileDependencies' is case-sensitive.
%
%   MATLABPOOL CONF <poolsize> is the same as MATLABPOOL OPEN CONF <poolsize> and
%   is provided for convenience.
%
%   MATLABPOOL(schedObj) or MATLABPOOL(schedObj, 'OPEN') is the same as 
%   MATLABPOOL OPEN, except that the worker pool is started on the scheduler 
%   identified by the object schedObj.  
%
%   MATLABPOOL(schedObj, 'OPEN', ...) is the same as MATLABPOOL('OPEN', ...) except
%   that the worker pool is started on the scheduler identified by the object 
%   schedObj.
%
%   MATLABPOOL(schedObj, poolsize) is the same as MATLABPOOL <poolsize> except
%   that the worker pool is started on the scheduler identified by the object 
%   schedObj.
%
%   MATLABPOOL CLOSE stops the worker pool, destroys the parallel job and makes
%   all parallel language features revert to using the MATLAB client to compute
%   their results
%
%   MATLABPOOL CLOSE FORCE stops the worker pool and destroys all parallel jobs
%   created by MATLABPOOL for the current user under the scheduler specified by
%   the default configuration, including any jobs currently running.
%
%   MATLABPOOL CLOSE FORCE CONF stops the worker pool and destroys all parallel
%   jobs being run under the scheduler specified in the configuration conf.
%
%   MATLABPOOL SIZE returns the size of the worker pool if it is open, or 0 
%   if the pool is closed.
%
%   MATLABPOOL('ADDFILEDEPENDENCIES', FILEDEPENDENCIES) allows you to add
%   extra file dependencies to an already running pool. FILEDEPENDENCIES is a 
%   cell array of strings, identical in form to those added to a job. Each
%   string can specify either absolute or relative files, directories,
%   or a file on the MATLAB path. These files are transferred to
%   each worker and placed in the file dependencies directory, exactly the 
%   same as if they had been set at the time the pool was opened.
%
%   MATLABPOOL UPDATEFILEDEPENDENCIES checks all the file dependencies of
%   the current pool to see if they have changed, and replicates any changes
%   to each of the labs in the pool. In this way code changes can be
%   sent out to remote labs. This checks dependencies added with both the 
%   MATLABPOOL ADDFILEDEPENDENCIES command and those specified when the pool 
%   was started (by a configuration or command line argument).
%
%   MATLABPOOL can be invoked as either a command or a function.  For
%   example, the following are equivalent:
%       MATLABPOOL CONF 4
%       MATLABPOOL('CONF', 4)
%
%   EXAMPLES
%   1. Start a worker pool using the default configuration (usually local) with
%      a pool size specified by that configuration (4 for the local scheduler)
%       >> matlabpool
%   2. Start a pool of 16 MATLAB workers using the configuration myConf
%       >> matlabpool myConf 16
%   3. Start a worker pool using the local configuration with 2 workers:
%       >> matlabpool local 2
%   4. Check whether the worker pool is currently open:
%      >> isOpen = matlabpool('size') > 0
%   5. Start a MATLAB pool on a scheduler, using a pool size specified
%      by that scheduler:
%      >> jm = findResource('scheduler', 'configuration', defaultParallelConfig);
%      >> matlabpool(jm)
%   6. Start a pool of 16 MATLAB workers on a scheduler:
%      >> matlabpool(jm, 16)
%
%   See also   parfor, batch, findResource,
%              createParallelJob, defaultParallelConfig, 
%              distcomp.jobmanager/matlabpool.

%   Copyright 2007-2010 The MathWorks, Inc.

iVerifyJava();

% Parse the matlabpool inputs - we are interested in all the possible actions
actionsToParse = parallel.internal.cluster.MatlabpoolHelper.getAllActions();
try
    parsedArgs = parallel.internal.cluster.MatlabpoolHelper.parseMatlabpoolInputs(actionsToParse, ...
        @iCheckAndReturnConfiguration, varargin{:});
catch err
    % Make all errors appear from matlabpool
    throw(err)
end

% Do the actual matlabpool bit
try    
    matlabpoolOut = parallel.internal.cluster.MatlabpoolHelper.doMatlabpool(parsedArgs, parsedArgs.ActionArgs.Scheduler);
catch err
    % Make all errors appear from matlabpool
    throw(err)
end

% Have to do the varargout assignment down here because doMatlabpool may return
% empty.
varargout{1:nargout} = matlabpoolOut{:};

end

% -------------------------------------------------------------------------
%
% -------------------------------------------------------------------------
function iVerifyJava()
%iVerifyJava Error if swing is not present.
if iIsOnClient()
    error(javachk('jvm', 'matlabpool'));
end
end

% -------------------------------------------------------------------------
%
% -------------------------------------------------------------------------
function onclient = iIsOnClient()
onclient = ~system_dependent('isdmlworker');
end

% -------------------------------------------------------------------------
%
% -------------------------------------------------------------------------
function configName = iCheckAndReturnConfiguration(configName)
% Function to pass to MatlabpoolHelper.parseMatlabpoolInputs to check the status
% of the configuration name that may have been found in the inputs.  This function 
% always returns configName = '' (if it does not error along the way).
%
% If no configName is supplied, return the default config.
% Otherwise, check that the configName is a valid configuration name.

if isempty(configName)
    configName = defaultParallelConfig;
elseif ~any(strcmpi(configName, getDistcompConfigurationNames))
    error('distcomp:matlabpool:InvalidInput', ...
        ['''%s'' is not a valid configuration name.\n'...
        'Use [conf, allConf] = defaultParallelConfig to see all your configurations.'], ...
        configName);
end
end
