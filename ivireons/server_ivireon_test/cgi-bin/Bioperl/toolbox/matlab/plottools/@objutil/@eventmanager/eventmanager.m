function obj = eventmanager(hTarget,varargin)

% Copyright 2007-2009 The MathWorks, Inc.

% EVENTMANAGER Propagates events from an object tree
%   Use this object for listening to an object tree. This object
%   will propagate property change events from any node within
%   a tree. An optional filter can be specified to reduce the set of
%   objects that will fire events.
%
%   A filter is a structure array with the following fields
%   classname  = name of the class
%   properties = cell array of property names
%   listentocreation = true/false whether to listen to creation events
%   listentodeletion = true/false whether to listen to deletion events
%   
%   Example 1:
%
%   function example
%   hline = plot(1:10); drawnow;
%   h = objutil.eventmanager(gcf);
%   li = handle.listener(h,'NodeChanged',@localcallback);
%   
%   % Changing the line will fire a node changed event
%   set(hline,'LineWidth',3);
%
%   function localcallback(obj,evd)
%   get(evd,'EventInfo')  % displays event information
%
%   For more examples, see teventmanager.m unit test

obj = objutil.eventmanager;

if ~isempty(hTarget) && ishghandle(hTarget)
    nin = nargin-1;
    if (nin>1)
        if rem(nin,2)~=0
           error('MATLAB:Graphics:eventreemanager','Incorrect number of arguments');
        end
        localInit(obj,hTarget,varargin{:});
    else
        localInit(obj,hTarget,{}); 
    end
end

%-----------------------------------------------------------------%
function localInit(hThis,hTarget,varargin)

hTarget = handle(hTarget);
hThis.RootNode = hTarget;
hThis.UseMCOS = feature('HGUsingMATLABClasses');
if (strcmp(varargin{1},'IncludeFilter'))
    if ~isstruct(varargin{2})
       error('MATLAB:Graphics:eventtreemanager','Filter must be a cell array');
    end
   hThis.Filter = varargin{2};
end

localAddListenersRecurse(hThis,hTarget);

%-----------------------------------------------------------------%
function localAddListenerWithNoFilterToObject(hThis,hTarget)
% Add listeners without using a filter

% Exclude objects with forbidden tags
if ~isempty(hThis.ExclusionTag) && strcmp(hThis.ExclusionTag,get(hTarget,'Tag'))
    return
end

% Flag to propagate any events to the client
doPropagate = true;

% Add listeners
if hThis.UseMCOS
    hCls = metaclass(hTarget);
    hProps = hCls.Properties;
    
    hListener = [event.listener(hTarget,'ObjectBeingDestroyed',...
                    localCreateFunctionHandle(@localObjectBeingDestroyedCallback,hThis,doPropagate)); ...
                 event.proplistener(hTarget,hProps,'PostSet',...
                    localCreateFunctionHandle(@localPropertyPostCallback,hThis,doPropagate))];
    % If hTarget is a leaf of the hg2 hiearchy, such as hg2.Lineseries, we should
    % not listen to objects being added since they can only be
    % user-invisible items such as primitive lines associated with data
    % brushing or markers associated with surfaces.
    if isa(hTarget,'matlab.graphics.axis.Axes')
        hListener = [hListener;...
                     event.listener(hTarget.ChildContainer,'ObjectChildAdded',...
                            localCreateFunctionHandle(@localObjectChildAddedCallback,hThis));...
                     event.listener(hTarget.ChildContainer,'ObjectChildRemoved',...
                            localCreateFunctionHandle(@localObjectChildRemovedCallback,hThis));...
                     event.listener(hTarget, 'MarkedClean',...
                        localCreateFunctionHandle(@localChildContainerUpdateCallback,hThis,hTarget.ChildContainer))];                       
        
    elseif isa(hTarget,'matlab.ui.Figure') || isa(hTarget,'matlab.ui.container.Panel')
        sv = hg2gcv(hTarget);
        hListener = [hListener;...
                     event.listener(sv,'ObjectChildAdded',...
                            localCreateFunctionHandle(@localObjectChildAddedCallback,hThis));...
                     event.listener(sv,'ObjectChildRemoved',...
                            localCreateFunctionHandle(@localObjectChildRemovedCallback,hThis))];         
    elseif isempty(ancestor(hTarget,'axes')) || isa(hTarget ,'hg2.HGGroup')
        hListener = [hListener;...
                     event.listener(hTarget,'ObjectChildAdded',...
                            localCreateFunctionHandle(@localObjectChildAddedCallback,hThis));...
                     event.listener(hTarget,'ObjectChildRemoved',...
                            localCreateFunctionHandle(@localObjectChildRemovedCallback,hThis))];       
    else
        hListener = [hListener;...
                    event.listener(hTarget,'ObjectChildRemoved',...
                    localCreateFunctionHandle(@localObjectChildRemovedCallback,hThis))];
    end
else
    hCls = classhandle(hTarget);
    hProps = get(hCls,'Properties');
    hListener(4) = handle.listener(hTarget,hProps,'PropertyPostSet',{@localPropertyPostCallback,hThis,doPropagate});
    hListener(3) = handle.listener(hTarget,'ObjectChildAdded',{@localObjectChildAddedCallback,hThis});
    hListener(2) = handle.listener(hTarget,'ObjectChildRemoved',{@localObjectChildRemovedCallback,hThis});
    hListener(1) = handle.listener(hTarget,'ObjectBeingDestroyed',{@localObjectBeingDestroyedCallback,hThis,doPropagate});
end
localAddListener(hThis,hTarget,hListener(:));


%-----------------------------------------------------------------%
function classname = localGetClassName(hObj,useMCOS)
% Build up formal class name (e.g. graph2d.lineseries)

if useMCOS
    m = metaclass(hObj);
    if ~isempty(m)
        classname = m.Name;
    else
         classname = '';
    end
else
    hCls = classhandle(hObj);
    pk = get(hCls,'Package');
    classname = [get(pk,'Name'),'.',get(hCls,'Name')];
end

%-----------------------------------------------------------------%
function [b,n] = localDoIncludeClassCreation(hThis,classname)

b = false;
filter = get(hThis,'Filter');
for n = 1:length(filter)
    if any(strcmpi(classname,filter(n).classname)) ...
           && isfield(filter(n),'listentocreation') ...
           && isequal(filter(n).listentocreation,true)
        b = true;
        break;
    end
end

%-----------------------------------------------------------------%
function [b,n] = localDoIncludeClass(hThis,classname)
% Loop through filter to see if the class name is registered

b = false;
filter = get(hThis,'Filter');
for n = 1:length(filter)
    if any(strcmpi(classname,filter(n).classname)) || ...
       isequal(filter(n).includeallchildren,true)
        b = true;
        break;
    end
end

    
%-----------------------------------------------------------------%
function b = localDoIncludeEventsForTarget(hThis,hTarget)

b = false;
filter = get(hThis,'Filter');
for n = 1:length(filter)
    if isfield(filter(n),'includeallchildren') && isequal(filter(n).includeallchildren,true)
         classname = filter(n).classname;
         hParent = ancestor(hTarget,classname);
         if ~isempty(hParent) && ~isequal(hParent,hTarget)
             b = true;
         end
    end
end

%-----------------------------------------------------------------%
function localAddListenerWithFilterToObject(hThis,hTarget)
% Add listeners based on filter

% Exclude objects with forbidden tags. Note that the ishghandle test is
% needed to exlcude scene viewer and camera objects
if ishghandle(hThis) && ~isempty(hThis.ExclusionTag) && ...
        strcmp(hThis.ExclusionTag,get(hTarget,'Tag'))
    return
end

filter = hThis.Filter;
if hThis.UseMCOS
    hCls = metaclass(hTarget);
else
    hCls = classhandle(hTarget);    
end
classname = localGetClassName(hTarget,hThis.UseMCOS);
[doinclude,n] = localDoIncludeClass(hThis,classname);

% Even if the object is filtered out, we still need to register
% add/remove/delete listeners to get any children
doPropagate = doinclude;
if hThis.UseMCOS
    if isa(hTarget,'matlab.graphics.axis.Axes')
        hChildListener = [event.listener(hTarget.ChildContainer,'ObjectBeingDestroyed',...
                                   localCreateFunctionHandle(@localObjectBeingDestroyedCallback,hThis,doPropagate)); ...
                          event.listener(hTarget.ChildContainer,'ObjectChildRemoved',...
                                   localCreateFunctionHandle(@localObjectChildRemovedCallback,hThis));...
                          event.listener(hTarget, 'MarkedClean',...
                             localCreateFunctionHandle(@localChildContainerUpdateCallback,hThis,hTarget.ChildContainer))];
    elseif isa(hTarget,'matlab.ui.Figure') || isa(hTarget,'matlab.ui.container.Panel')
        sv = hg2gcv(hTarget);
        hChildListener = [event.listener(sv,'ObjectBeingDestroyed',...
                                   localCreateFunctionHandle(@localObjectBeingDestroyedCallback,hThis,doPropagate)); ...
                          event.listener(sv,'ObjectChildRemoved',...
                                   localCreateFunctionHandle(@localObjectChildRemovedCallback,hThis))];
    else
        hChildListener = [event.listener(hTarget,'ObjectBeingDestroyed',...
                                   localCreateFunctionHandle(@localObjectBeingDestroyedCallback,hThis,doPropagate)); ...
                          event.listener(hTarget,'ObjectChildRemoved',...
                                   localCreateFunctionHandle(@localObjectChildRemovedCallback,hThis))];
    end
    % If hTarget is a leaf of the hg2 hiearchy, such as hg2.Lineseries, we should
    % not listen to objects being added since they can only be
    % user-invisible items such as primitive lines associated with data
    % brushing or markers associated with surfaces.
    if isa(hTarget,'matlab.graphics.axis.Axes')
       hChildListener = [hChildListener;...
                         event.listener(hTarget.ChildContainer,'ObjectChildAdded',...
                         localCreateFunctionHandle(@localObjectChildAddedCallback,hThis))];
    elseif isa(hTarget,'matlab.ui.Figure') || isa(hTarget,'matlab.ui.container.Panel')
        sv = hg2gcv(hTarget);
        hChildListener =  [hChildListener;...
                             event.listener(sv,'ObjectChildAdded',...
                                localCreateFunctionHandle(@localObjectChildAddedCallback,hThis))];
    elseif ~any(strcmp(classname,[filter.classname]))% && isprop(hTarget,'type')
       hChildListener = [hChildListener;...
                         event.listener(hTarget,'ObjectChildAdded',...
                         localCreateFunctionHandle(@localObjectChildAddedCallback,hThis))];   
    end
else
    hChildListener(3) = handle.listener(hTarget,'ObjectChildAdded',{@localObjectChildAddedCallback,hThis});
    hChildListener(2) = handle.listener(hTarget,'ObjectChildRemoved',{@localObjectChildRemovedCallback,hThis});
    hChildListener(1) = handle.listener(hTarget,'ObjectBeingDestroyed',{@localObjectBeingDestroyedCallback,hThis,doPropagate});
end
localAddListener(hThis,hTarget,hChildListener(:));

% Add property listeners if the property is registered
if doinclude
    if hThis.UseMCOS
        hProps = [hCls.Properties{:}];
    else
        hProps = get(hCls,'Properties');
    end
    propnamelist = filter(n).properties;
    if ~any([filter.includeallchildren]) && ~isempty(propnamelist)         
         hProps(~ismember(lower(localGetPropNames(hProps,hThis.UseMCOS)),...
             lower(propnamelist))) = [];
    end

    for m = 1:length(hProps)
        hProp = hProps(m);
        propname = hProp.Name;
        % property name is registered in filter
        doPropagate = isempty(propnamelist) || any(strcmpi(propname,propnamelist));
        if hThis.UseMCOS
             hListener(m) = event.proplistener(hTarget,hProp,'PostSet',...
                 @(es,ed) localPropertyPostCallback(es,ed,hThis,doPropagate));  %#ok<AGROW>
        else
             hListener(m) = handle.listener(hTarget,hProp,'PropertyPostSet',...
                 {@localPropertyPostCallback,hThis,doPropagate});  %#ok<AGROW>
        end
    end
    localAddListener(hThis,hTarget,hListener(:));
end


%-----------------------------------------------------------------%
function localAddListenersRecurse(hThis,hTarget)

if isempty(hThis.Filter)
   localAddListenerWithNoFilterToObject(hThis,hTarget);
else
   localAddListenerWithFilterToObject(hThis,hTarget);  
end

% Loop through children
hKids = localGetChildren(hTarget,hThis.UseMCOS);
for n = 1:length(hKids)
    if ~(isobject(hKids(n)) && isprop(hKids(n),'Internal') && ...
         hKids(n).Internal && isa(hKids(n).Parent,'hg2.DataObject'))
        localAddListenersRecurse(hThis,hKids(n));
    end
end

%-----------------------------------------------------------------%
function hKids = localGetChildren(hTarget,useMCOS)

if useMCOS
    hKids = findobj(hTarget);
    for k=1:length(hKids)
        if hKids(k)==hTarget
           hKids(k) = [];
           break;
        end
    end
else
    hKids = find(hTarget);
    % Remove self from list
    hKids(hKids==hTarget) = [];
end


%-----------------------------------------------------------------%
function localAddListener(hThis,hTarget,hListener)

KEY = 'eventmanagerlisteners__';
PROPKEY = 'eventmanagerproplisteners__';
% Store MCOS property listeners in a separate instance prop since they cannot
% concatenated with MCOS event.listeners.
if hThis.UseMCOS 
    if isa(hListener(1),'event.proplistener')   
        propName = PROPKEY;
    else
        propName = KEY;
    end
    % If not present, create an unserialized PROPKEY instance prop.
    if ~isprop(hTarget,propName)
        p = addprop(hTarget,propName);
        p.Transient = true;
        p.Hidden = true;
    end
    info = get(hTarget,propName);
    if ~isempty(info)
        info = [info;hListener];
    else
        info = hListener;
    end
    set(hTarget,propName,info);
else  
    info = getappdata(hTarget,KEY);
    if ~isempty(info)
        info = [info;hListener];
    else
        info = hListener;
    end
    setappdata(hTarget,KEY,info);
end

%-----------------------------------------------------------------%
function localObjectBeingDestroyedCallback(obj,evd,hThis,doPropagate) %#ok<INUSD>
% obj: object
% evd:
%      Type: 'ObjectBeingDestroyed'
%    Source: [1x1 figure]

% Only propagate if this is the root node since it will have no parent
% to notify of deletion

hObj = evd.Source;
if isequal(hThis.RootNode,hObj)
    classname = localGetClassName(hObj,hThis.UseMCOS);
    if localDoIncludeClassCreation(hThis,classname)
        if ishandle(hThis) && strcmpi(get(hThis,'Enable'),'on')
            hEvent = localCreateEvent(hThis,obj,evd);
            send(hThis,'NodeChanged',hEvent);
        end
    end
end

%-----------------------------------------------------------------%
function localObjectChildRemovedCallback(obj,evd,hThis)
% obj: parent object
% evd:
%      Type: 'ObjectChildRemoved'
%    Source: [1x1 figure]
%     Child: [1x1 uimenu]

% Listeners will automatically be removed since they are referenced only
% from the object being removed.

hChild = evd.Child;
classname = localGetClassName(hChild,hThis.UseMCOS);
if localDoIncludeClassCreation(hThis,classname)
    if ishandle(hThis) && strcmpi(get(hThis,'Enable'),'on')
        hEvent = localCreateEvent(hThis,obj,evd);
        send(hThis,'NodeChanged',hEvent);
    end
end

%-----------------------------------------------------------------%
function localObjectChildAddedCallback(obj,evd,hThis)
% obj: parent (e.g. axes)
% evd:
%      Type: 'ObjectChildAdded'
%    Source: [1x1 axes]
%     Child: [1x1 text]
     
hChild = evd.Child;
% Add new listeners for child
localAddListenersRecurse(hThis,hChild);

classname = localGetClassName(hChild,hThis.UseMCOS);
if localDoIncludeClassCreation(hThis,classname)
    if ishandle(hThis) && strcmpi(get(hThis,'Enable'),'on')
        hEvent = localCreateEvent(hThis,obj,evd);
        send(hThis,'NodeChanged',hEvent);
    end
end

%-----------------------------------------------------------------%
function localPropertyPostCallback(obj,evd,hThis,doPropagate)
% obj: 
% evd:
%              Type: 'PropertyPostSet'
%            Source: [1x1 schema.prop]
%    AffectedObject: [1x1 figure]
%          NewValue: [1 0 0]
          
hTarget = evd.AffectedObject;
if ishandle(hThis) && strcmpi(get(hThis,'Enable'),'on')
    if doPropagate || localDoIncludeEventsForTarget(hThis,hTarget)
        hEvent = localCreateEvent(hThis,obj,evd);
        send(hThis,'NodeChanged',hEvent);
    end
end

%-----------------------------------------------------------------%
function hEvent = localCreateEvent(hThis,src,evd) %#ok<INUSL>

% Create wrapper event data object, this is required
hEvent = handle.EventData(hThis,'NodeChanged');
schema.prop(hEvent,'EventInfo','handle');

% Create Event Info object
hEventInfo = [];
if hThis.UseMCOS
    if isa(evd,'event.PropertyEvent')
          hEventInfo = objutil.propertyevent;
          set(hEventInfo,'Type','PropertyPostSet');
          set(hEventInfo,'Source',evd.Source);
          set(hEventInfo,'AffectedObject',evd.AffectedObject);
          set(hEventInfo,'NewValue',evd.AffectedObject.(evd.Source.Name));
    else
        switch evd.EventName
            case 'ObjectChildRemoved'
                hEventInfo = objutil.childremovedevent;
                set(hEventInfo,'Type',evd.EventName);
                set(hEventInfo,'Source',evd.Source);
                set(hEventInfo,'Child',evd.Child);

            case 'ObjectChildAdded'
                hEventInfo = objutil.childaddedevent;
                set(hEventInfo,'Type',evd.EventName);
                set(hEventInfo,'Source',evd.Source);
                set(hEventInfo,'Child',evd.Child);
        end
    end
else
        switch get(evd,'Type')
            case 'ObjectChildRemoved'
                hEventInfo = objutil.childremovedevent;
                set(hEventInfo,'Type',get(evd,'Type'));
                set(hEventInfo,'Source',get(evd,'Source'));
                set(hEventInfo,'Child',get(evd,'Child'));

            case 'ObjectChildAdded'
                hEventInfo = objutil.childaddedevent;
                set(hEventInfo,'Type',get(evd,'Type'));
                set(hEventInfo,'Source',get(evd,'Source'));
                set(hEventInfo,'Child',get(evd,'Child'));

            case 'PropertyPostSet'
                hEventInfo = objutil.propertyevent;
                set(hEventInfo,'Type',get(evd,'Type'));
                set(hEventInfo,'Source',get(evd,'Source'));
                set(hEventInfo,'AffectedObject',get(evd,'AffectedObject'));
                set(hEventInfo,'NewValue',get(evd,'NewValue'));

       end
end

if isempty(hEventInfo)
   disp('')
end
% Wire up objects
set(hEvent,'EventInfo',hEventInfo);

% Local function for creating anonymous function handles with minimized
% scope.
function fH = localCreateFunctionHandle(fHin,varargin)

fH = @(es,ed) fHin(es,ed,varargin{:});

function propNames = localGetPropNames(hProps,useMCOS)

if useMCOS    
    propNames =  cell(size(hProps));
    for k=1:length(propNames)
        propNames{k} = hProps(k).Name;
    end
else
    propNames =  get(hProps,{'Name'});
end

% When an axes MarkedClean event occurs the listeners to the axes children
% must be rebuilt since the ChildContainer may have changed (e.g. in reponse
% to a 2d<->3d view change)
function localChildContainerUpdateCallback(ax,~,hThis,childContainer)

if isequal(ax.childContainer,childContainer)
    return
end

% Construct and chldremoved event and use it to fire the ch
evd = objutil.childremovedevent;
evd.Source = get(ax,'Parent');
evd.Child = ax;
localObjectChildRemovedCallback(evd.Source,evd,hThis);

% Construct and childadded event and use it to fire the ObjectChildAdded
% callback
evd = objutil.childaddedevent;
evd.Source = get(ax,'Parent');
evd.Child = ax;
localObjectChildAddedCallback(evd.Source,evd,hThis);