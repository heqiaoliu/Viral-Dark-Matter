function obj = objectroot
; %#ok Undocumented
%OBJECTROOT A short description of the function
%
%  OBJ = OBJECTROOT

%  Copyright 2000-2008 The MathWorks, Inc.

%  $Revision: 1.1.8.8 $    $Date: 2008/12/29 01:48:05 $

obj = distcomp.objectroot;

% Create the properties for this object
obj.ProxyHashtable = java.util.Hashtable;
% Do not create the UDD adaptor to listen for events if we are on a worker
% that is not running under the jobmanager.
DO_NOT_CREATE_ADAPTOR = system_dependent('isdmlworker') && isempty(getenv('JOB_MANAGER_HOST'));
if DO_NOT_CREATE_ADAPTOR
    return
end
% This piece of persistence is a temporary workaround for g455671 - as soon as
% this bug is fixed we should stop mlocking this file and persisting theHandle
% and go back to simply calling handle on the singleton java object
persistent theHandle
if isempty(theHandle)
    theHandle = handle(com.mathworks.toolbox.distcomp.uddadaptor.ProxyToUddAdaptor.getInstance);
    mlock;
end
% Get a UDD version of the java object that will dispatch callback events
% into the UDD objects. This java object is exported such that the jobmanager
% can send us events.
obj.ProxyToUddAdaptor = theHandle; 
% We need a mechanism to get the actual events from a java RMI call directly
% into matlab - this is done via the java Bean interface of this java object
% However we also need to be careful of the lifetime of this java object, so
% We are very explicit in decoupling using listeners rather than matlab 
% Callbacks because this means that we don't store a reference to objectroot
% in the actual java layer - and hence clear classes will continue to work
obj.ProxyToUddAdaptorListener = handle.listener(...
        obj.ProxyToUddAdaptor, ...  
        'ProxyToUddAdaptorEvent', ...
        {@iDispatchJavaEvent, obj});
% Undocumented option to set the recursion limit on callbacks to 1024 - this
% is a silly number that will be bounded by the RecursionLimit in MATLAB. 
% Hopefully our demos will continue to work provided the main RecusionLimit
% is up'ed appropriately
set(obj.ProxyToUddAdaptorListener, 'RecursionLimit', 1024);

end

function iDispatchJavaEvent(src, event, obj)
    % Make sure that once this function is finished we let the java layer
    % know that we are finished
    o = onCleanup(@() src.matlabEventFinished(event.javaEvent));
    try
        % Get the actual event from the UDD wrapped event
        event = event.JavaEvent;
        % Find the udd object which this event is sourced by - the UUID of
        % the source is held in event.getSource which should be found in
        % the proxyHashtable.
        uddObj = handle(obj.proxyHashtable.get(event.getSource));
        % If we found a valid object then tell it to dispatch the
        % appropriate event as indicated in event.getID
        if ~isempty(uddObj)
            uddObj.pDispatchJavaEvent(src, event);
        end
    catch err  %#ok<NASGU>
        % Do nothing - swallow the error silently
    end
end
