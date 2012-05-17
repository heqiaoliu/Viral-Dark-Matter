function obj = jobmanager(proxyManager)
; %#ok Undocumented
%Protected constructor for jobmanager matlab objects that is called by
%findresource to create appropriate objects

% Copyright 2004-2010 The MathWorks, Inc.

% Construct the base object
obj = distcomp.jobmanager;
% Call abstract base class constructor
obj.abstractjobqueue(proxyManager);
% Set the Type
obj.Type = 'jobmanager';

% This class accepts configurations and uses the scheduler section.
sectionName = 'scheduler';
obj.pInitializeForConfigurations(sectionName);
try
    obj.CachedName = char(proxyManager.getName);
    obj.LookupURL = char(proxyManager.getLookupURL);    
    % Set the job and task accessProxies
    obj.JobAccessProxy  = proxyManager.getJobAccess;
    obj.ParallelJobAccessProxy = proxyManager.getParallelJobAccess;
    obj.TaskAccessProxy = proxyManager.getTaskAccess;

    % Make this job manager proxy and all its access proxies use a
    % persistent credential store and the same credential consumer factory.
    if ~system_dependent('isdmlworker')
        credStore = obj.ProxyObject.createCredentialStore();
        obj.pSetCredentialStore(credStore);

        % Get the default consumer factory and set it in the jobmanager.
        import com.mathworks.toolbox.distcomp.auth.credentials.consumer.*;
        consumerFactory = CredentialConsumerFactory.getDefault();
        obj.pSetCredentialConsumerFactory(consumerFactory);
    end
catch err
    % Catch a possible ProxySerialization exception
    throw(distcomp.handleJavaException(obj, err));
end
