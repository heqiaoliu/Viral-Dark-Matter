function varargout = methods(this,fcn,varargin)
%METHODS Methods for legend class

%   Copyright 1984-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.55 $ $Date: 2010/05/20 02:27:20 $

% one arg is methods(obj) call
if nargin==1
    cls= this.classhandle;
    m = get(cls,'Methods');
    varargout{1} = get(m,'Name');
    return;
end

args = {fcn,this,varargin{:}};
if nargout == 0
  feval(args{:});
else
  [varargout{1:nargout}] = feval(args{:});
end

%----------------------------------------------------------------%
% Extract relevant info for constructing a new legend after deserializing
function val=postdeserialize(h) %#ok

val.strings = h.String';
val.loc = h.Location;
fig = ancestor(h,'figure');
val.position = hgconvertunits(fig,get(h,'Position'),get(h,'Units'),...
    'points',fig);
val.leg = h;
if ~isappdata(double(fig),'BusyPasting')
    val.ax = getappdata(double(h),'PeerAxes');
    val.plotchildren = getappdata(double(h),'PlotChildren');
else
    axProxy = getappdata(double(h),'PeerAxesProxy');
    val.ax = plotedit({'getHandleFromProxyValue',fig,axProxy});
    childProxy = getappdata(double(h),'PlotChildrenProxy');
    val.plotchildren = plotedit({'getHandleFromProxyValue',fig,childProxy});
end
    
val.viewprops = {'Orientation','TextColor','EdgeColor',...
                    'Interpreter','Box','Visible','Color'};
val.viewvals = get(h,val.viewprops);
val.units = get(h,'Units');

% Add appdata to the axes that points back to the legend. This appdata
% will be used to speed up the execution time of the h = legend(ax)
% syntax.
if ~isempty(val.ax) && ishandle(val.ax)
    setappdata(double(val.ax),'LegendPeerHandle',double(h));
end

%----------------------------------------------------------------%
% Motion callback for moving a legend. Not called in Plotedit mode.
function bmotion(h)

fig = ancestor(h,'figure');
pt = hgconvertunits(fig,[0 0 get(fig,'CurrentPoint')],get(fig,'Units'),...
                    'points',fig);
pt = pt(3:4);

% check if a drag has been started, either by moving a lot or waiting
startpt = getappdata(double(h),'StartPoint');
if ~isempty(startpt)
  if (any(abs(startpt - pt) > 5)) || ...
        (etime(clock,getappdata(double(h),'StartClock')) > .5)
    rmappdata(double(h),'StartPoint');
  else
    return;
  end
end

oldpt = getappdata(double(h),'LastPoint');
if isempty(oldpt), oldpt = startpt; end

% move position if current point has moved
if ~isequal(pt,oldpt)
  posPts = hgconvertunits(fig,get(h,'Position'),get(h,'Units'),...
                          'points', get(h,'Parent'));
  posPts(1:2) = posPts(1:2) - oldpt + pt;
  newpos = hgconvertunits(fig,posPts,'points',...
                          get(h,'Units'), get(h,'Parent'));
  set(double(h),'Position',newpos);
  setappdata(double(h),'LastPoint',pt);
end

%----------------------------------------------------------------%
function bmotioncb(hSrc,evdata,h) %#ok
if ~ishandle(h), return, end
bmotion(h);

%----------------------------------------------------------------%
% ButtonUp callback for legend. Not called in Plotedit mode.
function bup(h)

fig = ancestor(h,'figure');
winfuns = getappdata(double(h),'TempWinFuns');
if isappdata(double(h), 'TempWinFuns')
  rmappdata(double(h), 'TempWinFuns'); 
end
if isappdata(double(h),'OldCursor')
    set(fig,'Pointer',getappdata(double(h),'OldCursor'));
end

% To fix g214461 "closereq at 18" error - winfuns is empty and
% the set(fig ...) call below bombs because winfuns wasn't an empty
% cell array.
if (length(winfuns) ~= 2)
    winfuns = {'' ''};
end

set(fig,{'WindowButtonMotionFcn','WindowButtonUpFcn'},winfuns);
try %#ok
  rmappdata(double(h),'LastPoint');
  rmappdata(double(h),'LegendDestroyedListener');
end

%----------------------------------------------------------------%
function bupcb(hSrc,evdata,h) %#ok
if ~ishandle(h), return, end
bup(h);

%--------------------------------------------------------------------%
function remove_legend_cb(hSrc,evdata,h) %#ok
% If we are not in plot edit mode, restore the window functions
hFig = ancestor(h,'Figure');
if ~isactiveuimode(hFig,'Standard.EditPlot')
    bup(h);
end

%----------------------------------------------------------------%
% ButtonUp for Plotedit mode. Checks for double-click on text.
% We start editing on button up instead of the button down since
% double-clicking starts the property editor and that flushes
% the event queue causing the events to get processed incorrectly.
function handled = ploteditbup(h,pt) %#ok

handled = false;
fig = ancestor(h,'figure');
set(h.ItemText,'HitTest','on');
obj = hittest(fig);
set(h.ItemText,'HitTest','off');
if ~isempty(obj) && strcmp(get(obj,'Type'),'text') && ...
      strcmp(get(fig,'SelectionType'),'open')
  n = find(obj == h.ItemText);
  handled = true;
  start_textitem_edit(h,n);
end

%----------------------------------------------------------------%
% ButtonDown for legend. Not called in Plotedit mode.
function bdown(h)

fig = ancestor(h,'figure');
if isappdata(fig,'scribeActive'), return; end
if isappdata(double(h), 'TempWinFuns')
    % This means that the legend is in a weird state, having lost a bup
    % event. Happens, if the user hooks up a WindowButtonDownFcn on the
    % figure and calls msgbox on the callback.
    % This check gives the user, a way to bail out of the weird state!
    bup(h); 
    return; 
end

pt = hgconvertunits(fig,[0 0 get(fig,'CurrentPoint')],get(fig,'Units'),...
                    'points',fig);
pt = pt(3:4);
oldwinfuns = get(fig,{'WindowButtonMotionFcn','WindowButtonUpFcn'});
setappdata(double(h),'TempWinFuns',oldwinfuns);
setappdata(double(h),'StartPoint',pt);
setappdata(double(h),'StartClock',clock);
setappdata(double(h),'OldCursor',get(fig,'Pointer'));
set(fig,'WindowButtonMotionFcn',{@bmotioncb,h});
set(fig,'WindowButtonUpFcn',{@bupcb,h});

dlis = handle.listener(h, 'ObjectBeingDestroyed', {@remove_legend_cb,h});
setappdata(double(h),'LegendDestroyedListener',dlis);

set(fig,'Pointer','fleur');

%----------------------------------------------------------------%
function bdowncb(hSrc,evdata,h) %#ok

% First, check to see if we hit text
fig = ancestor(h,'Figure');
set(h.ItemText,'HitTest','on');
hItem = handle(hittest(fig));
set(h.ItemText,'HitTest','off');
if ~isequal(hItem,h)
    hgfeval(get(hItem,'ButtonDownFcn'),hSrc,evdata);
    % Return early to avoid conflicting callbacks.
    return;
end

seltype = get(ancestor(hSrc, 'figure'), 'SelectionType');
if strcmp(seltype, 'normal')
  bdown(h)
end

%----------------------------------------------------------------%
% ButtonDown for legend text objects. Not called in Plotedit mode.
function tbdown(h,n)

fig = ancestor(h,'figure');
seltype = get(fig,'SelectionType');
if strcmpi(seltype,'open')
  start_textitem_edit(h,n);
elseif strcmp(seltype, 'normal')
  bdown(h);
end

%----------------------------------------------------------------%
function tbdowncb(hSrc,evdata,h,n) %#ok
tbdown(h,n);

%----------------------------------------------------------------%
% Start editing legend text item n.
function start_textitem_edit(h,n)

th = double(h.itemText);
set(th(n),'Edit','on');
% We need to listen for the end of an edit:
hObj = handle(th(n));
hListener = handle.listener(hObj,findprop(hObj,'String'),'PropertyPostSet',{@end_textitem_editcb,h,n});
setappdata(double(h),'TempWinFuns',hListener);

%----------------------------------------------------------------%
% Stop editing legend text item n.
function end_textitem_edit(h,n)

fig = ancestor(h,'figure');
th = double(h.itemText);
t = th(n);

if ~isequal(get(fig,'CurrentObject'),t)
    strings = h.String;
    strings{n} = get(t,'String');
    set(h.PropertyListeners,'enable','off'); % for string listener
    h.String = strings;
    set(h.PropertyListeners,'enable','on'); % for string listener
    if ~isempty(h.PlotChildren) && isprop(h.PlotChildren(n),'DisplayName')
        str = get(t,'String');
        if size(str,1) > 1
            cstr = cellstr(str);
            s = repmat('%s\n',1,length(cstr));
            s(end-1:end) = [];
            str = sprintf(s,cstr{:});
        end
        set(h.PlotChildren(n),'DisplayName',str);
    end
    update_userdata(h);
    update_legend_items(h);
    legendcolorbarlayout(h.Axes,'objectChanged',double(h))
    if isappdata(double(h), 'TempWinFuns')
        rmappdata(double(h), 'TempWinFuns');
    end
end

%----------------------------------------------------------------%
function end_textitem_editcb(hSrc,evdata,h,n) %#ok
end_textitem_edit(h,n);

%----------------------------------------------------------------%
% Recompute legend strings and refresh legend layout
function update_legend_items(h)

ch = double(h.Plotchildren);
strings = h.String;
% update strings for display names
for k=1:length(strings)
    if isprop(ch(k),'DisplayName') && ...
            ~isempty(get(ch(k),'DisplayName'))
        dname = get(ch(k),'DisplayName');
        if ~isempty(dname)
          strings{k} = dname;
        end
    end
end
set(h.PropertyListeners,'enable','off'); % for string listener
h.String = strings;
set(h.PropertyListeners,'enable','on'); % for string listener
layout_legend_items(h);

%----------------------------------------------------------------%
% Layout legend contents and refresh the properties of each
% entry to match any plot changes.
function layout_legend_items(h, varargin)

ch = double(h.Plotchildren);
strings = h.String;

% Call site may request not to refresh tokens
fullRefreshTokens = true;
if nargin == 2
    if strcmpi(varargin{1},'ignoreTokens')
      fullRefreshTokens = false;
    end
end

% position informaiton
s = getsizeinfo(h);
% legend size
lpos = ones(1,4);
lpos(3:4) = getsize(h,s);
% initial token and text positions
tokenx = [s.leftspace s.leftspace+s.tokenwidth]/lpos(3);
textx = (s.leftspace+s.tokenwidth+s.tokentotextspace)/lpos(3);
% initial ypos (for text and line items)
ypos = 1 - ((s.topspace+(s.strsizes(1,2)/2))/lpos(4)); % middle of token
% initial tokeny (top and bottom of patch) for patch items
tokeny = ([s.strsizes(1,2)/-2.5 + s.rowspace/2, s.strsizes(1,2)/2.5 - s.rowspace/2]/lpos(4)) + ypos;
% y increment for vertically oriented legends
yinc = (s.rowspace + s.strsizes(:,2))/lpos(4);
% x increment (not including string) for horizontally oriented legends
xinc = (s.tokenwidth + s.tokentotextspace + s.colspace)/lpos(3);

texthandle = h.ItemText;
tokenhandle = h.ItemTokens;
tindex = 1;
for k=1:length(ch)
  item = ch(k);
  % TEXT OBJECT
  if length(strings) < k
      str = '';
      visible = 'off';
  else
      str = strings{k};
      visible = 'on';
  end
  set(texthandle(k),...
      'Color',h.TextColor,...
      'String',str,...
      'Position',[textx ypos 0],...
      'Interpreter',h.Interpreter,...
      'FontSize',h.FontSize,...
      'FontAngle',h.FontAngle,...
      'FontWeight',h.FontWeight,...
      'FontName',h.FontName, ...
      'Visible',visible);

  if ~ishandle(item), continue; end

  % TOKEN
  item = localGetTokenItem(item);
  if isappdata(item,'LegendLegendInfo')
    li = getLegendInfo(h,item);
    tokenh = tokenhandle(tindex);
    if ishandle(tokenh)
      oldli = [];
      if isprop(tokenh,'LegendInfo')
        oldli = get(tokenh,'LegendInfo');
      end
      if ~isequal(li,oldli)
        delete(get(tokenh,'Children'));
      end
    end
    if ~isempty(li)
      if isequal(li,oldli)
        update_legendinfo_token(h,tokenh,li,tokenx,tokeny);
      else
        build_legendinfo_token(h,tokenh,li,tokenx,tokeny);
      end
    end
    set(tokenhandle(tindex),'Visible',visible);
    tindex = tindex+1;
  else
    type=get(item,'type');
    switch type
      % FOR LINE
     case 'line'
      % LINE PART OF LINE
      set(tokenhandle(tindex),...
          'Marker','none',...
          'XData',tokenx,...
          'YData',[ypos ypos],...
          'Tag',str(:).',...
          'Visible',visible);
      if fullRefreshTokens
          set(tokenhandle(tindex),...
              'Color',get(item,'Color'),...
              'LineWidth',get(item,'LineWidth'),...
              'LineStyle',get(item,'LineStyle'));
      end

      tindex = tindex+1;
      % MARKER PART OF LINE
      % line for marker part (having a separate line for the marker
      % allows us to center the marker in the line.
      set(tokenhandle(tindex),...
          'LineStyle','none',...
          'XData', (tokenx(1) + tokenx(2))/2,...
          'YData', ypos,...
          'Visible',visible);
      if  fullRefreshTokens
          set(tokenhandle(tindex),...
              'Color',get(item,'Color'),...
              'LineWidth',get(item,'LineWidth'),...
              'Marker',get(item,'Marker'),...
              'MarkerSize',get(item,'MarkerSize'),...
              'MarkerEdgeColor',get(item,'MarkerEdgeColor'),...
              'MarkerFaceColor',get(item,'MarkerFaceColor'));
      end            
      tindex = tindex+1;
      % FOR PATCH
     case {'patch','surface'}
      pyd = get(item,'xdata');
      if length(pyd) == 1
        pxdata = sum(tokenx)/length(tokenx);
        pydata = ypos;
      else
        pxdata = [tokenx(1) tokenx(1) tokenx(2) tokenx(2)];
        pydata = [tokeny(1) tokeny(2) tokeny(2) tokeny(1)];
      end
      [edgecolor,facecolor] = patchcolors(h,item);
      [facevertcdata,facevertadata] = patchvdata(h,item);
      if strcmp(facecolor,'none') && strcmp(type,'patch')
          pydata = repmat(mean(pydata),1,numel(pydata));
      end
      set(tokenhandle(tindex),...
          'XData', pxdata,...
          'YData', pydata,...
          'Tag',str(:).',...
          'Visible',visible);
      if fullRefreshTokens
          set(tokenhandle(tindex),...
              'FaceColor',facecolor,...
              'EdgeColor',edgecolor,...
              'LineWidth',get(item,'LineWidth'),...
              'LineStyle',get(item,'LineStyle'),...
              'Marker',get(item,'Marker'),...
              'MarkerSize',h.FontSize,...
              'MarkerEdgeColor',get(item,'MarkerEdgeColor'),...
              'MarkerFaceColor',get(item,'MarkerFaceColor'),...
              'FaceVertexCData',facevertcdata,...
              'FaceVertexAlphaData',facevertadata);
      end
      tindex = tindex+1;
    end
  end
      
  if k<length(strings)
      if strcmpi(h.Orientation,'vertical')
          ypos = ypos - (yinc(k)+yinc(k+1))/2;
          tokeny = tokeny - (yinc(k)+yinc(k+1))/2;
      else
          tokenx = tokenx + xinc + s.strsizes(k,1)/lpos(3);
          textx = textx + xinc + s.strsizes(k,1)/lpos(3);
      end
  end
end

%----------------------------------------------------------------%
function build_legendinfo_token(legh,gh,li,tx,ty) %#ok
% gh = handle to group object (parent)
% li = legend info handle

% get and build components of li
gcomp = li.GlyphChildren;
for k=1:length(gcomp)
    build_legendinfo_component(gh,gcomp(k),tx,ty);
end
if ~isprop(gh,'LegendInfo')
  prop = schema.prop(gh,'LegendInfo','handle');
  prop.AccessFlags.Serialize = 'off';
  prop.Visible = 'off';
end  
set(gh,'LegendInfo',li);

function adjust_data(lich,tx,ty)
% adjust x and y data (line, patch)
if isprop(lich,'xdata') && isprop(lich,'ydata')
    x = get(lich,'xdata');
    y = get(lich,'ydata');
    x = tx(1) + diff(tx).*x;
    y = ty(1) + diff(ty).*y;
    set(lich,'xdata',x,'ydata',y);
end

% adjust position (text)
if isprop(lich,'position')
    pos = get(lich,'position');
    pos(1) = tx(1) + diff(tx).*pos(1);
    pos(2) = ty(1) + diff(ty).*pos(2);
    set(lich,'position',pos);
end

%----------------------------------------------------------------%
function lich=build_legendinfo_component(p,lic,tx,ty)
% p = parent
% lic = legendinfochild

% create the component lich from lic properties (if any)
if isempty(lic.PVPairs)
    lich=feval(lic.ConstructorName,'Parent',double(p));
else
    lich=feval(lic.ConstructorName,'Parent',double(p),lic.PVPairs{:});
end
set(lich,'HitTest','off');
adjust_data(lich,tx,ty);
if ~isempty(lic.GlyphChildren)
    % get components of the component
    gcomp = lic.GlyphChildren;
    % build those children
    for k=1:length(gcomp)
        build_legendinfo_component(lich,gcomp(k),tx,ty);
    end
end

%----------------------------------------------------------------%
function update_legendinfo_token(legh,gh,li,tx,ty) %#ok
% gh = handle to group object (parent)
% li = legend info handle


% get and build components of li
gcomp = li.GlyphChildren;
ch = flipud(get(gh,'Children'));
for k=1:length(gcomp)
  if (isa(handle(ch(k)), gcomp(k).ConstructorName))
    update_legendinfo_component(ch(k),gcomp(k),tx,ty);
  else
    delete(ch(k));
    build_legendinfo_component(gh,gcomp(k),tx,ty);
    newchildren = get(gh, 'Children');
    ch(k) = newchildren(1);
    set(gh, 'Children', flipud(ch));    
  end
end

%----------------------------------------------------------------%
function update_legendinfo_component(lich,lic,tx,ty)
% lich = child handle
% lic = legendinfochild

if ~isempty(lic.PVPairs)
  set(lich,lic.PVPairs{:});
end
adjust_data(lich,tx,ty);
if ~isempty(lic.GlyphChildren)
    % get components of the component
    gcomp = lic.GlyphChildren;
    % build those children
    newch = flipud(get(lich,'Children'));
    numCh = length(gcomp);
    % Get rid of extra children
    if numCh < length(newch)
        delete(newch(numCh+1:end));
        newch(numCh+1:end) = [];
    end       
    for k=1:length(gcomp)
        if k <= numel(newch)
            update_legendinfo_component(newch(k),gcomp(k),tx,ty);
        else
            build_legendinfo_component(lich,gcomp(k),tx,ty);
        end
    end
end

%----------------------------------------------------------------%
% Update the legend UserData for backwards compatibility
function update_userdata(h)

ud.PlotHandle = double(h.Axes);
ud.legendpos = getnpos(h);
ud.LegendPosition = get(double(h),'position');
ud.LabelHandles = [double(h.ItemText)' double(h.ItemTokens)']';
if ~isempty(h.PlotChildren) && ~isa(h.Plotchildren(1),'scribe.legendinfo') 
    ud.handles = double(h.Plotchildren);
else
    % legend with legendinfo specs only require handle handles
    ud.handles = h.Plotchildren;
end
ud.lstrings = h.String';
ud.LegendHandle = double(h);
set(double(h),'UserData',ud);

%also update the LegendOldSize appdata
% this appdata is also set in init/setWidthHeight
parent = get(h,'Parent');
fig = parent;
if ~strcmp(get(fig,'Type'),'figure')
    fig = ancestor(fig,'figure');
end
pos = get(h,'Position');
siz = hgconvertunits(fig,pos,get(h,'Units'),'points',parent);
setappdata(double(h),'LegendOldSize',siz(3:4));

%----------------------------------------------------------------%
% Return the "numeric" position of a legend
function npos = getnpos(h)

switch h.location
 case 'Best'
  npos = 0;
 case 'NorthWest'
  npos = 2;
 case 'NorthEast'
  npos = 1;
 case 'NorthEastOutside'
  npos = -1;
 case 'SouthWest'
  npos = 3;
 case 'SouthEast'
  npos = 4;
 otherwise
  fig = ancestor(h,'figure');
  npos = hgconvertunits(fig,get(double(h),'Position'),get(h,'Units'),...
                        'points',get(h,'Parent'));
end

%----------------------------------------------------------------%
% Get the layout information for a legend. This includes string
% extents and gap amounts. All sizes are normalized to the figure.
function out = getsizeinfo(h)

parent = get(h,'Parent');
fig = ancestor(h,'figure');
ppos = hgconvertunits(fig,get(parent,'Position'),get(parent,'Units'),...
                            'points',get(parent,'Parent'));
ax = double(h);
fname = get(ax,'fontname'); fsize = get(ax,'fontsize');
fangl = get(ax,'fontangle'); fwght = get(ax,'fontweight');
interp = get(ax,'Interpreter');
strings = h.String;
if isempty(strings), strings{end+1} = 'data1'; end
% get normalized (to figure/overlay) sizes of all strings
strsizes = ones(length(strings),2);
for k=1:length(strings)
  str = strings{k};
  if isempty(str), str = 'Onj'; end
  strsizes(k,:) = strsize(h,ppos,fname,fsize,fangl,fwght,interp,str);
end
% space sizes in/around legend:

topspace = 2; out.topspace = topspace/ppos(4);
rowspace = 0.5; out.rowspace = rowspace/ppos(4);
botspace = 2; out.botspace = botspace/ppos(4);
leftspace = 6; out.leftspace = leftspace/ppos(3);
rightspace = 3; out.rightspace = rightspace/ppos(3);
tokentotextspace = 3; out.tokentotextspace = tokentotextspace/ppos(3);
colspace = 5; out.colspace = colspace/ppos(3);
out.tokenwidth = h.itemTokenSize(1)/ppos(3);
% spaces between legend and axes
laxspace = 5; out.xlaxspace = laxspace/ppos(3); out.ylaxspace = laxspace/ppos(4);
out.strsizes = strsizes;

%----------------------------------------------------------------%
% Get the width and height of a legend using size info struct s
function lsiz = getsize(h,s)

if nargin == 1, s = getsizeinfo(h); end

% legend size
if strcmpi(h.Orientation,'vertical')
    lsiz = [s.leftspace + s.tokenwidth + s.tokentotextspace + max(s.strsizes(:,1)) + s.rightspace,...
        s.topspace + sum(s.strsizes(:,2)) + (length(h.String) - 1)*s.rowspace + s.botspace];
else
    lsiz = [s.leftspace + (s.tokenwidth*length(h.String)) + (s.tokentotextspace*length(h.String)) + ...
        (length(h.String) - 1)*s.colspace + sum(s.strsizes(:,1)) + s.rightspace,...
        s.topspace + max(s.strsizes(:,2)) + s.rowspace + s.botspace];
end

%----------------------------------------------------------------%
function transMat = localGetAxesTransform(hAx)
% Returns an invertible transformation matrix that represents the
% transformation of a point in the axes coordinate space to pixel-space.
% Based on HG's gs_data3matrix_to_pixel internal C-function. It should be
% noted that the Y-coordinate is flipped with respect to the Figure
% Window's returned "CurrentPoint" properties.

% Get needed transforms
xform = get(hAx,'x_RenderTransform');
offset = get(hAx,'x_RenderOffset');
scale = get(hAx,'x_RenderScale');
zeroInd = scale == 0;
invScale = zeros(size(scale));
invScale(~zeroInd) = 1./scale(~zeroInd);

transMat = xform * [diag(invScale) -offset;0 0 0 1];

%----------------------------------------------------------------%
function newData = localDoTransform(transMat,data)
% Transforms data based on the homogeneous transform matrix. Data must be a
% 1x3 matrix.

data = [data;ones(1,size(data,2))];
newData = transMat*data;
w = newData(4,:);
w(w==0) = 1;
newData = newData(1:3,:);
newData(1,:) = newData(1,:)./w; 
newData(2,:) = newData(2,:)./w; 
newData(3,:) = newData(3,:)./w; 

%----------------------------------------------------------------%
% Get the best location for legend to minimize data overlap
function pos = get_best_location(h) %#ok
pos(3:4) = getsize(h);
pos(1:2) = lscan(double(h.Axes),double(h.Plotchildren),pos(3),pos(4),0,1);

%----------------------------------------------------------------%
% Scan for good legend location.
function Pos = lscan(ha,plotChildren,wdt,hgt,tol,stickytol) %#ok

% Calculate tile size
cap = hgconvertunits(ancestor(ha,'figure'),...
    get(ha,'Position'),get(ha,'Units'),...
    'normalized',get(ha,'Parent'));

islogx = strcmpi(get(ha,'XScale'),'Log');
islogy = strcmpi(get(ha,'YScale'),'Log');
xlim=get(ha,'Xlim');
ylim=get(ha,'Ylim');

if islogx
    xlim = log10(xlim);
end
if islogy
    ylim = log10(ylim);
end

if ~all(isfinite(xlim)) || ~all(isfinite(ylim))
  % If any of the public limits are inf then we need the actual limits
  % by getting the hidden deprecated RenderLimits.
  oldstate = warning('off','MATLAB:HandleGraphics:NonfunctionalProperty:RenderLimits');
  renderlimits = get(ha,'RenderLimits');
  warning(oldstate);
  xlim = renderlimits(1:2);
  ylim = renderlimits(3:4);
end

H=ylim(2)-ylim(1);
W=xlim(2)-xlim(1);

buffH = 0.03*H;
buffW = 0.03*W;
Hgt = hgt*H/cap(4);
Wdt = wdt*W/cap(3);
Thgt = H/max(1,floor(H/(Hgt+buffH)));
Twdt = W/max(1,floor(W/(Wdt+buffW)));

% If there is only room for one tile, use the size of the legend as the
% tile size.
tallLegend = false;
if H-Thgt < eps
    Thgt = Hgt+buffH;
    tallLegend = true;
end
longLegend = false;
if W-Twdt < eps
    Twdt = Wdt+buffW;
    longLegend = true;
end

dh = (Thgt - Hgt)/2;
dw = (Twdt - Wdt)/2;

% Get data, points and text
Kids=[findall(ha,'type','line'); ...
    findall(ha,'type','patch'); ...
    findall(ha,'type','surface'); ...
    findall(ha,'type','text')];
Xdata=[];Ydata=[];
for i=1:length(Kids),
    type = get(Kids(i),'type');
    if strcmp(type,'line')
        [xk,yk,zk] = localGetLineData(Kids(i));
        Xdata=[Xdata,xk];
        Ydata=[Ydata,yk];
    elseif strcmp(type,'patch') || strcmp(type,'surface')
        xk = get(Kids(i),'Xdata');
        yk = get(Kids(i),'Ydata');
        Xdata=[Xdata,xk(:)'];
        Ydata=[Ydata,yk(:)'];
    elseif strcmp(get(Kids(i),'type'),'text'),
        tmpunits = get(Kids(i),'units');
        set(Kids(i),'units','data')
        tmp=get(Kids(i),'Position');
        ext=get(Kids(i),'Extent');
        set(Kids(i),'units',tmpunits);
        Xdata=[Xdata,[tmp(1) tmp(1)+ext(3)]];
        Ydata=[Ydata,[tmp(2) tmp(2)+ext(4)]];
    end
end
% The legend may point to children that are not in the same axes. These
% children require a bit of preprocessing:
plotChildren(~ishandle(plotChildren)) = [];
otherKids = setdiff([findall(plotChildren,'type','line'); ...
    findall(plotChildren,'type','patch'); ...
    findall(plotChildren,'type','surface'); ...
    findall(plotChildren,'type','text')],Kids);

peerTransform = localGetAxesTransform(ha);
invPeerTransform = pinv(peerTransform);

if islogx
    Xdata = log10(Xdata);
end
if islogy
    Ydata = log10(Ydata);
end

for i=1:length(otherKids),
    type = get(otherKids(i),'type');
    hAx = ancestor(otherKids(i),'Axes');
    isOtherLogX = strcmpi(get(hAx,'XScale'),'Log');
    isOtherLogY = strcmpi(get(hAx,'YScale'),'Log');
    if strcmp(type,'line')
        [xk,yk,zk] = localGetLineData(otherKids(i));
        if isOtherLogX
            xk = log10(xk);
        end
        if isOtherLogY
            yk = log10(yk);
        end
        dataVec = [xk(:)';yk(:)';zk(:)'];
        currTransform = localGetAxesTransform(hAx);
        newData = localDoTransform(invPeerTransform,localDoTransform(currTransform,dataVec));
        if islogx
            newData(1,:) = 10.^newData(1,:);
        end
        if islogy
            newData(2,:) = 10.^newData(2,:);
        end
        Xdata=[Xdata,newData(1,:)];
        Ydata=[Ydata,newData(2,:)];
    elseif strcmp(type,'patch') || strcmp(type,'surface')
        xk = get(otherKids(i),'Xdata');
        yk = get(otherKids(i),'Ydata'); 
        if isvector(x)
            [xk,yk] = meshgrid(xk,yk);
        end
        if isOtherLogX
            xk = log10(xk);
        end
        if isOtherLogY
            yk = log10(yk);
        end        
        zk = get(otherKids(i),'Zdata');
        dataVec = [xk(:)';yk(:)';zk(:)'];
        currTransform = localGetAxesTransform(hAx);
        newData = localDoTransform(invPeerTransform,localDoTransform(currTransform,dataVec));
        if islogx
            newData(1,:) = 10.^newData(1,:);
        end
        if islogy
            newData(2,:) = 10.^newData(2,:);
        end        
        Xdata=[Xdata,newData(1,:)];
        Ydata=[Ydata,newData(2,:)];
    elseif strcmp(get(otherKids(i),'type'),'text'),
        tmpunits = get(otherKids(i),'units');
        set(otherKids(i),'units','data')
        tmp=get(otherKids(i),'Position');
        ext=get(otherKids(i),'Extent');
        set(otherKids(i),'units',tmpunits);
        xk = [tmp(1) tmp(1)+ext(3)];
        yk = [tmp(2) tmp(2)+ext(4)];
        if isOtherLogX
            xk = log10(xk);
        end
        if isOtherLogY
            yk = log10(yk);
        end        
        zk = [0 0];
        dataVec = [xk(:)';yk(:)';zk(:)'];
        currTransform = localGetAxesTransform(hAx);
        newData = localDoTransform(invPeerTransform,localDoTransform(currTransform,dataVec));s
        if islogx
            newData(1,:) = 10.^newData(1,:);
        end
        if islogy
            newData(2,:) = 10.^newData(2,:);
        end        
        Xdata=[Xdata,newData(1,:)];
        Ydata=[Ydata,newData(2,:)];
    end
end 

% make sure xdata and ydata have same length
if ~isequal(length(Xdata),length(Ydata))
    xydlength = min(length(Xdata),length(Ydata));
    Xdata = Xdata(1:xydlength);
    Ydata = Ydata(1:xydlength);
end
% xdata and ydata must have same dimensions
in = isfinite(Xdata) & isfinite(Ydata);
Xdata = Xdata(in);
Ydata = Ydata(in);

% Determine # of data points under each "tile"
% Since the tile-size may not evenly go into the width or height, make this
% a two-pass approach taking only the unique positions.
xp = unique([(0:Twdt:W-Twdt) (W-Twdt:-Twdt:0)] + xlim(1));
% If we are in a scenario with a longer legend, be sure not to ignore the
% middle as a valid location.
if longLegend
    xp(end+1) = (W/2 - (Wdt+buffW)/2)+xlim(1);
end

yp = unique([(H-Thgt:-Thgt:0) (0:Thgt:H-Thgt)]+ ylim(1));
% If we are in a scenario with a taller legend, be sure not to ignore the
% middle as a valid location.
if tallLegend
    yp(end+1) =  (H/2 - (Hgt+buffH)/2)+ylim(1);
end

wtol = Twdt / 100;
htol = Thgt / 100;
pop = zeros(length(yp),length(xp));
for j=1:length(yp)
    for i=1:length(xp)
        pop(j,i) = sum(sum((Xdata > xp(i)-wtol) & (Xdata < xp(i)+Twdt+wtol) & ...
            (Ydata > yp(j)-htol) & (Ydata < yp(j)+Thgt+htol)));    
    end
end

% If the "XDir" property is set to reverse, then the tiles need to be
% flipped:
if strcmpi(get(ha,'XDir'),'Reverse')
    pop = fliplr(pop);
end
% If the "YDir" property is set to reverse, then the tiles need to be
% flipped:
if strcmpi(get(ha,'YDir'),'Reverse')
    pop = flipud(pop);
end

if all(pop(:) == 0), pop(1) = 1; end

% Cover up fewest points.  After this while loop, pop will
% be lowest furthest away from the data
while any(pop(:) == 0)
    newpop = filter2(ones(3),pop);
    if all(newpop(:) ~= 0)
        break;
    end
    pop = newpop;
end

[j,i] = find(pop == min(pop(:)));
xp =  xp - xlim(1) + dw;
yp =  yp - ylim(1) + dh;
Pos = [cap(1)+xp(i(end))*cap(3)/W
    cap(2)+yp(j(end))*cap(4)/H];

%----------------------------------------------------------------%
function [xk,yk,zk] = localGetLineData(hLine)
% Returns data information regarding a line.

xk = get(hLine,'Xdata');
yk = get(hLine,'Ydata');
zk = get(hLine,'Zdata');
if isempty(zk)
    zk = zeros(size(xk));
end
eithernan = isnan(xk) | isnan(yk) | isnan(zk);
xk(eithernan) = [];
yk(eithernan) = [];
zk(eithernan) = [];
nx = length(xk);
ny = length(yk);
nz = length(zk);
if nx < 100 && nx > 1 && ny < 100 && ny > 1
    xk = interp1(xk,linspace(1,nx,200));
    yk = interp1(yk,linspace(1,ny,200));
    zk = interp1(zk,linspace(1,nz,200));
end


%----------------------------------------------------------------%
% return size of string normalized to fpos (which should be in points)
function size=strsize(ax,fpos,fontname,fontsize,fontangle,fontweight,interp,str)

ax = double(ax);
t = getappdata(ax,'LegendTempText');
if isempty(t) || ~ishandle(t)
  t=text('Parent',ax,...
         'Units','points',...
         'Visible','off',...
         'HandleVisibility','off',...
         'Editing','off',...
         'Margin', 0.01,...
         'Tag','temphackytext');
  setappdata(ax,'LegendTempText',t);
end
set(t,'FontUnits','points');
oldwarn = warning('off'); %#ok
set(t,'FontSize',fontsize,...
      'Interpreter',interp,...
      'FontAngle',fontangle,...
      'FontWeight',fontweight,...
      'String',str, ...
      'FontName',fontname);

ext = get(t,'extent');
size = ext(3:4)./fpos(3:4);
warning(oldwarn);

%----------------------------------------------------%
% Find any legend in parent of input
function leg = find_legend(ha) %#ok

fig = get(ha,'parent');
ax = findobj(fig,'type','axes');
leg=[];
k=1;
while k<=length(ax) && isempty(leg)
  if islegend(ax(k))
    hax = handle(ax(k));
    if isequal(double(hax.axes),ha)
      leg=ax(k);
    end
  end
  k=k+1;
end

%----------------------------------------------------%
% Check if input is a legend
function tf=islegend(ax)

if length(ax) ~= 1 || ~ishandle(ax)
  tf=false;
else
  tf=isa(handle(ax),'scribe.legend');
end

%----------------------------------------------------%
function  [edgecolor,facecolor] = patchcolors(leg,h) %#ok

cdat = get(h,'Cdata');
facecolor = get(h,'FaceColor');
if any(strcmp(facecolor,{'interp', 'texturemap'}))
  if ~all(cdat == cdat(1))
    warning('MATLAB:legend:UnsupportedFaceColor',...
            'Legend not supported for patches with FaceColor ''%s''',facecolor)
  end
  facecolor = 'flat';
end
if strcmp(facecolor,'flat')
  if size(cdat,3) == 1       % Indexed Color
    if ~any(isfinite(cdat))
      facecolor = 'none';
    end
  else                       % RGB values
    facecolor = reshape(cdat(1,1,:),1,3);
  end
end

edgecolor = get(h,'EdgeColor');
if strcmp(edgecolor,'interp')
  if ~all(cdat == cdat(1))
    warning('MATLAB:legend:UnsupportedEdgeColor',...
            'Legend not supported for patches with EdgeColor ''interp''')
  end
  edgecolor = 'flat';
end
if strcmp(edgecolor,'flat')
  if size(cdat,3) == 1      % Indexed Color
    if ~any(isfinite(cdat))
      edgecolor = 'none';
    end
  else                      % RGB values
    edgecolor = reshape(cdat(1,1,:),1,3);
  end
end

%------------------------------------------------------------------%
function [facevertcdata,facevertadata] = patchvdata(leg,h) %#ok

cdat = get(h,'CData');
if isempty(cdat)
  %Set this as the first index in the colormap.  I would like to set it as
  %white [1 1 1], but painters complains when given RGB CData.
  facecolor = 1;
elseif size(cdat,3) == 1 % Indexed Color
                         % facecolor = cdat(1,1,1); %<-- may not be representative
                         % use mean cdata value
  facecolor = cdat(:);
  facecolor = mean(facecolor(~isnan(facecolor)));
elseif size(cdat,3) == 3 % RGB values
  facecolor = reshape(cdat(1,1,:),1,3);
else
  facecolor = 1;
end

xdat = get(h,'XData');

if length(xdat) == 1
  facevertcdata = facecolor;
else
  facevertcdata = [facecolor;facecolor;facecolor;facecolor];
end

try
  facealpha=get(h,'FaceVertexAlphaData');
catch ex %#ok<NASGU>
  try
    facealpha=get(h,'AlphaData');
  catch ex2 %#ok<NASGU>
    facealpha=1;
  end
end

if length(facealpha)<1
  facealpha=1;
else
  facealpha=facealpha(1);
end

if length(xdat) == 1
  facevertadata = facealpha;
else
  facevertadata = [facealpha;facealpha;facealpha;facealpha];
end

%-------------------------------------------------------------------%
%                Legend Context Menu
%-------------------------------------------------------------------%

%--------------------------------------------------------------------%
function set_contextmenu(h,onoff) %#ok

fig = ancestor(h,'figure');
uic = get(h,'UIContextMenu');
if isempty(uic)
  uic = uicontextmenu('Parent',fig,'HandleVisibility','off');
  setappdata(uic,'CallbackObject',h);
  % Refresh
  hMenu = graph2dhelper('createScribeUIMenuEntry',fig,'GeneralAction','Refresh','','',{@refresh_cb,h});
  set(hMenu,'Tag','scribe:legend:refresh');
  % Delete
  hMenu(end+1) = graph2dhelper('createScribeUIMenuEntry',fig,'GeneralAction','Delete','','',{@delete_cb,h});
  set(hMenu(end),'Tag','scribe:legend:delete');
  % Color
  hMenu(end+1) = graph2dhelper('createScribeUIMenuEntry',fig,'Color','Color ...','Color','Color');
  set(hMenu(end),'Separator','on');
  set(hMenu(end),'Tag','scribe:legend:color');
  % Edge color (xcolor and ycolor)
  hMenu(end+1) = graph2dhelper('createScribeUIMenuEntry',fig,'Color','Edge Color ...',{'XColor','YColor'},'Edge Color');
  set(hMenu(end),'Tag','scribe:legend:edgecolor');
  % Line width
  hMenu(end+1) = graph2dhelper('createScribeUIMenuEntry',fig,'LineWidth','Line Width','LineWidth','Line Width');
  set(hMenu(end),'Tag','scribe:legend:linewidth');
  hChil = findall(hMenu(end));
  hChil = hChil(2:end);
  widthTags = {'scribe:legend:linewidth:12.0';'scribe:legend:linewidth:11.0';...
      'scribe:legend:linewidth:10.0';'scribe:legend:linewidth:9.0';...
      'scribe:legend:linewidth:8.0';'scribe:legend:linewidth:7.0';...
      'scribe:legend:linewidth:6.0';'scribe:legend:linewidth:5.0';...
      'scribe:legend:linewidth:4.0';'scribe:legend:linewidth:3.0';...
      'scribe:legend:linewidth:2.0';'scribe:legend:linewidth:1.0';...
      'scribe:legend:linewidth:0.5'};
  set(hChil,{'Tag'},widthTags);
  % Font properties
  hMenu(end+1) = graph2dhelper('createScribeUIMenuEntry',fig,'Font','Font ...','','Font');
  set(hMenu(end),'Tag','scribe:legend:font');
  % Interpreter
  hMenu(end+1) = graph2dhelper('createScribeUIMenuEntry',fig,'TextInterpreter','Interpreter','Interpreter','Interpreter');
  set(hMenu(end),'Tag','scribe:legend:interpreter');
  hChil = findall(hMenu(end));
  hChil = flipud(hChil(2:end));
  intTags = {'scribe:legend:interpreter:latex';'scribe:legend:interpreter:tex';...
      'scribe:legend:interpreter:none'};
  set(hChil,{'Tag'},intTags);
  % Location
  hMenu(end+1) = graph2dhelper('createScribeUIMenuEntry',fig,'EnumEntry','Location','Location','Location',...
      {'Best','Inside North East','Outside North East','Inside South East',...
      'Inside North West','Outside North West','Inside South West'},...
      {'Best','NorthEast','NorthEastOutside','SouthEast','NorthWest','NorthWestOutside','SouthWest'});
  set(hMenu(end),'Tag','scribe:legend:location');
  hChil = findall(hMenu(end));
  hChil = flipud(hChil(2:end));
  loctags = {'scribe:legend:location:best';'scribe:legend:location:northeast';...
      'scribe:legend:location:northeastoutside';'scribe:legend:location:southeast';...
      'scribe:legend:location:northwest';'scribe:legend:location:northwestoutside';...
      'scribe:legend:location:southwest'};
  set(hChil,{'Tag'},loctags);
  % Orientation
  hMenu(end+1) = graph2dhelper('createScribeUIMenuEntry',fig,'EnumEntry','Orientation','Orientation','Orientation',...
      {'vertical','horizontal'},{'vertical','horizontal'});
  set(hMenu(end),'Tag','scribe:legend:orientation');
  hChil = findall(hMenu(end));
  hChil = flipud(hChil(2:end));
  ortags = {'scribe:legend:orientation:vertical';'scribe:legend:orientation:horizontal'};
  set(hChil,{'Tag'},ortags);
  % Set the parent of the menus
  set(hMenu,'Parent',uic);
  set(findall(hMenu),'Visible','on');
  % Property Editor
  hMenu = uimenu(uic,'HandleVisibility','off','Separator','on',...
      'Label','Show Property Editor','Callback',{@localOpenPropertyEditor,h});
  set(hMenu,'Tag','scribe:legend:propedit');
  % Code
  hMenu = uimenu(uic,'HandleVisibility','off','Separator','on',...
      'Label','Show Code','Callback',{@localGenerateMCode,h});
  set(hMenu,'Tag','scribe:legend:mcode');
  
  % set the context menu
  set(h,'uicontextmenu',uic);
end

%----------------------------------------------------------------%
function localOpenPropertyEditor(obj,evd,hLeg) %#ok<INUSL>

propedit(hLeg,'-noselect');

%----------------------------------------------------------------%
function localGenerateMCode(obj,evd,hLeg) %#ok<INUSL>

makemcode(hLeg,'Output','-editor')

%----------------------------------------------------------------%
function tokObj = localGetTokenItem(hObj)
% Given an HG object, return the item that will create its token:

if ~strcmpi(get(hObj,'Type'),'hggroup') && ~strcmpi(get(hObj,'Type'),'hgtransform')
    tokObj = hObj;
    return
end

% If the hggroup has legendinfo appdata, this will dominate:
if isappdata(double(hObj),'LegendLegendInfo')
    tokObj = hObj;
    return
end

% If the hggroup has no handle-visible children, or children whose 
% "IconDisplayStyle" is set to "off", return the group:
hChil = get(hObj,'Children');
% Filter out the legendable children:
legKids = arrayfun(@(x)(graph2dhelper('islegendable',x)),hChil);
hChil(~legKids) = [];
hChil = graph2dhelper('expandLegendChildren',hChil);
if isempty(hChil)
    tokObj = hObj;
    return
end

% Otherwise, recurse and get the token of the first child:
tokObj = localGetTokenItem(hChil(1));

%----------------------------------------------------------------%
function create_plotchild_listeners(h,hch,ch,forceDeleteListener) %#ok

if ~isprop(h,'ScribePLegendListeners')
    l = schema.prop(h,'ScribePLegendListeners','MATLAB array');
    l.AccessFlags.Serialize = 'off';
    l.Visible = 'off';
    newlis = {};
else
    newlis = get(h,'ScribePLegendListeners');
end
for i=1:length(hch)
    currHandle = hch(i);
    % Make sure we attach listeners to objects that actually determine the
    % tokens.
    currHandle = handle(localGetTokenItem(currHandle));
    cls = classhandle(currHandle);
    currObj = double(currHandle);
    type = get(currObj,'type');
    switch type
        case 'line'
            lis.color = handle.listener(currObj, cls.findprop('Color'), 'PropertyPostSet', {@PlotChildLinePropChanged,h,currHandle});
        case {'patch','surface'}
            lis.facecolor = handle.listener(currObj, cls.findprop('FaceColor'), 'PropertyPostSet', {@PlotChildPatchPropChanged,h,currHandle});
            lis.edgecolor = handle.listener(currObj, cls.findprop('EdgeColor'), 'PropertyPostSet', {@PlotChildPatchPropChanged,h,currHandle});
    end
    lis.linestyle = handle.listener(currObj, cls.findprop('LineStyle'), 'PropertyPostSet', {@PlotChildAllLinePropChanged,h,currHandle});
    lis.linewidth = handle.listener(currObj, cls.findprop('LineWidth'), 'PropertyPostSet', {@PlotChildAllLinePropChanged,h,currHandle});
    lis.marker = handle.listener(currObj, cls.findprop('Marker'), 'PropertyPostSet', {@PlotChildMarkerPropChanged,h,currHandle});
    lis.markersize = handle.listener(currObj, cls.findprop('MarkerSize'), 'PropertyPostSet', {@PlotChildMarkerPropChanged,h,currHandle});
    lis.markeredgecolor = handle.listener(currObj, cls.findprop('MarkerEdgeColor'), 'PropertyPostSet', {@PlotChildMarkerPropChanged,h,currHandle});
    lis.markerfacecolor = handle.listener(currObj, cls.findprop('MarkerFaceColor'), 'PropertyPostSet', {@PlotChildMarkerPropChanged,h,currHandle});
    if isprop(currHandle,'DisplayName')
        lis.dispname = handle.listener(currObj, cls.findprop('DisplayName'),'PropertyPostSet',{@PlotChildDispNameChanged,h,currHandle});
    end
    if isequal(h.PlotChildListen,'on')
        lis.deleted = handle.listener(currObj, 'ObjectBeingDestroyed', {@PlotChildDeleted,h,currHandle});
    end
    newlis{end+1} = lis; %#ok<AGROW>
end
set(h,'ScribePLegendListeners',newlis);


%----------------------------------------------------------------%
function PlotChildLinePropChanged(hProp,eventData,h,hch) %#ok

tok = [];
tok=[tok;getappdata(double(eventData.AffectedObject),'legend_linetokenhandle')];
tok=[tok;getappdata(double(eventData.AffectedObject),'legend_linemarkertokenhandle')];
if ~isempty(tok) && all(ishandle(tok))
    set(double(tok),hProp.Name,eventData.NewValue);
end

%----------------------------------------------------------------%
function PlotChildPatchPropChanged(hProp,eventData,h,hch) %#ok

tok=getappdata(double(eventData.AffectedObject),'legend_patchtokenhandle');
if ~isempty(tok) && all(ishandle(tok))
    set(double(tok),hProp.Name,eventData.NewValue);
    if strcmp(hProp.Name,'FaceColor')
        % need to update YData so refresh all items
        layout_legend_items(h);
    end
end

%----------------------------------------------------------------%
function PlotChildAllLinePropChanged(hProp,eventData,h,hch) %#ok

tok=[];
if strcmpi(get(double(eventData.AffectedObject),'type'),'line')
    tok=[tok;getappdata(double(eventData.AffectedObject),'legend_linetokenhandle')];
    tok=[tok;getappdata(double(eventData.AffectedObject),'legend_linemarkertokenhandle')];
else
    tok=getappdata(double(eventData.AffectedObject),'legend_patchtokenhandle');
end
if ~isempty(tok) && all(ishandle(tok))
    set(double(tok),hProp.Name,eventData.NewValue);
end

%----------------------------------------------------------------%
function PlotChildMarkerPropChanged(hProp,eventData,h,hch) %#ok

if strcmpi(get(double(eventData.AffectedObject),'type'),'line')
    tok = getappdata(double(eventData.AffectedObject),'legend_linemarkertokenhandle');
else
    tok=getappdata(double(eventData.AffectedObject),'legend_patchtokenhandle');
end
if ~isempty(tok) && all(ishandle(tok))
    set(double(tok),hProp.Name,eventData.NewValue);
end

%----------------------------------------------------------------%
function PlotChildDispNameChanged(hProp,eventData,h,hch) %#ok

ch = double(h.Plotchildren);
n = find(ch == double(hch));
if isempty(n), return; end
strings = h.String;
strings{n} = get(hch,'DisplayName');
set(h.PropertyListeners,'enable','off'); % for string listener
h.String = strings;
set(h.PropertyListeners,'enable','on'); % for string listener
layout_legend_items(h,'ignoreTokens');
legendcolorbarlayout(h.Axes,'objectChanged',double(h))
methods(h,'update_userdata');

%----------------------------------------------------------------%
function PlotChildDeleted(hProp,eventData,h,hch) %#ok
doPlotChildDeleted(h,hch);

function doPlotChildDeleted(h,hch)

if ~ishandle(double(h)) || ~isprop(h,'plotchildren')
    return;
end

delchild = true;
delch = double(hch);
delchtype = get(delch,'type');
ch = double(h.Plotchildren);

% check to see if it's a part of an existing scattergroup
% and don't delete the item if it is.
if ~isempty(h.Plotchildren)
    chtypes = get(ch,'type');
    if strcmpi(delchtype,'patch') && isappdata(delch,'scattergroup')
        delscgroup = getappdata(delch,'scattergroup');
        chpatches = ch(strcmpi(chtypes,'patch'));
        k=1;
        while k<=length(chpatches) && delchild
            getappdata(chpatches(k),'scattergroup');
            % don't delete if there is another patch with the same
            % scattergroup
            if isequal(getappdata(chpatches(k),'scattergroup'),delscgroup) && ...
                    ~isequal(chpatches(k),delch)
                delchild = false;
            end
            k=k+1;
        end
    end
end

if delchild
    % get delete index
    delindex = find(eq(delch,ch));
    % remove from child and strings lists
    str = h.String;
    ch(delindex) = [];
    str(delindex) = [];
    
    h.Plotchildren = ch;
    set(h.PropertyListeners,'enable','off'); % for string listener
    h.String = str;
    set(h.PropertyListeners,'enable','on'); % for string listener
    
    % remove old text and token items
    delete(h.ItemText);
    delete(h.ItemTokens);
    
    % update legend
    if isempty(ch)
        % if no children, delete legend
        delete(h);
    else
        % make new items for legend
        create_legend_items(h,ch);
        legendcolorbarlayout(h.Axes,'objectChanged',double(h))
        % update user data
        methods(h,'update_userdata');
    end
end

%----------------------------------------------------------------%
% Local Utilities
%----------------------------------------------------------------%
function create_legend_items(h,children)
children = double(children);

% construct strings from string cell and counts
strings = h.String;

s = methods(h,'getsizeinfo');
lpos = ones(1,4);
lpos(3:4) = methods(h,'getsize',s);

% initial token and text positions
tokenx = [s.leftspace s.leftspace+s.tokenwidth]/lpos(3);
textx = (s.leftspace+s.tokenwidth+s.tokentotextspace)/lpos(3);
% initial ypos (for text and line items)
ypos = 1 - ((s.topspace+(s.strsizes(1,2)/2))/lpos(4)); % middle of token
% initial tokeny (top and bottom of patch) for patch items
tokeny = ([s.strsizes(1,2)/-2.5 + s.rowspace/2, s.strsizes(1,2)/2.5 - s.rowspace/2]/lpos(4)) + ypos;
% y increment for vertically oriented legends
yinc = (s.rowspace + s.strsizes(:,2))/lpos(4);
% x increment (not including string) for horizontally oriented legends
xinc = (s.tokenwidth + s.tokentotextspace + s.colspace)/lpos(3);

texthandle = zeros(length(children),1);
tokenhandle = [];

for k=1:length(children)
  item = children(k);
  % TEXT OBJECT
  texthandle(k) = text('Parent',double(h),...
                       'Interpreter',h.Interpreter,...
                       'Units','normalized',...
                       'Color',h.TextColor,...
                       'String',strings{k},...
                       'Position',[textx ypos 0],...
                       'VerticalAlignment','middle',...
                       'SelectionHighlight','off',...
                       'Interruptible','off','HitTest','off');
  set(texthandle(k),'FontUnits','points',...
                    'FontAngle',h.FontAngle,...
                    'FontWeight',h.FontWeight,...
                    'FontName',h.FontName);
  set(texthandle(k),'FontSize',h.FontSize);
  set(texthandle(k),'ButtonDownFcn',methods(h,'getfunhan','tbdowncb',k)); 
  htext = handle(texthandle(k));
  props = [htext.findprop('FontName'),htext.findprop('FontSize'),...
           htext.findprop('FontWeight'),htext.findprop('FontAngle')];
  l = handle.listener(htext, props,...
                      'PropertyPostSet', @changedItemTextFontProperties);
  setappdata(double(htext), 'Listeners', l);                             
                             
  setappdata(item,'legend_texthandle',texthandle(k));
  % TOKEN (GRAPHIC)
  if isa(item,'scribe.legendinfo')
    li = item;
    tokenhandle(end+1) = hg.hggroup(...
        'Parent',double(h),...
        'HitTest','off',...
        'Tag',strings{k}(:).',...
        'SelectionHighlight','off',...
        'Interruptible','off');
    methods(h,'build_legendinfo_token',tokenhandle(end),li,tokenx,tokeny);
  else
      item = localGetTokenItem(item);
    type=get(item,'type');
    if isappdata(item,'LegendLegendInfo')
      li = getLegendInfo(h,item);
      tokenhandle(end+1) = hg.hggroup(...
          'Parent',double(h),...
          'HitTest','off',...
          'Tag',strings{k}(:).',...
          'SelectionHighlight','off',...
          'Interruptible','off');
      if ishandle(li)
        methods(h,'build_legendinfo_token',tokenhandle(end),li,tokenx,tokeny);
      else
        rmappdata(item, 'LegendLegendInfo');
      end
    else
      switch type
        % FOR LINE
       case 'line'
        % LINE PART OF LINE
        tokenhandle(end+1) = line('Parent',double(h),...
                                  'Color',get(item,'Color'),...
                                  'LineWidth',get(item,'LineWidth'),...
                                  'LineStyle',get(item,'LineStyle'),...
                                  'Marker','none',...
                                  'XData',tokenx,...
                                  'YData',[ypos ypos],...
                                  'Tag',strings{k}(:).',...
                                  'SelectionHighlight','off',...
                                  'HitTest','off',...
                                  'Interruptible','off');
        setappdata(item,'legend_linetokenhandle',tokenhandle(end));
        % MARKER PART OF LINE
        % line for marker part (having a separate line for the marker
        % allows us to center the marker in the line.
        tokenhandle(end+1) = line('Parent',double(h),...
                                  'Color',get(item,'Color'),...
                                  'LineWidth',get(item,'LineWidth'),...
                                  'LineStyle','none',...
                                  'Marker',get(item,'Marker'),...
                                  'MarkerSize',get(item,'MarkerSize'),...
                                  'MarkerEdgeColor',get(item,'MarkerEdgeColor'),...
                                  'MarkerFaceColor',get(item,'MarkerFaceColor'),...
                                  'XData', (tokenx(1) + tokenx(2))/2,...
                                  'YData', ypos,...
                                  'HitTest','off',...
                                  'SelectionHighlight','off',...
                                  'Interruptible','off');
        setappdata(item,'legend_linemarkertokenhandle',tokenhandle(end));
        % FOR PATCH
       case {'patch','surface'}
        pyd = get(item,'xdata');
        if length(pyd) == 1
          pxdata = sum(tokenx)/length(tokenx);
          pydata = ypos;
        else
          pxdata = [tokenx(1) tokenx(1) tokenx(2) tokenx(2)];
          pydata = [tokeny(1) tokeny(2) tokeny(2) tokeny(1)];
        end
        [edgecolor,facecolor] = patchcolors(h,item);
        [facevertcdata,facevertadata] = patchvdata(h,item);
        if strcmp(facecolor,'none') && strcmp(type,'patch')
            pydata = repmat(mean(pydata),1,numel(pydata));
        end
        tokenhandle(end+1) = patch('Parent',double(h),...
                                   'FaceColor',facecolor,...
                                   'EdgeColor',edgecolor,...
                                   'LineWidth',get(item,'LineWidth'),...
                                   'LineStyle',get(item,'LineStyle'),...
                                   'Marker',get(item,'Marker'),...
                                   'MarkerSize',h.FontSize,...
                                   'MarkerEdgeColor',get(item,'MarkerEdgeColor'),...
                                   'MarkerFaceColor',get(item,'MarkerFaceColor'),...
                                   'XData', pxdata,...
                                   'YData', pydata,...
                                   'FaceVertexCData',facevertcdata,...
                                   'FaceVertexAlphaData',facevertadata,...
                                   'Tag',strings{k}(:).',...
                                   'SelectionHighlight','off',...
                                   'HitTest','off',...
                                   'Interruptible','off');
        setappdata(item,'legend_patchtokenhandle',tokenhandle(end));
      end
    end
  end
  if k<length(children)
    if strcmpi(h.Orientation,'vertical')
      ypos = ypos - (yinc(k)+yinc(k+1))/2;
      tokeny = tokeny - (yinc(k)+yinc(k+1))/2;
    else
      tokenx = tokenx + xinc + s.strsizes(k,1)/lpos(3);
      textx = textx + xinc + s.strsizes(k,1)/lpos(3);
    end
  end
end
h.ItemText = texthandle;
h.ItemTokens = tokenhandle;

function li = getLegendInfo(h,item)
li = getappdata(item,'LegendLegendInfo');
if isempty(li) || ~ishandle(li)
  enabled = get(h.PropertyListeners,'enabled');
  set(h.PropertyListeners,'enabled','off');
  try
    setLegendInfo(handle(item));
  catch ex %#ok<NASGU>
    lis = getappdata(item, 'LegendLegendInfoStruct');
    if ~isempty(lis)
      legendinfo(item, lis{:});
    end
  end
  set(h.PropertyListeners,{'enabled'},enabled);
  li = getappdata(item,'LegendLegendInfo');
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

%----------------------------------------------------------------%
function changedItemTextFontProperties(hProp,eventData) %#ok
% The user should not be allowed to change the font properties of the
% individual text item.
leg = get(eventData.AffectedObject, 'parent');
hleg = handle(leg);
prop = eventData.Source.Name;
    
% If the text object's prop is different from that of the legend reflect
% the value onto the legend.
if strcmp(prop, 'FontSize')
  equal = (eventData.NewValue == get(leg,prop));
else
  equal = strcmp(eventData.NewValue,get(leg,prop));
end
if ~equal
    set(leg, prop, eventData.NewValue);    
    hleg.methods('layout_legend_items','ignoreTokens');
    legendcolorbarlayout(double(hleg.Axes), 'objectChanged', hleg);
end

%----------------------------------------------------------------%
function delete_cb(hProp,eventData,leg) %#ok
% If plot edit mode is on, we want to go through the plot edit mode delete
% infrastructure in order to gain undo support:

hFig = ancestor(leg,'figure');
if isactiveuimode(hFig,'Standard.EditPlot')
    scribeccp(hFig,'delete');
else
    delete(leg);
end

%----------------------------------------------------------------%
function refresh_cb(hProp,eventData,leg) %#ok
refresh(leg);

%----------------------------------------------------------------%
function refresh(leg)

hleg = handle(leg);
ax = hleg.Axes;
children = graph2dhelper ('get_legendable_children', handle(ax));
vis = strcmp(get(children,'Visible'), 'on');
children = children(vis);

% Delete the items tokens and strings
delete(hleg.ItemTokens);
delete(hleg.ItemText);

% Get the legend strings
str = {};
for k=1:length(children)
  if isprop(children(k),'DisplayName') &&...
           ~isempty(get(children(k),'DisplayName'))
    str{k} = get(children(k),'DisplayName');
  else
    str{k} = ['data',num2str(k)];
  end
end

% Create plotchild listeners for plot children
% added since last refresh or legend creation
newChildren = setdiff(children,double(hleg.PlotChildren));
hnewChildren = handle(newChildren);
create_plotchild_listeners(hleg, hnewChildren, newChildren);

% (Re)create the legend tokens
set(hleg.PropertyListeners, 'enable','off');
hleg.PlotChildren = children;
hleg.String = str;
create_legend_items(hleg, children);

% Layout the legend again
layout_legend_items(hleg);
legendcolorbarlayout(ax, 'objectChanged', hleg);
set(hleg.PropertyListeners, 'enable','on');

%----------------------------------------------------------------%
function update_contextmenu_cb(varargin) %#ok<DEFNU>
% This is a stub method for back compatibility
