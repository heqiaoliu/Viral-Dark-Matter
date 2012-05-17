function matlabpool(obj, varargin)
%matlabpool  Open a pool of MATLAB sessions with scheduler for parallel computation
% 
%   MATLABPOOL enables the parallel language features within the MATLAB
%   language (e.g., parfor) by starting a parallel job that connects this
%   MATLAB client session with a number of labs.
%
%   MATLABPOOL(scheduler) or MATLABPOOL(scheduler, 'OPEN') starts a worker
%   pool using the identified scheduler or job manager.  You can
%   also specify the pool size using MATLABPOOL(scheduler, 'open',
%   <poolsize>).  The poolsize cannot exceed the cluster size
%   specified on the scheduler.
%
%   MATLABPOOL(scheduler, <poolsize>) is the same as MATLABPOOL(scheduler,
%   'open', <poolsize>) and is provided for convenience.
%
%   MATLABPOOL(... , 'FileDependencies', FILEDEPENDENCIES) starts a worker
%   pool and concatenates the cell array FILEDEPENDENCIES with the
%   FileDependencies specified in the scheduler's configuration, should one
%   exist. Note that 'FileDependencies' is case-sensitive.
%
%   Examples: 
%
%   1. Start a MATLAB pool on a scheduler, using a pool size specified
%      by that scheduler's configuration: 
%
%      >> jm = findResource('scheduler', 'configuration', defaultParallelConfig);
%      >> matlabpool(jm)
%
%   2. Start a pool of 16 MATLAB workers 
%      >> matlabpool(jm, 16)
%
%   See also   matlabpool, findResource, distcomp.jobmanager/batch

%  Copyright 2010 The MathWorks, Inc.

%  $Revision: 1.1.6.2 $  $Date: 2010/05/10 17:03:19 $

% Get the name of the object that we wish to appear in the error
% identifiers and messages (i.e. "jobmanager" for distcomp.jobmanager and
% "localscheduler" for distcomp.localscheduler.  This is required because
% the @jobmanager/matlabpool.m file is copied to @abstractscheduler.
className = class(obj);
% strip off any package names
className = strread(className, '%s', 'delimiter', '.');
objectNameToUseForErrors = className{end};
% Use an anonymous function for the configuration test function that is
% parsed to parseMatlabpoolInputs so that we can get the correct error
% messages out of it.
configurationTestFcn = @(x) iCheckAndReturnConfiguration(x, objectNameToUseForErrors);

% Parse the matlabpool inputs - we are only interested in 'matlabpool open'
actionsToParse = parallel.internal.cluster.MatlabpoolHelper.OpenAction;
try
    parsedArgs = parallel.internal.cluster.MatlabpoolHelper.parseMatlabpoolInputs(actionsToParse, ...
        configurationTestFcn, varargin{:});
catch err
    if strcmpi(err.identifier, parallel.internal.cluster.MatlabpoolHelper.FoundNoParseActionErrorIdentifier)
        error(sprintf('distcomp:%s:InvalidMatlabpoolAction', objectNameToUseForErrors), ... 
            ['The matlabpool method on the %s object accepts only the %s action.  ', ...
            'Use the matlabpool function for all other actions.'], ...
            objectNameToUseForErrors, actionsToParse);
    end
    % Make all errors appear from matlabpool
    throw(err);
end

% Do the actual matlabpool bit
try
    % we never expect any output args from doMatlabpool on a scheduler
    parallel.internal.cluster.MatlabpoolHelper.doMatlabpool(parsedArgs, obj);
catch err
    % Make all errors appear from matlabpool
    throw(err);
end

% -------------------------------------------------------------------------
%
% -------------------------------------------------------------------------
function configName = iCheckAndReturnConfiguration(configName, objectNameToUseForErrors)
% Function to pass to MatlabpoolHelper.parseMatlabpoolInputs to check the status
% of the configuration name that may have been found in the inputs.  This function 
% always returns configName = '' (if it does not error along the way).
%
% The scheduler's matlabpool method never wants a configuration to be supplied.
% However, we also need to distinguish between the following cases
%
% User specifies a configuration in error, and the configuration name is a valid one
%   >> jm.matlabpool('aValidConfigurationName') 
% Here, we need to tell the user that config names aren't allowed
%
% User just specifies a silly action, or 'silly' instead of 4 (numlabs), or 'silly' 
% instead of 'addFileDependencies'
%   >> jm.matlabpool('silly')
% Here, we need to tell the user that 'silly' is not a valid parameter at this location

% No configuration name is exactly what we want.
if isempty(configName)
    return;
end

if any(strcmpi(configName, getDistcompConfigurationNames))
    % A configuration was supplied, which we don't allow
    error(sprintf('distcomp:%s:InvalidArgument', objectNameToUseForErrors), ...
        'The matlabpool method of a %s object does not accept a configuration.', objectNameToUseForErrors);
else
    % Some other string was supplied and was interpreted as a configuration, but it isn't
    % actually a configuration name.
    error('distcomp:matlabpool:InvalidInput',...
        '"%s" is not a valid parameter at this location for the matlabpool method.', ...
        configName);
end
