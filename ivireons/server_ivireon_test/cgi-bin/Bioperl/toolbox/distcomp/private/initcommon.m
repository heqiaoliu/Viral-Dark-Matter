function initcommon
; %#ok Undocumented
% Copyright 2009-2010 The MathWorks, Inc.
        
% Initialization common to workers and clients

% Check to see if a jvm is present - error if not
if ~usejava('jvm')
    error('distcomp:initclient:jvmNotPresent',...
          ['Java must be initialized in order to use the Parallel Computing Toolbox.  ',...
           'Please launch MATLAB without the ''-nojvm'' flag.']);
end

% Set security manager so that we can download code using a codebase classloader
if isempty(java.lang.System.getSecurityManager)
    java.lang.System.setProperty('java.security.policy',...
                                 fullfile(toolboxdir('distcomp'), 'config', 'jsk-all.policy'));
    java.lang.System.setSecurityManager(com.mathworks.toolbox.distcomp.util.AllowAllSecurityManager);
end

% Set JVM properties for RMI and DNS
RMI_connectionTimeoutMillis = '10000';
RMI_readTimeoutMillis = '300000';
DNS_lookupIntervalSecs = '300';
java.lang.System.setProperty('sun.rmi.transport.connectionTimeout', RMI_connectionTimeoutMillis);
java.lang.System.setProperty('sun.rmi.transport.tcp.readTimeout', RMI_readTimeoutMillis);
java.lang.System.setProperty('sun.net.inetaddr.ttl', DNS_lookupIntervalSecs);

% Make sure we never try and load code from anywhere but local classpath
java.lang.System.setProperty('java.rmi.server.codebase', '');
java.lang.System.setProperty('java.rmi.server.useCodebaseOnly', 'true');

% Set the data store size. Use direct buffers for data transfers.
import com.mathworks.toolbox.distcomp.util.LargeDataInvoker;
maxMemory = sun.misc.VM.maxDirectMemory;
LargeDataInvoker.setDesiredDataStoreSize(floor(maxMemory/2));

% Initialize MatlabRefStore
com.mathworks.toolbox.distcomp.util.MatlabRefStore.initMatlabRef;


