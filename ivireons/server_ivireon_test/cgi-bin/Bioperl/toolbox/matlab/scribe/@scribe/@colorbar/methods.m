function val = methods(this,fcn,varargin)
% METHODS - methods for colorbar class

%   Copyright 1984-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.35 $  $  $

val = [];

% one arg is methods(obj) call
if nargin==1
    cls= this.classhandle;
    m = get(cls,'Methods');
    val = get(m,'Name');
    return;
end

args = {fcn,this,varargin{:}};
if nargout == 0
    feval(args{:});
else
    val = feval(args{:});
end

%----------------------------------------------------------------%
% Extract relevant info for constructing a new colorbar after deserializing
function val=postdeserialize(h) %#ok<DEFNU>

val.location = h.Location;
val.position = h.Position;
val.ax = h.Axes;
val.cbar = h;
val.titlestr = get(getappdata(double(h),'CBTitle'),'String');
val.xlabelstr = get(getappdata(double(h),'CBXLabel'),'String');
val.ylabelstr = get(getappdata(double(h),'CBYLabel'),'String');

%----------------------------------------------------------------%
function deletecolorbars(cbar)

cbars = find_colorbars(double(cbar.Axes),'any');
if ~isempty(cbars)
    for k=1:length(cbars)
        h = handle(cbars(k));
        if ishandle(double(h)) && ...
                ~strcmpi(get(double(h),'beingdeleted'),'on') && ...
                ishandle(get(double(h),'parent')) && ...
                ~strcmpi(get(get(double(h),'parent'),'beingdeleted'),'on')
            h.methods('delete');
        end
    end
end

%----------------------------------------------------------------%
% ButtonUp in Plotedit mode. Check for interactive edit mode.
function handled = bup(h,point) %#ok<INUSD>

handled = true;

% if in plotedit mode turn off custom button up
b = hggetbehavior(double(h),'Plotedit');
set(b,'ButtonUpFcn',[]);
set(b,'MouseMotionFcn',[]);

%----------------------------------------------------------------%
% ButtonDown in Plotedit mode. Check for interactive edit mode.
function handled = bdown(h,pt) %#ok<DEFNU,INUSD>

handled = false;
fig = ancestor(h,'figure');
if strcmpi(h.Editing,'on')
    % If we clicked on the border of the colorbar, do not handle the button
    % down ourselves, rather let plot edit resize or move the colorbar.
    hMode = plotedit(fig,'getmode');
    hPlotSelect = hMode.ModeStateData.PlotSelectMode;
    if strcmpi(hPlotSelect.ModeStateData.NonScribeMoveMode,'none');
        % if in plotedit mode turn on custom event handlers
        b = hggetbehavior(double(h),'Plotedit');
        set(b,'ButtonUpFcn',@bup);
        set(b,'MouseMotionFcn',@move_colormap);

        h.ColormapMoveInitialMap = get(fig,'Colormap');
        handled = true;
        scribeax = handle(getappdata(fig,'Scribe_ScribeOverlay'));
        scribeax.CurrentShape = h;
    end
end
if get(fig,'CurrentAxes') == double(h)
    set(fig,'CurrentAxes',double(h.Axes));
end

%-----------------------------------------------------------------------%
function res = localPointOnBorder(obj,point)
% Given a point in normalized figure units, determine if it is on the
% border of the colorbar

res = false;

% Get the position of the object in pixels
hAncestor = handle(get(obj,'Parent'));
hFig = ancestor(obj,'Figure');
if ~isa(hAncestor,'hg.figure') && ~isa(hAncestor,'hg.uipanel')
    hAncestor = hFig;
end

point = hgconvertunits(hFig,[point 0 0],'Normalized','Pixels',hFig);

objPos = hgconvertunits(hFig,get(obj,'Position'),get(obj,'Units'),'Pixels',hAncestor);
if ~isa(hAncestor,'hg.figure')
    ancPos = hgconvertunits(hFig,get(hAncestor,'Position'),get(hAncestor,'Units'),'Pixels',hFig);
else
    ancPos = [0 0 0 0];
end
objPos(1:2) = objPos(1:2)+ancPos(1:2);

% calc x and y limits of rectangle in pixel coords
XL = objPos(1);
XR = objPos(1) + objPos(3);
YU = objPos(2) + objPos(4);
YL = objPos(2);

% Store point in pixels:
px = point(1);
py = point(2);

a2 = 4; % half pixel afsiz;

% test if mouse over the boundary of the position rect
if (any(abs([XL XR]-px) <= a2) && YL <= py && py <= YU) || ...
        (any(abs([YL YU]-py) <= a2) && XL <= px && px <= XR)
    res = true;
end


%----------------------------------------------------------------%
% Return the cursor to use if the mouse is over this object. Used
% in plotedit mode and when the colorbar is in interactive edit mode.
function over=mouseover(h,point) %#ok<DEFNU>

over=0; % not over object
fig = ancestor(h,'figure');
scribeax = handle(getappdata(fig,'Scribe_ScribeOverlay'));
cbpos = h.Position;
inrect =  point(1) > cbpos(1) && point(1) < cbpos(1)+cbpos(3) && ...
    point(2) > cbpos(2) && point(2) < cbpos(2)+cbpos(4);

if isempty(scribeax) || strcmp('off',scribeax.InteractiveCreateMode)
    if strcmpi(h.Editing,'on')
        % If we are on the border, let plot edit mode do its thing.
        if inrect>0 && ~localPointOnBorder(h,point)
            switch h.Location
                case {'East','West','EastOutside','WestOutside'}
                    over = 'heditbar';
                case 'manual'
                    if cbpos(3)>cbpos(4) % horizontal
                        over = 'veditbar';
                    else
                        over = 'heditbar';
                    end
                otherwise
                    over = 'veditbar';
            end
            hMode = plotedit(fig,'getmode');
            hPlotSelect = hMode.ModeStateData.PlotSelectMode;
            hPlotSelect.ModeStateData.NonScribeMoveMode = 'none';
        end
    end
end

%----------------------------------------------------------------%
% Compute and set shifted colormap when in interactive edit mode.
function handled = move_colormap(h,pt)

handled = true;
fig = ancestor(h,'figure');
scribeax = handle(getappdata(fig,'Scribe_ScribeOverlay'));

map0 = h.ColormapMoveInitialMap;
mapsiz = length(map0);
pt0 = scribeax.NClickPoint;
cbpos = h.Position;

switch h.Location
    case {'East','West','EastOutside','WestOutside'}
        mapindstart = ceil(mapsiz*(pt0(2) - cbpos(2))/cbpos(4));
        mapindsmove = ceil(mapsiz*(pt(2) - pt0(2))/cbpos(4));
    case 'manual'
        if cbpos(3)>cbpos(4) % horizontal
            mapindstart = ceil(mapsiz*(pt0(1) - cbpos(1))/cbpos(3));
            mapindsmove = ceil(mapsiz*(pt(1) - pt0(1))/cbpos(3));

        else
            mapindstart = ceil(mapsiz*(pt0(2) - cbpos(2))/cbpos(4));
            mapindsmove = ceil(mapsiz*(pt(2) - pt0(2))/cbpos(4));
        end

    otherwise
        mapindstart = ceil(mapsiz*(pt0(1) - cbpos(1))/cbpos(3));
        mapindsmove = ceil(mapsiz*(pt(1) - pt0(1))/cbpos(3));
end

% calculate new colormap
newmap = map0;

if mapindsmove>0
    stretchind = mapindstart+mapindsmove;
    stretchind = min(stretchind,mapsiz);
    mapindstart = max(1,mapindstart);
    stretchfx = stretchind/mapindstart;
    ixinc = 1/stretchfx;
    ix = 1;
    for k=1:stretchind
        ia = max(1,min(mapsiz,floor(ix)));
        if ia<mapsiz
            ib = ia+1;
            ifrx = ix - ia;
            newmap(k,:) = map0(ia,:) + ifrx*(map0(ib,:) - map0(ia,:));
        else
            newmap(k,:) = map0(ia,:);
        end
        ix = ix + ixinc;
    end
    % avoid div by 0
    squeezefx = max(1,(mapsiz - stretchind))/(mapsiz - mapindstart);
    ixinc = 1/squeezefx;
    ix = mapindstart;
    for k=stretchind:mapsiz
        ia = max(1,min(mapsiz,floor(ix)));
        if ia<mapsiz
            ib = ia+1;
            ifrx = ix - ia;
            newmap(k,:) = map0(ia,:) + ifrx*(map0(ib,:) - map0(ia,:));
        else
            newmap(k,:) = map0(ia,:);
        end
        ix = ix + ixinc;
    end
else
    stretchind = mapindstart+mapindsmove;
    stretchind = max(stretchind,1);
    mapindstart = max(1,mapindstart);
    stretchfx = stretchind/mapindstart;
    ixinc = 1/stretchfx;
    ix = 1;
    for k=1:stretchind
        ia = max(1,min(mapsiz,floor(ix)));
        if ia<mapsiz
            ib = ia+1;
            ifrx = ix - ia;
            newmap(k,:) = map0(ia,:) + ifrx*(map0(ib,:) - map0(ia,:));
        else
            newmap(k,:) = map0(ia,:);
        end
        ix = ix + ixinc;
    end
    squeezefx = (mapsiz - stretchind)/(mapsiz - mapindstart);
    ixinc = 1/squeezefx;
    ix = mapindstart;
    for k=stretchind:mapsiz
        ia = max(1,min(mapsiz,floor(ix)));
        if ia<mapsiz
            ib = ia+1;
            ifrx = ix - ia;
            newmap(k,:) = map0(ia,:) + ifrx*(map0(ib,:) - map0(ia,:));
        else
            newmap(k,:) = map0(ia,:);
        end
        ix = ix + ixinc;
    end
end

% set it
set(fig,'Colormap',newmap);


%----------------------------------------------------------------%
function calculate_colormap(h) %#ok<INUSD>

% fig = double(h.Figure);
% scribeax = h.ScribeAxes;
%
% map0 = h.BaseColormap;
%
% for k=1:maplength
%     frx = k/mapsiz;
%     % find lower node
%     for n=1:length(h.CmapNodeFrx)
%         if frx > h.CmapNodeFrx(n)
%             lowernode = n;
%         end
%     end
%     % find upper node
%     for n=length(h.CmapNodeFrx):1
%         if frx < h.CmapNodeFrx(n)
%             uppernode = n;
%         end
%     end
% set(fig,'Colormap',newmap);

%----------------------------------------------------------------%
function updatefonts(h)

ax = double(h.Axes);
cbars = find_colorbars(ax,'any');
for k=1:length(cbars)
    cax = double(cbars(k));
    set(cax,'fontname',get(ax,'fontname'));
    set(cax,'fontangle',get(ax,'fontangle'));
    set(cax,'fontsize',get(ax,'fontsize'));
    set(cax,'fontweight',get(ax,'fontweight'));
end

%----------------------------------------------------------------------%
function hc = find_colorbars(ha,location)

% find colorbars with plotaxes ha, and location (which may be
% 'any', or one of the standard colorbar location).

fig = get(ha,'parent');
ax = findobj(fig,'type','axes');
hc=[];
k=1;
% vectorize
for k=1:length(ax)
    if iscolorbar(ax(k))
        hax = handle(ax(k));
        if isequal(double(hax.Axes),ha)
            if isequal(location,'any')
                hc(end+1)=ax(k);
            elseif strcmp(location,hax.Location)
                hc(end+1)=ax(k);
            end
        end
    end
end

%----------------------------------------------------------------------%
function tf=iscolorbar(ax)

if length(ax) ~= 1 || ~ishandle(ax)
    tf=false;
else
    tf=isa(handle(ax),'scribe.colorbar');
end

%----------------------------------------------------------------------%
function startlisteners(h) %#ok<DEFNU>

% add listeners to peer axes
hax = h.Axes;
if isempty(hax)||~ishandle(hax), return; end
ax = double(hax);
if ~isprop(hax,'ScribeColorbarListeners')
    l = schema.prop(hax,'ScribeColorbarListeners','MATLAB array');
    l.AccessFlags.Serialize = 'off';
    l.Visible = 'off';
end
cls = classhandle(hax);
lis.color = handle.listener(hax, cls.findprop('Color'),...
    'PropertyPostSet', {@PeerAxesChangedColor,h});
lis.fontname = handle.listener(hax, cls.findprop('FontName'),...
    'PropertyPostSet', {@PeerAxesChangedFontProperties,h});
lis.fontsize = handle.listener(hax, cls.findprop('FontSize'),...
    'PropertyPostSet', {@PeerAxesChangedFontProperties,h});
lis.fontweight = handle.listener(hax, cls.findprop('FontWeight'),...
    'PropertyPostSet', {@PeerAxesChangedFontProperties,h});
lis.fontangle = handle.listener(hax, cls.findprop('FontAngle'),...
    'PropertyPostSet', {@PeerAxesChangedFontProperties,h});
lis.deleted = handle.listener(hax, 'ObjectBeingDestroyed', {@PeerAxesDeleted,h});
h.DeleteProxy = handle(text('parent',hax,...
    'visible','off', ...
    'tag','LegendDeleteProxy',...
    'handlevisibility','off'));
lis.proxydeleted = handle.listener(h.DeleteProxy, 'ObjectBeingDestroyed', {@PeerAxesCleared,h});
set(hax,'ScribeColorbarListeners',lis);

% add listeners to figure
fig = ancestor(h,'figure');
hfig = handle(fig);
if ~isprop(hfig,'ScribeColorbarListeners')
    l = schema.prop(hfig,'ScribeColorbarListeners','MATLAB array');
    l.AccessFlags.Serialize = 'off';
    l.Visible = 'off';
end
cls = classhandle(hfig);
lis.color = handle.listener(hfig, cls.findprop('Color'),...
    'PropertyPostSet', {@FigureChangedColor,h});
lis.currentaxes = handle.listener(handle(fig), cls.findprop('CurrentAxes'),...
    'PropertyPostSet', graph2dhelper('updateLegendMenuToolbar'));
set(hfig,'ScribeColorbarListeners',lis);

%----------------------------------------------------------------%
% Figure listener callbacks
%----------------------------------------------------------------%

%----------------------------------------------------------------%
function FigureChangedColor(hProp,eventData,h) %#ok<INUSL>

if ishandle(double(h)) && ...
        ~strcmpi(get(double(h),'beingdeleted'),'on') && ...
        ishandle(get(double(h),'parent')) && ...
        ~strcmpi(get(get(double(h),'parent'),'beingdeleted'),'on')
    h.methods('auto_adjust_colors');
end

%----------------------------------------------------------------%
% Peer axes listener callbacks
%----------------------------------------------------------------%
function PeerAxesChangedFontProperties(hProp,eventData,h) %#ok<INUSL>

if ishandle(double(h)) && ...
        ~strcmpi(get(double(h),'beingdeleted'),'on') && ...
        ishandle(get(double(h),'parent')) && ...
        ~strcmpi(get(get(double(h),'parent'),'beingdeleted'),'on')
    h.methods('updatefonts');
    %    legendcolorbarlayout(h.Axes,'objectChanged',h);
end

%----------------------------------------------------------------%
function PeerAxesChangedColor(hProp,eventData,h) %#ok<INUSL>

if ishandle(double(h)) && ...
        ~strcmpi(get(double(h),'beingdeleted'),'on') && ...
        ishandle(get(double(h),'parent')) && ...
        ~strcmpi(get(get(double(h),'parent'),'beingdeleted'),'on')
    h.methods('auto_adjust_colors');
end

%----------------------------------------------------------------%
function PeerAxesDeleted(hProp,eventData,h) %#ok<INUSL>

if ishandle(double(h)) && ...
        ~strcmpi(get(double(h),'beingdeleted'),'on') && ...
        ishandle(get(double(h),'parent')) && ...
        ~strcmpi(get(get(double(h),'parent'),'beingdeleted'),'on')
    h.methods('deletecolorbars');
end

%----------------------------------------------------------------%
function PeerAxesCleared(hProp,eventData,h)

PeerAxesDeleted(hProp,eventData,h);

%----------------------------------------------------------------%
function toggle_editmode(h)

cbarax = double(h);
fig = ancestor(h,'figure');
uic = get(cbarax,'UIContextMenu');
if ~isempty(uic)
    emodemenu = findall(uic,'type','UIMenu','Tag','scribe:colorbar:interactivecolormapshift');
    if ~isempty(emodemenu)
        state = get(emodemenu,'checked');
        if strcmpi(state,'off')
            set(emodemenu,'checked','on');
            plotedit(fig,'on');
            h.Editing = 'on';
            set(cbarax,'linewidth',1);
            selectobject(h,'replace');
        else
            set(emodemenu,'checked','off');
            h.Editing = 'off';
            plotedit(fig,'off');
            set(cbarax,'linewidth',.5);
        end
    end
end

%----------------------------------------------------------------%
function toggle_editmode_cb(hSrc,evdata,h) %#ok<INUSL>

toggle_editmode(h);

%----------------------------------------------------------------%
function set_standard_colormap(h,name)

fig = ancestor(h,'figure');
map = get(fig,'Colormap');
mapsiz = size(map);
map = feval(name,mapsiz(1));
h.BaseColormap = map;
calculate_colormap(h);

set(fig,'colormap',map);

%----------------------------------------------------------------%
function set_standard_colormap_cb(hSrc,evdata,h,name) %#ok<INUSL>

set_standard_colormap(h,name);

%---------------------------------------------------------%
function auto_adjust_colors(h)

if isempty(h.Axes) || ~ishandle(h.Axes), return; end
lpos = h.Position;
lcenter = [lpos(1)+lpos(3)/2 lpos(2)+lpos(4)/2];
u = get(h.Axes,'Units');
if ~strcmpi(u,'normalized')
    set(h.Axes,'Units','normalized');
end
apos = get(h.Axes,'Position');
if ~strcmpi(u,'normalized')
    set(h.Axes,'Units',u);
end
fig = ancestor(h,'figure');
fcolor = get(fig,'Color');
acolor = get(h.Axes,'Color');

if lcenter(1)>apos(1) && lcenter(1)<apos(1)+apos(3) && ...
        lcenter(2)>apos(2) && lcenter(2)<apos(2)+apos(4)
    c=acolor;
    if ischar(c)
        c=fcolor;
    end
else
    c=fcolor;
end

set(h.PropertyListeners,'Enable','off');
doChangeX = strcmpi(h.XColorMode,'auto') && strcmpi(h.EdgeColorMode,'auto');
doChangeY = strcmpi(h.YColorMode,'auto') && strcmpi(h.EdgeColorMode,'auto');
if ~ischar(c) && sum(c(:))<1.5
    if doChangeX
        set(h,'xcolor','w');
    end
    if doChangeY
        set(h,'ycolor','w');
    end
else
    if doChangeX
        set(h,'xcolor','k');
    end
    if doChangeY
        set(h,'ycolor','k');
    end
end
set(h.PropertyListeners,'Enable','on');

%-------------------------------------------------------------------%
%                Colorbar Context Menu
%-------------------------------------------------------------------%
%-------------------------------------------------------------------%
function update_contextmenu(h,onoff)

mapnames={'cool','gray','hot','hsv','jet'};
uic = get(h,'UIContextMenu');
if ~isempty(uic)
    % update standard colormaps
    m = findall(uic,'Type','uimenu','Tag','scribe:colorbar:colormap');
    if ~isempty(m)
        mitems = allchild(m);
        if ~isempty(mitems)
            set(mitems,'Checked','off');
            fig = ancestor(h,'figure');
            cmap = get(fig,'Colormap');
            maplength=length(cmap);
            k=1; found=false;
            while k<=length(mapnames) && ~found
                % create test map of type maplabels{k} and length
                % maplength.
                tmap = feval(mapnames{k},maplength);
                if isequal(cmap,tmap)
                    % if test map same as figure map, check item.
                    found=true;
                    mitem = findall(m,'Tag',['scribe:colorbar:colormap:' mapnames{k}]);
                    set(mitem,'Checked','on');
                end
                k=k+1;
            end
        end
    end
end

%-------------------------------------------------------------------%
function update_contextmenu_cb(hSrc,evdata,varargin)
update_contextmenu(varargin{:})

%--------------------------------------------------------------------%
function set_contextmenu(h,onoff) %#ok<DEFNU>

fig = ancestor(h,'figure');
maplabels={'cool','gray','hot','hsv','jet(default)'};
mapfunctions={'cool','gray','hot','hsv','jet'};
maptags = cellfun(@(x)(['scribe:colorbar:colormap:' x ]),mapfunctions,'UniformOutput',false);
uic = get(h,'UIContextMenu');
if isempty(uic)
    uic = uicontextmenu('Parent',fig,'HandleVisibility','off','Callback',{@update_contextmenu_cb,h});
    setappdata(uic,'CallbackObject',h);
    % Delete:
    hMenu = graph2dhelper('createScribeUIMenuEntry',fig,'GeneralAction','Delete','','',{@delete_self_cb,h});
    set(hMenu,'Tag','scribe:colorbar:delete');
    % Location
    hMenu(end+1) = graph2dhelper('createScribeUIMenuEntry',fig,'CustomEnumEntry','Location','Location','',...
        {'Outside North','Outside South','Outside West','Outside East','West','East'},...
        {'NorthOutside','SouthOutside','WestOutside','EastOutside','West','East'},...
        {@localChangeLocationCallback,h});
    set(hMenu(end),'Tag','scribe:colorbar:location');
    locationtags = {'scribe:colorbar:location:northoutside';'scribe:colorbar:location:southoutside';...
        'scribe:colorbar:location:westoutside';'scribe:colorbar:location:eastoutside';...
        'scribe:colorbar:location:west';'scribe:colorbar:location:east'};
    set(hMenu(end),'Separator','on');
    % Set the parent of the menus
    set(hMenu,'Parent',uic);
    set(findall(hMenu),'Visible','on');
    hChil = findall(hMenu(end));
    hChil = flipud(hChil(2:end));
    set(hChil,{'Tag'},locationtags);
    % Standard colormaps
    stdmaps = uimenu(uic,'HandleVisibility','off','Label','Standard Colormaps',...
        'Separator','on','Tag','scribe:colorbar:colormap');
    for k=1:length(maplabels)
        uimenu(stdmaps,'HandleVisibility','off','Label', maplabels{k}, ...
            'Callback', {@set_standard_colormap_cb, h, mapfunctions{k}},...
            'Tag',maptags{k});
    end
    % editmode
    hMenu = uimenu(uic,'HandleVisibility','off','Label','Interactive Colormap Shift',...
        'Separator','off','Callback',{@toggle_editmode_cb,h});
    set(hMenu,'Tag','scribe:colorbar:interactivecolormapshift');
    % colormap editor
    
    hMenu = uimenu(uic,'HandleVisibility','off','Label','Open Colormap Editor',...
        'Separator','off','Callback',@edit_colormap_cb);
    set(hMenu,'Tag','scribe:colorbar:editcolormap');
    % Property Editor
    hMenu = uimenu(uic,'HandleVisibility','off','Separator','on',...
        'Label','Show Property Editor','Callback',{@localOpenPropertyEditor,h});
    set(hMenu,'Tag','scribe:colorbar:propedit');
    % Code
    hMenu = uimenu(uic,'HandleVisibility','off','Separator','on',...
        'Label','Show Code','Callback',{@localGenerateMCode,h});
    set(hMenu,'Tag','scribe:colorbar:mcode');
    % set
    set(h,'uicontextmenu',uic);
    update_contextmenu(h,'on');
end

%----------------------------------------------------------------%
function localOpenPropertyEditor(obj,evd,hLeg) %#ok<INUSL>

propedit(hLeg,'-noselect');

%----------------------------------------------------------------%
function localGenerateMCode(obj,evd,hLeg) %#ok<INUSL>

makemcode(hLeg,'Output','-editor')

%--------------------------------------------------------------------%
function edit_colormap_cb(hSrc,evdata)
colormapeditor;

%--------------------------------------------------------------------%
function delete_self_cb(hSrc,evdata,h)

% If plot edit mode is on, we want to go through the plot edit mode delete
% infrastructure in order to gain undo support:
hFig = ancestor(h,'figure');
if isactiveuimode(hFig,'Standard.EditPlot')
    scribeccp(hFig,'delete');
else
    delete(h);
end

%--------------------------------------------------------%
function localChangeLocationCallback(hSrc,evdata,h,hFig,value)
% Callback to change the location of the colorbar:

% If plot edit mode is on, we want to add undo support to the operation:
if isactiveuimode(hFig,'Standard.EditPlot')
    currLoc = get(h,'Location');
    if ~strcmpi(currLoc,value)
        proxyVal = plotedit({'getProxyValueFromHandle',h});
        currPos = [];
        currOr = [];
        currXLoc = [];
        currYLoc = [];
        if strcmpi(currLoc,'manual')
            currPos = get(h,'Position');
            currOr = get(h,'Orientation');
            currXLoc = get(h,'XAxisLocation');
            currYLoc = get(h,'YAxisLocation');
        end
        cmd.Name = 'Change Location';
        cmd.Function = @localChangeLocation;
        cmd.Varargin = {proxyVal,hFig,value,[],[],[],[]};
        cmd.InverseFunction = @localChangeLocation;
        cmd.InverseVarargin = {proxyVal,hFig,currLoc,currPos,currOr,currXLoc,currYLoc};
        uiundo(hFig,'function',cmd);
    end
end

set(h,'Location',value);

%--------------------------------------------------------%
function localChangeLocation(proxyVal,hFig,locVal,posVal,orientation,xAxisLoc,yAxisLoc)
% Undo / Redo operation for location changes:
h = plotedit({'getHandleFromProxyValue',hFig,proxyVal});
set(h,'Location',locVal);
% If the location was manual, we have to set a few extra properties.
if strcmpi(locVal,'manual')
    set(h,'Position',posVal);
    set(h,'Orientation',orientation);
    set(h,'XAxisLocation',xAxisLoc,'YAxisLocation',yAxisLoc);
end

%--------------------------------------------------------%
% Helper function to get a function handle to a subfunction
function out=getfunhan(h,str,varargin)

if strcmp(str,'-noobj')
    str = varargin{1};
    if nargin == 3
        out = str2func(str);
    else
        out = {str2func(str),varargin{2:end}};
    end
else
    out = {str2func(str),h,varargin{:}};
end

%----------------------------------------------------------------------%
% Sets orientation of the colorbar
function setConfiguration(cbar, ax) %#ok<DEFNU>

cbarax = double(cbar);

img = findobj(cbarax,'Type','image');
t = getappdata(img,'colormapt');
if isappdata(img,'colormaplim')
    lim = getappdata(img,'colormaplim');
    performTight = false;
else
    lim = t;
    performTight = true;
end

orientation = cbar.Orientation;
switch orientation(1:3)
    case 'Ver'
        % Make sure that the ticks are set correctly before changing the
        % limits
        set(cbarax,'XTick',[],'YTickMode','auto');
        set(cbar,'YLim',lim,'XLim',[0 1]);
        if regexp(orientation,'Left') %verticalleft
            set(cbar,'YAxisLocation','left');
        else %verticalright
            set(cbar,'YAxisLocation','right');
        end
        
    case 'Hor'
        % Make sure that the ticks are set correctly before changing the
        % limits
        set(cbarax,'YTick',[],'XAxisLocation','bottom','XTickMode','auto');
        set(cbar,'XLim',lim,'YLim',[0 1]);
        if regexp(orientation,'Top') %horizontaltop
            set(cbar,'XAxisLocation','top');
        else %horizontalbottom
            set(cbar,'XAxisLocation','bottom');
        end            
end

cbar.methods('doUpdateImage', performTight);

%----------------------------------------------------------------------%
% Create child image and set up initial properties
function initialize_colorbar_properties(cbar,fig,ax) %#ok<DEFNU>

cbarax = double(cbar);

% Determine color limits by context.  If any axes child is an image
% use scale based on size of colormap, otherwise use current CAXIS.
ch = findobj(get_current_data_axes(fig,ax));
hasimage = 0;
t = [];
isLogicalOrNumeric = false;
cdatamapping = 'direct';
mapsize = size(colormap(ax),1);
for i=1:length(ch)
  typ = get(ch(i),'type');
  if strcmp(typ,'image'),
    hasimage = 1;
    cdataClass = class(get(ch(i),'CData'));
    isLogicalOrNumeric = ismember(cdataClass,{'logical','uint8','uint16'});
    cdatamapping = get(ch(i), 'CDataMapping');
  elseif strcmp(class(handle(ch(i))),'specgraph.contourgroup') 
    % long-term should give the contourplot enough control over
    % clim to avoid this explicit check
    cdatamapping = 'scaled';
    llist = get(ch(i),'LevelList');
    if length(llist) > 1 && strcmp(get(ax,'CLimMode'),'auto')
        t2 = caxis(ax);
        t = [min(llist(:)) max(llist(:))];
        t = [max(t2(1),t(1)) min(t2(2),t(2))];
        if t(1) >= t(2), t = t2; end
      break;
    end
  elseif strcmp(typ,'hggroup') && isprop(ch(i),'CDataMapping')
    % charting objects set their own cdata mapping mode
    cdatamapping = get(handle(ch(i)),'CDataMapping');
  elseif strcmp(typ,'surface') && ...
        strcmp(get(ch(i),'FaceColor'),'texturemap') % Texturemapped surf
    hasimage = 2;
    cdatamapping = get(ch(i), 'CDataMapping');
  elseif strcmp(typ,'patch') || strcmp(typ,'surface')
    cdatamapping = get(ch(i), 'CDataMapping');
  end
end
if mapsize == 0
    t = caxis(ax);
elseif strcmp(cdatamapping, 'scaled')
    % Treat images and surfaces alike if cdatamapping == 'scaled'
    % Make sure there are at least two entries into the color map:
    if mapsize < 2
        mapsize = 2;
    end
    if isempty(t), t = caxis(ax); end
    d = (t(2) - t(1))/mapsize;
    t = [t(1)+d/2  t(2)-d/2];
else
    % Make sure there are at least two entries into the color map:
    if mapsize < 2
        mapsize = 2;
    end
    if hasimage,
        % handle zero-based indexing into colormap for logical, uint8,
        % uint16
        if isLogicalOrNumeric
            t = [0, mapsize - 1];
        else
            t = [1, mapsize]; 
        end
    else
        if isempty(t), t = caxis(ax); end
        if all(t == [0 1]) && strcmp(get(ax,'CLimMode'),'auto')
            t = [1.5, mapsize+.5];
        else
            d = (t(2) - t(1))/mapsize;
            t = [t(1)+d/2  t(2)-d/2];
        end
    end
end

img = image('Parent',double(cbar),...
            'Tag','TMW_COLORBAR',...
            'SelectionHighlight','off',...
            'HitTest','off',...
            'Visible','off',...
            'Interruptible','off');
setappdata(img,'colormapsize',mapsize);
setappdata(img,'colormapt',t);
setappdata(img,'NonDataObject',[]);
cbar.Image = handle(img);

set(cbarax,...
'Tickdir','in',...
'Layer','top',...
'Ydir','normal', ...
'Tag','Colorbar',...
'Interruptible','off');

set(img,'Visible',cbar.Visible);

%-----------------------------------------------------------------------
function doUpdateImage(cbar, varargin)

% The first arg in varargin should be a logical indicating whether to do an
% axis('tight')
performTight = false;
if ~isempty(varargin)
    performTight = varargin{1};
end

cbarax = double(cbar);

img = findobj(cbarax,'Type','image');
mapsize = getappdata(img,'colormapsize');
t = getappdata(img,'colormapt');

orientation = cbar.Orientation;
switch orientation(1:3)
    case 'Ver'
        set(img,'CData',(1:mapsize)',...
                      'YData',t,...
                      'XData',[0 1]);
    case 'Hor'
        set(img,'CData',(1:mapsize),...
                      'XData',t,...
                      'YData',[0 1]);
end

if performTight
    axis(cbarax,'tight');
end
%----------------------------------------------------------------------%
% Given a figure and candidate axes, get an axes that colorbar can
% attach to.
function h = get_current_data_axes(hfig, haxes)
h = datachildren(hfig);
if isempty(h) || any(h == haxes)
    h = haxes;
else
    h = h(1);
end
