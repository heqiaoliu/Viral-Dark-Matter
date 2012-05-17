function out = findResource(resourceType, varargin)
%findResource Find available distributed computing resources
%
%   OUT = findResource
%   returns a scheduler object representing the scheduler identified by the
%   default parallel configuration, with the scheduler object properties set to
%   the values defined in that configuration.
%
%   OUT = findResource('scheduler', 'configuration', CONFIG)
%   returns a scheduler object representing the scheduler identified by the
%   specified parallel configuration, with the scheduler object properties set
%   to the values defined in that configuration.
%
%   OUT = findResource('scheduler','type', SCHEDTYPE)
%   OUT = findResource('worker')
%   return an array, OUT, containing objects representing all available
%   distributed computing schedulers of the given type, or workers. SCHEDTYPE
%   can be one of :
%
%   'local', 'jobmanager', 'hpcserver', 'lsf', 'mpiexec', 'pbspro', 'torque', or any
%   string starting with 'generic'
%
%   The 'local' option allows your jobs to run on MATLAB workers on your
%   local client machine, without a jobmanager or separate scheduler.
%   You can use different scheduler types starting with 'generic' to
%   identify one generic scheduler or configuration from another. For
%   third-party schedulers, job data is stored in the location specified by the
%   scheduler object's DataLocation property.
%
%   OUT = findResource('scheduler','type','jobmanager','LookupURL','HOST:PORT')
%   OUT = findResource('worker','LookupURL','HOST:PORT')
%   use the lookup process of the job manager running at a specific
%   location. The lookup process is part of a job manager. By default,
%   findResource uses all the lookup processes that are available to the local
%   machine via multicast. If you specify 'LookupURL' with a host and port,
%   findResource uses the job manager lookup process running at that
%   location. This URL is where the lookup is performed from, it is not
%   necessarily the host running the job manager or worker. This unicast call is
%   useful when you want to find resources that might not be available via
%   multicast or in a network that does not support multicast. Note that the
%   port value of a lookup defaults to 27350 if it is not specified. This
%   is the default base port for a cluster as specified in the mdce_def file.
%
%   Note:  LookupURL is ignored when finding third-party schedulers.
%
%   OUT = findResource(... ,'P1', V1, 'P2', V2,...)
%   returns an array, OUT, of resources whose property names and property values
%   match those passed as parameter-value pairs, P1, V1, P2, V2.
%   Note that the property value pairs can be in any format supported by the SET
%   function.
%   When a property value is specified, it must use the same exact value that
%   the GET function returns, including letter case. For example, if GET returns
%   the Name property value as 'MyJobManager', then findResource will not find
%   that object if searching for a Name property value of 'myjobmanager'.
%
%   Remarks
%   Note that it is permissible to use parameter-value string pairs, structures,
%   and parameter-value cell array pairs in the same call to findResource.  The
%   parameter-value pairs can also be specified as a configuration, described in
%   the "Programming with User Configurations" section in the documentation. If 
%   a configuration is specified then the Configuration property of the returned
%   scheduler object will also be set to the specified value.
%
%   Examples: 
%   Find the scheduler identified by the default parallel configuration, with
%   the scheduler object properties set to the values defined in that
%   configuration.
%     sched = findResource();
%   
%   Find a particular job manager by its name.
%     jm1 = findResource('scheduler','type','jobmanager', ...
%                        'Name', 'ClusterQueue1');
%
%   Find all job managers. In this example, there are four.
%     all_job_managers = findResource('scheduler','type','jobmanager')
%     all_job_managers =
%         distcomp.jobmanager: 1-by-4
%
%   Find all job managers accessible from the lookup service on a particular
%   host.
%     jms = findResource('scheduler','type','jobmanager', ...
%                        'LookupURL','MyJobManagerHost');
%
%   Find a particular job manager accessible from the lookup service on a
%   particular host. In this example, subnet2.host_alpha port 6789 is where the
%   lookup is performed, but the job manager named SN2Jmgr might be running on
%   another machine.
%
%     jm = findResource('scheduler','type','jobmanager', ...
%                        'LookupURL', 'subnet2.host_alpha:6789', ...
%                        'Name', 'SN2JMgr');
%
%   Find the LSF scheduler on the network.
%     lsf_sched = findResource('scheduler','type','LSF')
%
%   See also defaultParallelConfig, batch, createJob, createParallelJob,
%   createMatlabpoolJob.

% Copyright 2004-2010 The MathWorks, Inc.

% This will error in a deployed application if
% this is the second MCR component in the application.
pMCRShutdownHandler( 'initialize' );

% Need a variable to carry out a one off check to ensure that the java
% security manager has been set correctly - this set occurs in the schema
% of the distcomp package so all we need to do is get the singleton instance of
% distcomp.objectroot
persistent HAS_BEEN_INITIALISED
if isempty(HAS_BEEN_INITIALISED)
    if ~usejava('jvm')
        error('distcomp:findReource:jvmNotPresent','Java must be initialized in order to use the Parallel Computing Toolbox. \nPlease launch MATLAB without the ''-nojvm'' flag.');
    end
    % This might throw an error if java isn't available
    try
        distcomp.getdistcompobjectroot;
        HAS_BEEN_INITIALISED = true;
    catch err
        % Catch the port unavailable exception and display nicely
        throw(distcomp.handleJavaException([], err));
    end
end

% Has the user specified a resource type - if not this is the default
% call that uses the configuration specified in defaultParallelConfig
if nargin < 1
    resourceType = 'scheduler';
    pvals = {'configuration', defaultParallelConfig};
else
    pvals = varargin;
end
% Verify that the resource type is valid before we go any further.
% It should be a 1xN char array.
idInvalidResType = 'distcomp:findresource:InvalidResourceType';
if ~iIsString(resourceType)
    error(idInvalidResType, 'Resource type must be a string.');
end
validResourceTypes = {'jobmanager', 'worker', 'scheduler'};
if ~any(strcmp(validResourceTypes, resourceType))
    % Handle the case when users call
    % findResource('configuration', 'myconfig') instead of
    % findResource('scheduler', 'configuration', 'myconfig')
    if strcmpi(resourceType, 'configuration')
        error(idInvalidResType, ...
              iConfigurationNeedsResourceTypeMsg(pvals{:}));
    else
        error(idInvalidResType, iInvalidResourceTypeMsg(resourceType));
    end
end

[props, pvals, configurationNameSpecified] = pConvertToPVArraysWithConfig(pvals, 'findResource');
% The lookupURL property is not a part of the sub-selection PV-pairs,
% so we extract it from the PV-pairs regardless of the resource type.
[url, props, pvals] = iGetURL(props, pvals);
distcompserialize([]);

% Make errors originate from findResource
try
    % Ensure that the user has asked us to find a valid type of resource
    switch resourceType
        case 'jobmanager'
            [out, props, pvals] = iFindScheduler(url, [{'type'} props], [{'jobmanager'} pvals]);
        case 'worker'
            [out, props, pvals] = iFindWorkers(url, props, pvals);
        case 'scheduler'
            [out, props, pvals] = iFindScheduler(url, props, pvals);
        otherwise
            error(idInvalidResType, iInvalidResourceTypeMsg(resourceType));
    end
catch err
    rethrow(err)
end
% Has the user asked to subselect the list
if numel(out) > 0 && ~isempty(props)
    out = out.find(props, pvals, '-depth', 0);
end
% Conduct a two-way communication check for the MathWorks jobmanager
if isa(out, 'distcomp.jobmanager')
    out.pCheckTwoWayCommunications;
end
% Have we been asked to set the configuration on the scheduler as
% well
if ~isempty(configurationNameSpecified)
    set(out, 'Configuration', configurationNameSpecified);
end
% Set the username in the jobmanager.
% If the configuration has already set the username we do not do anything
% here. But therefore this needs to run after setting the configuration.
if isa(out, 'distcomp.jobmanager')
    for i = 1:numel(out)
        jm = out(i);
        if isempty(jm.pGetUserName())
            try
                userIdentity = jm.pReturnProxyObject().promptForIdentity([]);
                jm.pSetUserName(userIdentity);
            catch err
                throw(distcomp.handleJavaException(jm, err));
            end
        end
    end
end

%--------------------------------------------------------------------------
%
%--------------------------------------------------------------------------
function [out, props, pvals] = iFindJobManagers(url, props, pvals)
[name, props, pvals] = iGetName(props, pvals);
accessor = iCreateAccessor(url);
if isempty(accessor)
    out = [];
    return;
end
try
    % Get all the jobmanager serviceItems
    proxyManagers = accessor.getJobManagers(name);
    % Check each to ensure that version info is the same
    OK = true(size(proxyManagers));
    for i = 1:numel(OK)
        OK(i) = proxyManagers(i).checkVersion;
        if ~OK(i)
            warning('distcomp:findresource:IncorrectVersion', ...
                iIncorrectVersionString(proxyManagers(i)));
        end
    end
    % Remove those that fail the version check
    proxyManagers = proxyManagers(OK);
    % Jobmanager construction could throw an error (not able to access the
    % JobAccessProxy for example - so loop over the createObject to pick up
    % those errors
    OK = true(numel(proxyManagers), 1);
    out = handle(-ones(numel(proxyManagers), 1));
    uddConstructor = distcomp.getSchedulerUDDConstructor('jobmanager');
    for i = 1:numel(OK)
        try
            out(i) = distcomp.createObjectsFromProxies(proxyManagers(i), uddConstructor, distcomp.getdistcompobjectroot);
        catch
            OK(i) = false;
        end
    end
    % Subselect only the successfully created objects
    out = out(OK);
catch err
    rethrow(err);
end

%--------------------------------------------------------------------------
%
%--------------------------------------------------------------------------
function [out, props, pvals] = iFindWorkers(url, props, pvals)
[name, props, pvals] = iGetName(props, pvals);
accessor = iCreateAccessor(url);
if isempty(accessor)
    out = [];
    return;
end
try
    % Get all the ml worker serviceItems
    proxyWorkers = accessor.getMLWorkers(name);
    % Check each to ensure that version info is the same
    OK = true(size(proxyWorkers));
    for i = 1:numel(OK)
        OK(i) = proxyWorkers(i).checkVersion;
        if ~OK(i)
            warning('distcomp:findresource:IncorrectVersion', ...
                iIncorrectVersionString(proxyWorkers(i)));
        end
    end
    % Remove those that fail the version check
    proxyWorkers = proxyWorkers(OK);
    uddConstructor = distcomp.getSchedulerUDDConstructor('worker');
    out = distcomp.createObjectsFromProxies(proxyWorkers, uddConstructor, distcomp.getdistcompobjectroot);
catch err
    rethrow(err);
end

%--------------------------------------------------------------------------
%
%--------------------------------------------------------------------------
function str = iIncorrectVersionString(proxy)
localVersion = com.mathworks.toolbox.distcomp.util.Version.VERSION_STRING;
if isempty(proxy.getName)
    resStr = 'a remote resource';
else
    resStr = sprintf('the resource %s', char(proxy.getName));
end
if isempty(proxy.getHostName)
    hostStr = '';
else
    hostStr = sprintf(' on computer %s', char(proxy.getHostName));
end
str = sprintf([ ...
    '\nThe local product version of the Parallel Computing Toolbox is \n'...
    'incompatible with that of %s%s.\n' ...
    'The local product version is %s while the version on the remote computer is %s.\n' ...
    'Specify the ''Name'' and ''LookupURL'' inputs to findResource to find only\n' ...
    'the resources you want to use.\n' ...
    ], resStr, hostStr, char(localVersion), char(proxy.getVersionString));

%--------------------------------------------------------------------------
%
%--------------------------------------------------------------------------
function [out, props, pvals] = iFindScheduler(url, props, pvals)
import com.mathworks.toolbox.distcomp.distcompobjects.SchedulerProxy
[type, props, pvals] =  iGetType(props, pvals);
if isempty(type)
    error('distcomp:findresource:InvalidArgument', ...
          'You must supply a type argument to find a scheduler');
end

% CCS will be deprecated in the future
if strcmpi(type, 'ccs')
    warning('distcomp:ccs:DeprecatedSchedulerType', ...
        ['The CCS scheduler type will be removed in a future version \n' ...
        'of the Parallel Computing Toolbox. Please use the HPCSERVER \n' ...
        'scheduler type instead.']);
    warning('off', 'distcomp:ccs:DeprecatedSchedulerType');
    
    % Change the name to hpcserver instead
    type = 'hpcserver';
end

% Create the correct scheduler type. REMEMBER to add these to the error just below
switch lower(type)
    case {'lsf' 'pbspro' 'torque' 'mpiexec' 'hpcserver' 'local' 'runner'}
        name = lower(type);
        
        % Remember to not warn on a permission error here
        WARN_ON_PERMISSION_ERROR = false;
        % Create the storage object to use with the scheduler
        storage = distcomp.filestorage(pwd, WARN_ON_PERMISSION_ERROR);
        proxy = SchedulerProxy.createInstance(name, storage);
        uddConstructor = distcomp.getSchedulerUDDConstructor(name);
        out = distcomp.createObjectsFromProxies(proxy, uddConstructor, distcomp.getdistcompobjectroot);
    case 'jobmanager'
        [out, props, pvals] = iFindJobManagers(url, props, pvals);
  otherwise
        % Generic schedulers can be specified as 'generic<arbitrary text>',
        name = 'generic';
        found = strncmpi(type, name, numel(name));
        if found
            % Remember to not warn on a permission error here
            WARN_ON_PERMISSION_ERROR = false;
            % Create the storage object to use with the scheduler
            storage = distcomp.filestorage(pwd, WARN_ON_PERMISSION_ERROR);
            genericProxy = SchedulerProxy.createInstance(type, storage);
            uddConstructor = distcomp.getSchedulerUDDConstructor(name);
            out = distcomp.createObjectsFromProxies(genericProxy, uddConstructor, distcomp.getdistcompobjectroot);
        else
            error('distcomp:findresource:InvalidArgument', ...
                  ['Currently supported schedulers are:\n''jobmanager'', ' ...
                   '''lsf'', ''mpiexec'', ''hpcserver'', ''local'', ''pbspro'', ' ...
                   '''torque'', and ''generic''.']);
        end
end

%--------------------------------------------------------------------------
%
%--------------------------------------------------------------------------
function accessor = iCreateAccessor(url)
if isempty(url)
    try
        % Create the multicast accessor that we will use to find the JobManagers
        accessor = com.mathworks.toolbox.distcomp.util.MulticastAccessor;
    catch
        error('distcomp:findresource:ServiceNotFound', 'Unable to open a socket for multicast discovery.\nTry providing findResource with a ''lookupURL'' input');
    end
else
    try
        % Create the unicast accessor that we will use to find JobManagers at one url
        accessor = com.mathworks.toolbox.distcomp.util.UnicastAccessor(url);
    catch
        error('distcomp:findresource:ServiceNotFound', 'The ''lookupURL'' input is malformed.');
    end
end
if ~accessor.lookupServiceFound
    % This accessor is useless.  Don't pass it back to the caller.
    accessor = [];
    if isempty(url)
        warning('distcomp:findresource:ServiceNotFound', iGetJINIMulticastErrorString);
    else
        warning('distcomp:findresource:ServiceNotFound', iGetJINIUnicastErrorString(url));
    end
end

%--------------------------------------------------------------------------
%
%--------------------------------------------------------------------------
function errorStr = iGetJINIMulticastErrorString
errorStr = sprintf([...
    'Could not contact any job manager lookup process. You may not have started a job\n' ...
    'manager, or multicast protocols may be failing on your network. If you are\n' ...
    'certain that a job manager is running, try findResource with a ''lookupURL'' input.' ...
    ]);

%--------------------------------------------------------------------------
%
%--------------------------------------------------------------------------
function errorStr = iGetJINIUnicastErrorString(url)
[hostname, ipAddress, fqdn] = iGetHostInfo(url);
if isempty(ipAddress)
    errorStr = sprintf( ...
        ['Could not contact a job manager lookup process using the lookupURL\n' ...
         '''%s''.\n' ...
         'The hostname in the lookupURL, %s, could not be resolved.' ...
        ], url, hostname);
else
    errorStr = sprintf([...
        'Could not contact a job manager lookup process using the lookupURL\n' ...
        '''%s''.  Possible reasons for this problem are:\n\n' ...
        '\t1. The job manager process has not been started, has crashed, or \n' ...
        '\t   has been shut down.\n' ...
        '\t2. A firewall is blocking communication between this computer and the \n'...
        '\t   job manager.\n' ...
        '\t3. This computer cannot resolve the hostname of the job manager computer, or\n', ...
        '\t   it resolves it to an incorrect IP address.\n' ...
        '\t4. The job manager computer resolves its own hostname to an incorrect IP\n'...
        '\t   address.\n'...
        '\t5. Network routers are unable to route traffic from this computer to\n' ...
        '\t   the job manager.\n\n' ...
        'The hostname in the lookupURL, %s, corresponds to the fully\n' ...
        'qualified hostname %s, and this computer\n' ...
        'resolves it to the IP address %s.' ...
                       ], url, hostname, fqdn, ipAddress);
end

%--------------------------------------------------------------------------
%
%--------------------------------------------------------------------------
function [hostname, ipAddress, fqdn] = iGetHostInfo(url)
% Remove the port from the lookupURL so that we are only left with the host name.
% Return empty ipAddress if and only if the resolution failed.
hostname = regexprep(url, ':[0-9]*$', '');
try
    inetAddress = java.net.InetAddress.getByName(hostname);
    ipAddress = char(inetAddress.getHostAddress());
    fqdn = char(inetAddress.getCanonicalHostName());
catch
    ipAddress = [];
    fqdn = [];
end
%--------------------------------------------------------------------------
%
%--------------------------------------------------------------------------
function [value, props, pvals] = iGetProperty(property, props, pvals)
value = [];
% Can we find the property anywhere (it might be defined multiple times).
found = strcmpi(property, props);
% If we found it, get the last value for it and remove all occurrences from
% the lists.
if any(found)
   value = pvals{find(found, 1, 'last')};
   props(found) = [];
   pvals(found) = [];
end

%--------------------------------------------------------------------------
%
%--------------------------------------------------------------------------
function [name, props, pvals] = iGetName(props, pvals)
[name, props, pvals] = iGetProperty('name', props, pvals);
if ~isempty( name ) && ~ischar( name )
    error('distcomp:findresource:InvalidPropertyValueClass','Name property must be a string value');
end

%--------------------------------------------------------------------------
%
%--------------------------------------------------------------------------
function [url, props, pvals] = iGetURL(props, pvals)
[url, props, pvals] = iGetProperty('lookupURL', props, pvals);
if ~isempty( url ) && ~ischar( url )
    error('distcomp:findresource:InvalidPropertyValueClass','lookupURL property must be a string value');
end

%--------------------------------------------------------------------------
%
%--------------------------------------------------------------------------
function [type, props, pvals] = iGetType(props, pvals)
[type, props, pvals] = iGetProperty('type', props, pvals);
if ~isempty( type ) && ~ischar( type )
    error('distcomp:findresource:InvalidPropertyValueClass','Type property must be a string value');
end

%--------------------------------------------------------------------------
%
%--------------------------------------------------------------------------
function msg = iInvalidResourceTypeMsg(resourceType)
msg = sprintf('Invalid resource type: ''%s''. You can only find resources\nof type ''scheduler'', ''jobmanager'', or ''worker''.', resourceType);


%--------------------------------------------------------------------------
%
%--------------------------------------------------------------------------
function msg = iConfigurationNeedsResourceTypeMsg(varargin)
if nargin == 1 && iIsString(varargin{1})
    % The user executed findResource('configuration', 'some_string') Let's
    % assume that the string argument they passed is the name of a
    % configuration.
    config = varargin{1};
else
    % Let's be cautious and use a made-up name of a configuration in our
    % message.
    config = 'MyConfig';
end
msg = sprintf(['The first argument to findResource must be the ', ...
               'resource type to be found,\n', ...
               'such as ''scheduler''.  If you want to find a scheduler ', ...
               'using a configuration\n', ...
               'named ''%s'', use:\n\n', ...
               '  findResource(''scheduler'',',  ...
               ' ''configuration'', ''%s'')', ...
               ], config, config);

%--------------------------------------------------------------------------
%
%--------------------------------------------------------------------------
function valid = iIsString(value)
valid = ischar(value) && (size(value, 2) == numel(value));
