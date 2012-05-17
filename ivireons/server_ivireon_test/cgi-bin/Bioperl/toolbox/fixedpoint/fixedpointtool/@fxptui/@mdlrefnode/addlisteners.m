function addlisteners(h)
%ADDLISTENERS  adds listeners to this object

%   Author(s): G. Taillefer
%   Copyright 2006-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2008/10/08 17:10:57 $

try
    load_system(h.daobject.ModelName);
    % Add listener to react to changes in name of the Model block.
    if numel(h.listeners) == 0
        h.listeners = handle.listener(h.daobject, 'NameChangeEvent', @(s,e)locfirepropertychange(h,e));
    else
        h.listeners(end+1) = handle.listener(h.daobject, 'NameChangeEvent', @(s,e)locfirepropertychange(h,e));
    end
    h.listeners(end+1) = handle.listener(h.daobject, findprop(h.daobject, 'DefaultDataLogging'), 'PropertyPostSet', @(s,e)locloggingchange(e,h));
    % Add a listener to react to changes in the ModelName parameter. By default, when a model is loaded for the first time, Simulink triggers Hierarchy changed events and the UI gets
    % updated correctly. But if you change the ModelName to a model that is already in memory, simulink will not fire any events. The client is responsible for
    % triggering the correct events.
    ed = DAStudio.EventDispatcher;
    h.listeners(end+1) = handle.listener(ed,'PropertyChangedEvent', @(s,e)locpropertychange(h,s,e));
    % We don't need listeners for now on the referenced model because we don't show it in the Tree Hierarchy.
    %h.mdlref = get_param(h.daobject.ModelName, 'Object');
    %h.listeners(4) = handle.listener(h.mdlref, 'ObjectChildAdded', @(s,e)objectadded(h,s,e));
    %h.listeners(5) = handle.listener(h.mdlref, 'ObjectChildRemoved', @(s,e)objectremoved(h,s,e));
catch e %#ok<NASGU> % We do not want to throw this exception here.
    return;
end

%--------------------------------------------------------------------------
function locloggingchange(e,h)
if(~strcmpi(e.NewValue, h.daobject.DefaultDataLogging))
  h.setlogging(e.NewValue);
end

%--------------------------------------------------------------------------
function locpropertychange(h,s,e)

if isequal(e.Source,h.daobject)
    h.firepropertychange;
end

%--------------------------------------------------------------------------
function locfirepropertychange(h,e)
% Update the cachedFullName and trigger a property changed event
h.CachedFullName = fxptds.getpath(e.Source.getFullName);
h.firepropertychange;

%-------------------------------------------------------------------------


% [EOF]
