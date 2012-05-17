function init(h)
%INIT Initlialize legend listeners and application data
%  INIT(H) initializes the legend state for legend H.

%   Copyright 1984-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.11 $ $Date: 2008/12/04 22:40:49 $

hax = h.Axes;
ax = double(hax);
fig = ancestor(h, 'figure');


% prevent addition of title, xlabel and ylabel
setappdata(double(h),'MWBYPASS_title',{graph2dhelper('noop')});
setappdata(double(h),'MWBYPASS_xlabel',{graph2dhelper('noop')});
setappdata(double(h),'MWBYPASS_ylabel',{graph2dhelper('noop')});
setappdata(double(h),'MWBYPASS_zlabel',{graph2dhelper('noop')});
setappdata(double(h),'NonDataObject',[]);
setappdata(double(h),'PostDeserializeFcn',graph2dhelper('legendpostdeserialize'));
set(double(h),'Tag','legend');

%set up listeners-----------------------------------------
l= handle.listener(h,h.findprop('Position'),...
    'PropertyPostSet',{@changedPos,h,'position'});
l(end+1)= handle.listener(h,h.findprop('OuterPosition'),...
    'PropertyPostSet',{@changedPos,h,'outerposition'});
l(end+1)= handle.listener(h,h.findprop('Units'),...
    'PropertyPreSet',{@changedUnits,h,'off'});

% the units post-set must be listener number 4. see the callback
% for details
l(end+1)= handle.listener(h,h.findprop('Units'),...
    'PropertyPostSet',{@changedUnits,h,'on'});
l(end+1)= handle.listener(h,h.findprop('Position'),...
    'PropertyPreGet',{@computePos,h});
l(end+1)= handle.listener(h,h.findprop('OuterPosition'),...
    'PropertyPreGet',{@computePos,h});
l(end+1)= handle.listener(h,h.findprop('Location'),...
    'PropertyPostSet',{@changedLocation,ax});
l(end+1)= handle.listener(h,h.findprop('Orientation'),...
    'PropertyPostSet',{@changedOrientation,ax});
l(end+1)= handle.listener(h,h.findprop('TextColor'),...
    'PropertyPostSet',@changedTextColor);
l(end+1)= handle.listener(h,h.findprop('Interpreter'),...
    'PropertyPostSet',@changedFontProperties);
l(end+1)= handle.listener(h,h.findprop('Box'),...
    'PropertyPostSet',@changedBox);
l(end+1)= handle.listener(h,h.findprop('String'),...
    'PropertyPostSet',@changedString);
l(end+1)= handle.listener(h,h.findprop('Visible'),...
    'PropertyPostSet',@changedVisibility);
l(end+1)= handle.listener(h,h.findprop('FontName'),...
    'PropertyPostSet',@changedFontProperties);
l(end+1)= handle.listener(h,h.findprop('FontSize'),...
    'PropertyPostSet',@changedFontProperties);
l(end+1)= handle.listener(h,h.findprop('FontWeight'),...
    'PropertyPostSet',@changedFontProperties);
l(end+1)= handle.listener(h,h.findprop('FontAngle'),...
    'PropertyPostSet',@changedFontProperties);
l(end+1)= handle.listener(h,h.findprop('LineWidth'),...
    'PropertyPostSet',@changedLineWidth);
hparent = handle(get(h,'Parent'));
l(end+1)= handle.listener(hparent,'ResizeEvent', {@setWidthHeight,h});
l(end+1)= handle.listener(h,'LegendInfoChanged',@changedLegendInfo);
h.PropertyListeners = l;
l = handle.listener(h,'ObjectBeingDestroyed',{@legendDeleted,h});
h.DeleteListener = l;

% add listeners to figure
if ~isprop(handle(fig),'ScribeLegendListeners')
    l = schema.prop(handle(fig),'ScribeLegendListeners','MATLAB array');
    l.AccessFlags.Serialize = 'off';
    l.Visible = 'off';
end
if (isempty(get(fig, 'ScribeLegendListeners')))
    cls = classhandle(handle(fig));
    flis.currentaxes = handle.listener(handle(fig), cls.findprop('CurrentAxes'),...
        'PropertyPostSet', @changedCurrentAxes);
    set(handle(fig),'ScribeLegendListeners',flis);
end

if ~isempty(hax)
    % add listeners to plotaxes
    if ~isprop(hax,'ScribeLegendListeners')
        l = schema.prop(hax,'ScribeLegendListeners','MATLAB array');
        l.AccessFlags.Serialize = 'off';
        l.Visible = 'off';
    end
    cls = classhandle(hax);
    lis.fontname = handle.listener(hax, cls.findprop('FontName'),...
        'PropertyPostSet', {@PlotAxesChangedFontProperties,h});
    lis.fontsize = handle.listener(hax, cls.findprop('FontSize'),...
        'PropertyPostSet', {@PlotAxesChangedFontProperties,h});
    lis.fontweight = handle.listener(hax, cls.findprop('FontWeight'),...
        'PropertyPostSet', {@PlotAxesChangedFontProperties,h});
    lis.fontangle = handle.listener(hax, cls.findprop('FontAngle'),...
        'PropertyPostSet', {@PlotAxesChangedFontProperties,h});
    lis.linewidth = handle.listener(hax, cls.findprop('LineWidth'),...
        'PropertyPostSet', {@PlotAxesChangedLineWidth,h});
    lis.deleted = handle.listener(hax, 'ObjectBeingDestroyed', {@PlotAxesDeleted,h});
    if isequal(h.PlotChildListen,'on')
        lis.childadded = handle.listener(hax, 'ObjectChildAdded', {@PlotAxesChildAdded,h});
    end
    existing_proxy = findall(ax,'tag','LegendDeleteProxy');
    if ~isempty(existing_proxy)
        set(existing_proxy,'DeleteFcn','');
        if length(existing_proxy) > 1
            delete(existing_proxy(2:end));
        end
        h.DeleteProxy = handle(existing_proxy(1));
    else
        h.DeleteProxy = handle(text('parent',ax,...
            'visible','off', ...
            'tag','LegendDeleteProxy',...
            'handlevisibility','off'));
    end
    lis.proxydeleted = handle.listener(h.DeleteProxy, 'ObjectBeingDestroyed', {@PlotAxesCleared,h});
    set(hax,'ScribeLegendListeners',lis);

    % add listeners to plotchildren
    if ~isempty(h.Plotchildren) && ~isa(h.Plotchildren(1),'scribe.legendinfo')
        hpch = h.Plotchildren;
        pch = double(hpch);
        methods(h,'create_plotchild_listeners',hpch,pch)
    end
end

methods(h,'set_contextmenu','on');

%Add Button down function
set(double(h),'ButtonDownFcn',methods(h,'getfunhan','bdowncb'));

% set correct state of cbar toggle and menuitem
if ~isempty(ax)
    graph2dhelper('updateLegendMenuToolbar', [], [], ax);
    legendcolorbarlayout(ax,'on')
    legendcolorbarlayout(ax,'addToLayoutList',double(h))
    legendcolorbarlayout(ax,'layout')
end
setWidthHeight([],[],h);

% Add the bdwncb for each textobject
% texthandle = h.ItemText;
% for (k=1:length(texthandle))
%     set(texthandle(k),'ButtonDownFcn',methods(h,'getfunhan','tbdowncb',k));
% end

%----------------------------------------------------------------%
% LISTENER CALLBACKS
%----------------------------------------------------------------%


%----------------------------------------------------------------------%
% Callback fired when Units change Pre and Post to enable/disable
% position listeners
function changedUnits(hProp,eventData,h,state) %#ok
list = h.PropertyListeners;
list(4) = []; % units post-set listener must be item 4
set(list,'enable',state)

%----------------------------------------------------------------------%
% Callback fired when Location changes.
function changedLocation(hProp,eventData,ax) %#ok
h = eventData.affectedObject;
setappdata(double(h),'LegendComputePosCache',[]);
if ~isempty(ax)
    legendcolorbarlayout(ax,'removeFromLayoutList',double(h))
    legendcolorbarlayout(ax,'addToLayoutList',double(h))
    legendcolorbarlayout(ax,'layout');
end
methods(h,'update_userdata');

%----------------------------------------------------------------------%
% Callback fired when Orientation changes.
function changedOrientation(hProp,eventData,ax) %#ok
h = eventData.affectedObject;
setappdata(double(h),'LegendComputePosCache',[]);
methods(h,'layout_legend_items');
methods(h,'update_userdata');
if isempty(ax)
    setWidthHeight([],[],h)
elseif strcmp(get(h,'Location'),'BestOutside')
    legendcolorbarlayout(ax,'removeFromLayoutList',double(h))
    legendcolorbarlayout(ax,'addToLayoutList',double(h))
    legendcolorbarlayout(ax,'layout');
else
    legendcolorbarlayout(ax,'objectChanged',double(h))
end

%----------------------------------------------------------------%
function computePos(hProp,eventData,h) %#ok
if ~isempty(h.Axes) && isempty(getappdata(double(h.Axes),'inLayout'))
    oldPos = getappdata(double(h.Axes),'LegendComputePosCache');
    axPos = get(h.Axes,'Position');
    if ~isequal(oldPos,axPos)
        legendcolorbarlayout(h.Axes,'layoutNoPixelBounds');
    end
end

%----------------------------------------------------------------%
function changedPos(hProp,eventData,h,prop) %#ok

if strcmp(get(h,'ActivePositionProperty'),prop) && ...
        (isempty(h.Axes) || ...
        isempty(getappdata(double(h.Axes),'inLayout')))
    set(h,'Location','none');
    setappdata(double(h),'LegendOldSize',[]);
    setWidthHeight([],[],h);
    methods(h,'update_userdata');
end

%----------------------------------------------------------------%
function changedVisibility(hProp,eventData) %#ok

h=eventData.affectedObject;
if isequal(h.ObserveStyle,'on')
    ax = double(h);
    vis = get(ax,'Visible');
    set(ax,'ContentsVisible',vis);
end

%----------------------------------------------------------------%
function changedTextColor(hProp,eventData) %#ok

h=eventData.affectedObject;
set(h.ItemText,'Color',h.TextColor);

%----------------------------------------------------------------%
function changedBox(hProp,eventData) %#ok

h=eventData.affectedObject;
if isequal(h.ObserveStyle,'on')
    h.ObserveStyle = 'off';
    if isequal(h.box,'off')
        set(double(h),'visible','off');
        set(double(h.ItemText),'visible','on');
        set(double(h.ItemTokens),'visible','on');
    else
        set(double(h),'visible','on');
    end
    h.ObserveStyle='on';
end

%----------------------------------------------------------------%
% Set the legend width and height to be constant as the parent
% resizes when in normalized units
function setWidthHeight(hSrc,eventData,h) %#ok
if ishandle(h) && strcmp(get(h,'Units'),'normalized') && ...
        any(strcmp(get(h,'Location'),{'none','Best'}))
    if ~isempty(h.Axes) && ~isempty(getappdata(double(h.Axes),'inLayout')), return; end
    pos = get(h,'Position');
    oldsize = getappdata(double(h),'LegendOldSize');
    parent = get(h,'Parent');
    fig = parent;
    if ~strcmp(get(fig,'Type'),'figure')
        fig = ancestor(fig,'figure');
    end
    if isempty(oldsize)
        oldsize = pos(3:4);
    else
        oldsize = hgconvertunits(fig,[0 0 oldsize],'points',get(h,'Units'),parent);
        oldsize = oldsize(3:4);
    end
    siz = max(methods(h,'getsize'),oldsize);
    if any(abs(siz-pos(3:4)) > 1e-10)
        center = pos(1:2)+pos(3:4)/2;
        pos = [center-siz/2 siz];
        listen = h.PropertyListeners;
        if ~isempty(listen)
            oldstate = get(listen,'enable');
            set(listen,'enable','off');
        end
        set(h,'Position',pos);
        if ~isempty(listen)
            set(listen,{'enable'},oldstate);
        end
    end
    siz = hgconvertunits(fig,pos,get(h,'Units'),'points',parent);
    setappdata(double(h),'LegendOldSize',siz(3:4));
end

%----------------------------------------------------------------%
% The user changed the legend String property by hand so update
% any DisplayNames and refresh the legend
function changedString(hProp,eventData) %#ok

h = eventData.affectedObject;
if ~iscell(h.String) && ischar(h.String)
    h.String = cellstr(h.String);
end
ch = double(h.Plotchildren);
strings = h.String;
if length(strings) > length(ch)
    strings = strings(1:length(ch));
    h.String = strings;
end
newlis = get(h,'ScribePLegendListeners');
for k=1:length(newlis)
    if isfield(newlis{k},'dispname')
        set(newlis{k}.dispname,'enable','off')
    end
end
for k=1:length(strings)
    if ishandle(ch(k)) && isprop(ch(k),'DisplayName')
        set(ch(k),'DisplayName',strings{k});
    end
end
for k=1:length(newlis)
    if isfield(newlis{k},'dispname')
        set(newlis{k}.dispname,'enable','on')
    end
end
methods(h,'layout_legend_items','ignoreTokens');
legendcolorbarlayout(h.Axes,'objectChanged',double(h))
methods(h,'update_userdata');

%----------------------------------------------------------------%
% A legendinfo of an object displayed in the legend changed so
% regenerate legend items
function changedLegendInfo(h,eventData) %#ok
% remove old text and token items

hchild = getappdata(double(h.Axes),'legendInfoAffectedObject');
if any(double(h.PlotChildren) == double(hchild))
    methods(h,'layout_legend_items');
    legendcolorbarlayout(double(h.Axes),'layout');
    methods(h,'update_userdata');
end

%----------------------------------------------------------------%
function legendDeleted(hProp,eventData,h) %#ok

uic = get(h,'UIContextMenu');
if ishandle(uic)
    delete(uic);
end
if ishandle(double(h)) && ...
        ishandle(get(double(h),'parent')) && ...
        ~strcmpi(get(get(double(h),'parent'),'beingdeleted'),'on')
    ax = double(h.Axes);
    if ~isempty(ax) && ishandle(ax) && ~strcmpi(get(ax,'beingdeleted'),'on')
        graph2dhelper('updateLegendMenuToolbar', [], [], double(h.Axes));
        legendcolorbarlayout(double(h.Axes),'removeFromLayoutList',double(h))
        legendcolorbarlayout(double(h.Axes),'layout')
    end
end

%----------------------------------------------------------------%
function changedFontProperties(hProp,eventData) %#ok

h=eventData.affectedObject;

% remove auto updating from plot axes once the legend is manually set
hax = h.Axes;
lis = get(hax,'ScribeLegendListeners');
if strcmp(hProp.Name,'FontName')
    lis.fontname = [];
elseif strcmp(hProp.Name,'FontSize')
    lis.fontsize = [];
elseif strcmp(hProp.Name,'FontWeight')
    lis.fontweight = [];
elseif strcmp(hProp.Name,'FontAngle')
    lis.fontangle = [];
end
set(hax,'ScribeLegendListeners',lis);

% update items for legend
methods(h,'layout_legend_items','ignoreTokens');
legendcolorbarlayout(double(h.Axes),'objectChanged',h)
methods(h,'update_userdata');

%----------------------------------------------------------------%
function changedLineWidth(hProp,eventData) %#ok

h=eventData.affectedObject;

% remove auto updating from plot axes once the legend is manually set
hax = h.Axes;
lis = get(hax,'ScribeLegendListeners');
lis.linewidth = [];
set(hax,'ScribeLegendListeners',lis);

% update items for legend
methods(h,'layout_legend_items','ignoreTokens');
legendcolorbarlayout(double(h.Axes),'objectChanged',h)
methods(h,'update_userdata');

%----------------------------------------------------------------%
% Plot axes listener callbacks
%----------------------------------------------------------------%
function PlotAxesChangedFontProperties(hProp,eventData,h) %#ok

ax = double(eventData.affectedObject);
if ishandle(ax) && ishandle(h)

    % set font properties from axes without firing property listeners
    proplis = get(h,'PropertyListeners');
    oldstate = get(proplis,'enable');
    set(proplis,'enable','off')
    hax = h.Axes;
    lis = get(hax,'ScribeLegendListeners');
    if ~isempty(lis.fontname)
        h.FontName = get(ax,'FontName');
    end
    if ~isempty(lis.fontangle)
        h.FontAngle = get(ax,'FontAngle');
    end
    if ~isempty(lis.fontsize)
        h.FontSize = get(ax,'FontSize');
    end
    if ~isempty(lis.fontweight)
        h.FontWeight = get(ax,'FontWeight');
    end
    set(proplis,{'enable'},oldstate)

    % make new items for legend
    methods(h,'layout_legend_items','ignoreTokens');
    legendcolorbarlayout(double(h.Axes),'objectChanged',h)
    methods(h,'update_userdata');
end

%----------------------------------------------------------------%
function PlotAxesChangedLineWidth(hProp,eventData,h) %#ok

ax = double(eventData.affectedObject);
if ishandle(ax) && ishandle(h)
    % set line width property from axes without firing property listeners
    proplis = get(h,'PropertyListeners');
    oldstate = get(proplis,'enable');
    set(proplis,'enable','off')
    set(h,'LineWidth',get(ax,'LineWidth'));
    set(proplis,{'enable'},oldstate)

    % make new items for legend
    methods(h,'layout_legend_items','ignoreTokens');
    legendcolorbarlayout(double(h.Axes),'objectChanged',h)
    methods(h,'update_userdata');
end

%----------------------------------------------------------------%
function PlotAxesDeleted(hProp,eventData,h) %#ok

if ishandle(h) && ...
        ~strcmpi(get(double(h),'beingdeleted'),'on') && ...
        ishandle(get(h,'parent')) && ...
        ~strcmpi(get(get(double(h),'parent'),'beingdeleted'),'on')
    delete(h);
end

%----------------------------------------------------------------%
function PlotAxesCleared(hProp,eventData,h)

PlotAxesDeleted(hProp,eventData,h);

%----------------------------------------------------------------%
function PlotAxesChildAdded(hProp,eventData,h) %#ok

if ~ishandle(double(h)) || ~isprop(h,'plotchildren')
    return;
end

addchild = true;
newch = double(eventData.child);
newchtype = get(newch,'type');

% note the plot objects are hggroups with LegendInfo appdata and
% that only gets set after the childAdd listener is fired so this
% test will exclude plot objects. Another test is needed here.
if ~graph2dhelper('islegendable',newch)
    return;
end

% check to see if it's a part of an existing scattergroup
% and don't add a new item if it is.
if isempty(h.Plotchildren) || ~all(ishandle(h.Plotchildren))
    % this really shouldn't happen
    typeindex = 1;
    insertindex = 1;
    ch = [];
else
    ch = double(h.Plotchildren);
    chtypes = get(ch,'type');
    if strcmpi(newchtype,'patch') && isappdata(newch,'scattergroup')
        newscgroup = getappdata(newch,'scattergroup');
        chpatches = ch(strcmpi(chtypes,'patch'));
        k=1;
        while k<=length(chpatches) && addchild
            getappdata(chpatches(k),'scattergroup');
            if isequal(getappdata(chpatches(k),'scattergroup'),newscgroup)
                addchild = false;
            end
            k=k+1;
        end
    end
    if addchild
        % get insert index
        % insert at end of same type items in legend
        sametypeinds = find(strcmpi(newchtype,chtypes));
        typeindex = length(sametypeinds) + 1;
        if ~isempty(sametypeinds)
            insertindex = sametypeinds(end) + 1;
        elseif strcmpi(newchtype,'line')
            insertindex = 1;
        elseif strcmpi(newchtype,'patch')
            lineinds = find(strcmpi('line',chtypes));
            if isempty(lineinds)
                insertindex=1;
            else
                insertindex=lineinds(end) + 1;
            end
        else
            insertindex=length(ch) + 1;
        end
    end
end

if addchild
    % set string for the new item
    newstr = sprintf('%s %d',newchtype,typeindex);
    % create new plotchild and strings lists
    str = h.String;
    if insertindex>length(ch)
        ch(end+1) = newch;
        str{end+1} = newstr;
    else
        ch = [ch(1:insertindex-1);newch;ch(insertindex:length(ch))];
        str = [str(1:insertindex-1);{newstr};str(insertindex:length(str))];
    end
    h.Plotchildren = ch;
    set(h.PropertyListeners,'enable','off'); % for string listener
    h.String = str;
    set(h.PropertyListeners,'enable','on'); % for string listener

    % remove old text and token items
    delete(h.ItemText);
    delete(h.ItemTokens);

    methods(h,'create_legend_items',ch);
    legendcolorbarlayout(double(h.Axes),'layout');
    % update user data
    methods(h,'update_userdata');

    % add listeners for new plotchild
    methods(h,'create_plotchild_listeners',handle(newch),newch);
end

%----------------------------------------------------------------------%
% Callback fired when the CurrentAxes changes
function changedCurrentAxes(hProp,eventData) %#ok
ax = eventData.NewValue;
if isa(handle(ax),'scribe.legend')
    fig = ancestor(ax,'figure');
    set(fig, 'CurrentAxes', double(get(ax,'Axes')));
    return;
end
graph2dhelper('updateLegendMenuToolbar', [], [], ax);
