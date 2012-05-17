function schema
%Schema for the uitabgroup class.
%   This is a subclass of the uicontainer
%   component. It defines three new properties in addition to the default
%   uicontainer properties
%
%   This class has a Java Peer.
%
%   Selectedindex - The currently selected tab.
%   SelectionChangeFcn - Callback function invoked when the SelectedObject changes.
%   TabPlacement - The orientation of the tabs (TOP/LEFT/BOTTOM/RIGHT).

%   Copyright 2004-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.10 $  $Date: 2010/05/20 02:30:22 $

% Package and class info
pk = findpackage('uitools');
hg = findpackage('hg');
baseclass = hg.findclass('uiflowcontainer');

class = schema.class(pk,'uitabgroup', baseclass);

% Selected Index property
p = schema.prop(class, 'SelectedIndex', 'int');
set(p, 'FactoryValue', 0);
set(p, 'SetFunction', @setSelectedIndex);


% SelectedTab property 
paliased = schema.prop(class, 'SelectedTab', 'handle');
set(paliased, 'FactoryValue', handle([]));
set(paliased, 'SetFunction', @setSelectedTab);
set(paliased, 'Visible', 'off');

% SelectionChangeFcn (MATLAB callback) & the SelectionChange event
schema.prop(class, 'SelectionChangeFcn', 'MATLAB callback');
schema.event(class, 'SelectionChanged');
% Aliasing for name changes
schema.prop(class, 'SelectionChangeCallback', 'MATLAB callback');

% TabLocation property [Add new enumeration type]
if isempty(findtype('TabLocationEnum'))
  schema.EnumType('TabLocationEnum', {'top', 'left', 'bottom', 'right'});
end
p = schema.prop(class, 'TabLocation', 'TabLocationEnum');
set(p, 'FactoryValue', 'top');

%Type
p = schema.prop(class, 'Type', 'String');
set(p, 'AccessFlags.PublicGet','on','AccessFlags.PublicSet','off');
set(p, 'FactoryValue', 'uitabgroup');
set(p, 'GetFunction', @getType);

% Private Hidden properties
% The JavaPeer and the HgContainer
p = schema.prop(class, 'JavaPeer', 'handle');
set(p, 'AccessFlags.PublicGet','off','AccessFlags.PublicSet','off', ...
       'AccessFlags.PrivateGet','on','AccessFlags.PrivateSet','on',...
       'AccessFlags.Copy', 'off',...
       'AccessFlags.Serialize', 'off', 'Visible', 'off');
p = schema.prop(class, 'HgContainer', 'handle');
set(p, 'AccessFlags.PublicGet','off','AccessFlags.PublicSet','off', ...
       'AccessFlags.PrivateGet','on','AccessFlags.PrivateSet','on',...
       'AccessFlags.Copy', 'off',...
       'AccessFlags.Serialize', 'off', 'Visible', 'off');


% This is used to store all the listeners.
p = schema.prop(class, 'Listeners', 'MATLAB array');
set(p, 'AccessFlags.PublicGet','off','AccessFlags.PublicSet','off', ...
       'AccessFlags.PrivateGet','on','AccessFlags.PrivateSet','on',...
       'AccessFlags.Copy', 'off',...
       'AccessFlags.Serialize', 'off', 'Visible', 'off');  

% The following is a very sneaky way to attach a "static" class listener
% in MATLAB-udd. We attach a class instance created listener on a property
% of the class in the schema itself. This ensures three things:
% 1. There is only one such listener on the class (which is what we want).
% 2. The listener has the same life-cycle as the class.
% 3. This listener is fired even for the first instance that is created.
% If this sticks, we may need to formalize this for other hg MATLAB-udd objects.
schema.prop(p, 'ClassListener', 'handle');
p.ClassListener = handle.listener(class, 'ClassInstanceCreated', @instanceCreated);

%//////////////////////////////////////////////////////////////////////////
function instanceCreated(src, evt)
h = evt.Instance;

% Create the UITabgroup (Java) Peer, and parent it to this container
h.FlowDirection = 'topdown';
h.JavaPeer = handle(com.mathworks.hg.peer.UITabGroupPeer);
comp = h.JavaPeer.getComponent();
%Don't lose the handle to the JTabbedPane because we need to add a
%StateChanged listener
setappdata(h, 'JTabbedPane', comp);

% The combination of the JTabbedPane's SCROLL_LAYOUT & Panel as its parent
% (& JVM 1.5!!!) doesn't repaint correctly.  So, I am inserting a JPanel 
% that does the trick
% TODO replace this with a call to awtcreate
jpanel = javax.swing.JPanel(java.awt.BorderLayout);
jpanel.add(comp, 'Center');

% the below reference to h.parent assumes h.parent is never empty
[~, h.HgContainer] = javacomponent(jpanel,[1 1 1 1], h.parent);

set(h.HgContainer, 'HandleVisibility', 'off');
% I need to set the opaque property of the component to 'on' so that the
% flowcontainer will manage this child (this needs to change)
% Setting the opaque to 'on', will break Mac (when javafigure is turned
% on:-) - the uicontainer will render on top of the javapeer & the javapeer
% will be invisible - this needs to be changed before that
set(h.HgContainer, 'Opaque', 'on');
set(h.HgContainer, 'Parent', h);
set(handle(comp,'callbackproperties'), 'StateChangedCallback', {@onSelChanged, h});


% Listen to the properties of the base class that need interaction with
% the Java Peer
listeners = get(h, 'Listeners');
listeners{end+1} = handle.listener(h, 'ObjectChildAdded', ...
    {@childAddedCallback, h.JavaPeer, h.HgContainer});
listeners{end+1} = handle.listener(h, 'ObjectChildRemoved', ...    
    {@childRemovedCallback, h.JavaPeer});
listeners{end+1} = handle.listener(h, findprop(h, 'Children'), ...
    'PropertyPostSet', {@childrenPermutedCallback, h.JavaPeer});
listeners{end+1} = handle.listener(h, findprop(h, 'BackgroundColor'), ...
    'PropertyPostSet', {@backgroundColorCallback, h.JavaPeer});
listeners{end+1} = handle.listener(h, findprop(h, 'SelectedIndex'), ...
    'PropertyPostSet', {@selectedIndexCallback, h.JavaPeer});
listeners{end+1} = handle.listener(h, findprop(h, 'TabLocation'), ...
    'PropertyPostSet', {@tabLocationCallback, h.JavaPeer, h.HgContainer});
listeners{end+1} = handle.listener(h, findprop(h, 'Visible'), ...
    'PropertyPostSet', {@tabVisibleCallback, h.JavaPeer, h.HgContainer});
listeners{end+1} = handle.listener(h, findprop(h, 'SelectedTab'), ...
    'PropertyPostSet', {@selectedTabCallback});
set(h,'Listeners', listeners);

% Force the background color, font and other props (inherited from
% uicontainer),  because HG sets the property before this method is called
evt2.AffectedObject = h; 
evt2.NewValue = get(h, 'BackgroundColor');
backgroundColorCallback([], evt2, h.JavaPeer);


%//////////////////////////////////////////////////////////////////////////
function childAddedCallback(src, evt, javapeer, hgContainer)
hChild = evt.Child;
if (~isa(handle(hChild), 'uitools.uitab'))
    %THIS IS NOT ALLOWED - Only uitabpanel(s) can be children
    
    % For now, the reparenting has already happened, and hence we can't do
    % any better than reparent the child to gcf.
    % In future, the error check must happen even before the reparenting
    % has occurred (& an error raised prior to the reparenting)   
    set(hChild, 'Parent', gcf);
    error('MATLAB:schema:CannotBeParent', 'A uitabgroup cannot be the parent of a %s.\n Hence, the %s has been reparented to the gcf', ...
        get(hChild, 'type'), get(hChild, 'type') );  
end

% Add the new tab to the javapeer and force it to happen before I get the
% preferred size
javapeer.addTab(get(hChild, 'Title'));
% Note: this will force through the selection change fcn
drawnow;
%Set the size of the HgUicontainer based on the comp's size
LdoLayout(src, javapeer, hgContainer);

% Listen to properties of the child (ex. Title) tha require action to be
% taken on the javapeer
listener = handle.listener(hChild, hChild.findprop('Title'), ...
     'PropertyPostSet', {@childTitleCallback, src, javapeer});
setappdata(double(hChild),'TabGroupChildListener', listener);

% Switch the order of the children
children = allchild(double(src));
childrenNew = [children(2:end-1); children(1); children(end)];
set(double(src), 'Children', childrenNew);

%//////////////////////////////////////////////////////////////////////////
function childRemovedCallback(src, evt, javapeer)
if (isa(handle(evt.Child), 'uitools.uitab'))
    index = find(handle(getVisibleChildren(src)) == evt.Child);
    javapeer.removeTab(index-1);
    % Remove self as listener to the child's properties (ex. Title)
    listener = getappdata(double(evt.Child), 'TabGroupChildListener');
    delete(listener);
    setappdata(double(evt.Child),'TabGroupChildListener', []);
end

%//////////////////////////////////////////////////////////////////////////
function childrenPermutedCallback(src, ~, javapeer)
arrTitles = get(getVisibleChildren(src), 'Title');
javapeer.setAllTabTitles(arrTitles);

%//////////////////////////////////////////////////////////////////////////
function childTitleCallback(~, evt, tabgroup, javapeer)
index = find(handle(getVisibleChildren(tabgroup)) == evt.AffectedObject);
javapeer.setTabTitle(index-1, evt.NewValue);

%//////////////////////////////////////////////////////////////////////////
function backgroundColorCallback(~, evt, javapeer)
col = evt.NewValue;
javapeer.setControlBackgroundColor(java.awt.Color(col(1), col(2), col(3)));

%//////////////////////////////////////////////////////////////////////////
function onSelChanged(~, evt, tabgroup)
if (isBlockingChangeEvents(tabgroup))
    return;
end
index = evt.getSource().getSelectedIndex() + 1;
% Sanity check - Make sure that the tabgroup is a tabgroup
if (isa(tabgroup, 'uitools.uitabgroup') == 0)
    return;
end
indexOld = get(tabgroup,'SelectedIndex');
%Run the selection callback
if (index ~= indexOld)
    runSelectionChangeFcn(tabgroup, indexOld, index);
%     runSelectionChangeCallback(tabgroup, indexOld, index);
end
%Change the state
set(tabgroup,'SelectedTab',getTabAt(tabgroup,index));

%//////////////////////////////////////////////////////////////////////////
% Run the old callback
function runSelectionChangeFcn(tabgroupRef, oldIndex, newIndex)
cbk = get(tabgroupRef,'SelectionChangeFcn');
if ~isempty(cbk);
    source = double(tabgroupRef);
    evtdata.EventName = 'SelectionChanged';
    evtdata.OldValue = oldIndex;
    evtdata.NewValue = newIndex;
    hgfeval(cbk, source, evtdata);
end
% Run the new callback
function runSelectionChangeCallback(tabgroupRef, oldIndex, newIndex)
cbkAlias = get(tabgroupRef, 'SelectionChangeCallback');
if ~isempty(cbkAlias);
    evtdata.EventName = 'SelectionChange';
    evtdata.OldValue = handle(getTabAt(tabgroupRef,oldIndex));
    evtdata.NewValue = handle(getTabAt(tabgroupRef,newIndex));
    hgfeval(cbkAlias, tabgroupRef, evtdata);
end

%//////////////////////////////////////////////////////////////////////////
% Update the visibility based on selection of tabs
function updateVisibilityOfTabs(tabgroupRef)
%NOTE: If index==indexOld, then the selectedIndex was changed
%programmatically
index = get(tabgroupRef,'SelectedIndex');
children =  handle(findobj(getVisibleChildren(tabgroupRef),'Type','uitab'));
%Hide the old tabpanel & show the new tabpanel
for i=1:length(children)
    if strcmpi(get(children(i), 'Visible'), 'on')
        children(i).updateVisibility();
    end
end
% If all the tabs have been removed, the newly selectedIndex will be
% zero - in that case, don't do anything further.
if (index <= 0)
    return;
end
children(index).updateVisibility();

%//////////////////////////////////////////////////////////////////////////
function evt = setSelectedIndex(src, evt)
enterBlockingChangeEventsContext(src);
children = getVisibleChildren(src);
if (evt > length(children) || evt < 0 || (evt==0 && ~isempty(children)))   
    exitBlockingChangeEventsContext(src);
    error('MATLAB:schema:InvalidIndex', 'Selected Index has to be between 1 and the number of tabs');
end

%//////////////////////////////////////////////////////////////////////////
function selectedIndexCallback(~, evt, javapeer)
% Tell the JavaPeer to change the selected tab
javapeer.setSelectedIndex(get(evt.AffectedObject,'SelectedIndex')-1);
% Throw the SelectionChanged Event.
hThis = evt.AffectedObject;
hEvent = handle.EventData(hThis, 'SelectionChanged');
send(hThis, 'SelectionChanged', hEvent);
drawnow;
updateVisibilityOfTabs(hThis);
exitBlockingChangeEventsContext(evt.AffectedObject);
set(hThis,'SelectedTab',getTabAt(evt.AffectedObject, get(evt.AffectedObject,'SelectedIndex')));
%//////////////////////////////////////////////////////////////////////////
function c = enterBlockingChangeEventsContext(tabgroup)
setappdata(tabgroup,'BlockChangeEvents',true);
c = onCleanup(@() setappdata(tabgroup,'BlockChangeEvents',false));
setappdata(tabgroup,'Cleanup',c);
%//////////////////////////////////////////////////////////////////////////
function exitBlockingChangeEventsContext(tabgroup)
if (ishandle(tabgroup) &&  isappdata(tabgroup,'Cleanup'))
    delete(getappdata(tabgroup,'Cleanup'));
end
%//////////////////////////////////////////////////////////////////////////
function val = isBlockingChangeEvents(tabgroup)
val = false;
if (ishandle(tabgroup) && isappdata(tabgroup,'BlockChangeEvents'))
    val = getappdata(tabgroup,'BlockChangeEvents');
end

%//////////////////////////////////////////////////////////////////////////
function newValue = setSelectedTab(src, newValue)
if ~(isequal(get(newValue,'Parent'),double(src)))
    error('MATLAB:schema:InvalidTab', 'SelectedTab must be a child of this parent');
end

%//////////////////////////////////////////////////////////////////////////
function selectedTabCallback(~,evt)
children =  getVisibleChildren(evt.AffectedObject);
vecOfChildHandles = cell2mat(arrayfun(@(x) handle(x), children,'UniformOutput',false));
newIndex = find(ismember(vecOfChildHandles,evt.NewValue));
oldIndex = get(evt.AffectedObject,'SelectedIndex');
if (newIndex~=oldIndex)
    runSelectionChangeCallback(evt.AffectedObject, oldIndex, newIndex);
    set(evt.AffectedObject,'SelectedIndex',newIndex );
end



%//////////////////////////////////////////////////////////////////////////
function tab = getTabAt(tabgroup, index)
children = getVisibleChildren(tabgroup);
tab = handle([]);
if ~isempty(children)
    try
        tab = children(index);
    catch ex
        if ~strcmpi(ex.identifier,'MATLAB:badsubscript')
            rethrow(ex);
        end
    end
end

%//////////////////////////////////////////////////////////////////////////
function tabLocationCallback(~, evt, javapeer, hgContainer)
location = evt.NewValue;

if (strcmpi(location, 'left'))    
    pos = 2;
elseif (strcmpi(location, 'bottom'))
    pos = 3;
elseif (strcmpi(location, 'right'))
    pos = 4;
else %if (strcmpi(location, 'top'))
    pos = 1; %Default to top
end
javapeer.setTabPlacement(pos)
% Force the container to doLayout
LdoLayout(evt.AffectedObject, javapeer, hgContainer)

%//////////////////////////////////////////////////////////////////////////
function tabVisibleCallback(~, evt, ~, hgContainer)
set(hgContainer, 'Visible', evt.NewValue);
% if (strcmpi(evt.NewValue, 'on'))
%     javapeer.setControlVisible(true);
% else
%     javapeer.setControlVisible(false);
% %     set(javapeer, 'ControlVisible', false);
% end

%//////////////////////////////////////////////////////////////////////////
function LdoLayout(tabgroup, javapeer, hgContainer)
tabgroup = handle(tabgroup);
location = get(tabgroup, 'TabLocation');
comp = javapeer.getComponent;
height = comp.getPreferredSize().height;
width = comp.getPreferredSize().width;
hgContainer = handle(hgContainer);

if (strcmpi(location, 'left'))
    tabgroup.FlowDirection = 'lefttoright';
    hgContainer.WidthLimits = [width width];
    hgContainer.HeightLimits = [2 Inf];
elseif (strcmpi(location, 'bottom'))
    tabgroup.FlowDirection = 'bottomup';
    hgContainer.HeightLimits = [height height];
    hgContainer.WidthLimits = [2 Inf];
elseif (strcmpi(location, 'right'))
    tabgroup.FlowDirection = 'righttoleft';
    hgContainer.WidthLimits = [width width];
        hgContainer.HeightLimits = [2 Inf];
else %if (strcmpi(location, 'top'))
    tabgroup.FlowDirection = 'topdown';
    hgContainer.HeightLimits = [height height];
    hgContainer.WidthLimits = [2 Inf];
end
% Force the container to redo flowlayout
refresh(ancestor(hgContainer.parent,'figure'))

%//////////////////////////////////////////////////////////////////////////
function ch = getVisibleChildren(tabgroup)
oldState = get(0,'ShowHiddenHandles');
c = onCleanup(@() set(0,'ShowHiddenHandles',oldState));
set(0,'ShowHiddenHandles','off');
ch = get(tabgroup,'Children');

%//////////////////////////////////////////////////////////////////////////
function result = getType(~, ~)
result = 'uitabgroup';







