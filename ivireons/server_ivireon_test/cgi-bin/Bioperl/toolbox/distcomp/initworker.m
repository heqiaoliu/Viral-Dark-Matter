function initworker(varargin)
; %#ok Undocumented
% initialization function for MATLAB Distributed Computing Server

% Copyright 2003-2010 The MathWorks, Inc.

try   
    % Check to see if a jvm is present - error if not
    if ~usejava('jvm')
        error('distcomp:initworker:jvmNotPresent',...
            ['Java must be initialized in order to use the Parallel Computing Toolbox.  ',...
            'Please launch MATLAB without the ''-nojvm'' flag.']);
    end    
    % Set up the log handler that will stream back to the Worker
    iInitializeLogging();
    iLog('Start initworker');
    
    % Make sure we die when our parent does
    iLog('Starting ParentWatchdog');
    com.mathworks.toolbox.distcomp.control.ParentWatchdog;
    
    % Make sure this MATLAB cannot core dump, and will exit if anything goes
    % wrong. The (unused) return argument suppresses command window output.
    OK = system_dependent(100, 2); %#ok<NASGU>
    dct_psfcns('ensureProcessExitsOnFault');
    
    % Call the common initialization
    iLog('Calling initcommon');
    initcommon();
    
    % Initialize NativeMethods - do this now to get early warning if
    % nativedmatlab shared library can not be loaded.
    com.mathworks.toolbox.distcomp.nativedmatlab.NativeMethods;
    
    iLog('Setting system properties from environment');
    import com.mathworks.toolbox.distcomp.util.SystemPropertyNames;
    % Set java system properties from the environment
    iSetSystemPropertyFromEnv(...
        'java.rmi.server.hostname',...
        'HOSTNAME');
    iSetSystemPropertyFromEnv(...
        SystemPropertyNames.BASE_PORT, ...
        'BASE_PORT');
    iSetSystemPropertyFromEnv(...
        SystemPropertyNames.RMI_USE_SECURE_COMMUNICATION, ...
        'USE_SECURE_COMMUNICATION');
    iSetSystemPropertyFromEnv(...
        SystemPropertyNames.RMI_SECURE_DATA_TRANSFER, ...
        'SECURE_DATA_TRANSFER');
    iSetSystemPropertyFromEnv(...
        SystemPropertyNames.RMI_KEYSTORE_PATH, ...
        'KEYSTORE_PATH');
    iSetSystemPropertyFromEnv(...
        SystemPropertyNames.RMI_DEFAULT_KEYSTORE_PATH, ...
        'DEFAULT_KEYSTORE_PATH');
    iSetSystemPropertyFromEnv(...
        SystemPropertyNames.RMI_KEYSTORE_PASSWORD, ...
        'KEYSTORE_PASSWORD');
    iSetSystemPropertyFromEnv(...
        SystemPropertyNames.RMI_USE_SERVER_SPECIFIED_HOSTNAME, ...
        'USE_SERVER_SPECIFIED_HOSTNAME');
    
    iLog('Setting port range');
    % Set the port range MATLAB will use to talk to the job manager.
    iSetPortRange();
           
    iLog('Testing DataStore export');
    % Check we can create/export a DataStore - this detects problems with
    % settings that otherwise won't be found until later.
    minTransferSize = 1; % Any size will do
    invoker = com.mathworks.toolbox.distcomp.util.LargeDataInvoker(minTransferSize);
    % This will error if the DataStore can not be exported
    invoker.getDataStoreProxy(); 
        
    address = getenv('WORKER_IPC_ADDRESS');
    if isempty(address)
        error('distcomp:initworker:InvalidEnvironment',...
            'WORKER_IPC_ADDRESS environment variable is not set.\n');
    end
    requestServerArguments = {address};
    
    if ispc 
        % On Windows look for the MDCEUSER variable
        % If it is set we will pass it to pctRequestServer
        user = getenv('MDCEUSER');
        if ~isempty(user)
            iLog('pctRequestServer will give permissions to %s', user)
            requestServerArguments = {address, user};
        end
    end
    
    % Start listening for commands
    iLog('Starting pctRequestServer on %s', address);
    pctRequestServer('start', requestServerArguments{:});
    
    iLog('End initworker');
catch err
    % Don't use iLog here just in case it is causing the error.
    fprintf(err.getReport());
    fprintf('Exiting MATLAB due to error in initworker\n');
    % Exit MATLAB (should send SIGKILL to be sure.)
    exit('force');
end
end

% -------------------------------------------------------------------------
%
% -------------------------------------------------------------------------
function iSetPortRange()
import com.mathworks.toolbox.distcomp.control.PortConfig;
import com.mathworks.toolbox.distcomp.service.ExportConfigInfo;
basePortString = getenv('BASE_PORT');
% The minimum port to use - this skips the reserved ports
minPort = PortConfig.getMinDistcompServiceExportPort(basePortString);
ExportConfigInfo.setPortRange(minPort, minPort + 100);
end

% -------------------------------------------------------------------------
%
% -------------------------------------------------------------------------
function iSetSystemPropertyFromEnv(property, variable)
% Set a java system property from environment variable
value = getenv(variable);
% Will need to change this if empty string is a valid value.
if isempty(value)
    error('distcomp:initworker:InvalidEnvironment',...
          'Environment variable "%s" is not defined.', variable);
end
iLog('Setting "%s" to "%s"', char(property), value);
java.lang.System.setProperty(property, value);
end


% -------------------------------------------------------------------------
%
% -------------------------------------------------------------------------
function iInitializeLogging()

logPort = str2double( getenv('WORKER_LOG_PORT') );
if isnan(logPort)
    error('distcomp:initworker:InvalidEnvironment',...
          'Environment variable "WORKER_LOG_PORT" is not defined.');
end

logLevel = str2double( getenv('WORKER_LOG_LEVEL') );
if isnan(logLevel)
    error('distcomp:initworker:InvalidEnvironment',...
          'Environment variable "WORKER_LOG_LEVEL" is not defined.');
end

import com.mathworks.toolbox.distcomp.logging.*;
% Set up the handler to stream stuff back to the Worker
handler = SocketStreamHandler(logPort);
handler.setLevel(DistcompLevel.getLevelFromValue(logLevel));
formatter = DistcompSimpleFormatter();
handler.setFormatter(formatter);
com.mathworks.toolbox.distcomp.PackageInfo.LOGGER.addHandler(handler);

end
% -------------------------------------------------------------------------
%
% -------------------------------------------------------------------------
function iLog(varargin)
% initworker will log at "INFO" 
logger = com.mathworks.toolbox.distcomp.worker.PackageInfo.LOGGER;
msg = sprintf(varargin{:});
logger.info(msg);
end
