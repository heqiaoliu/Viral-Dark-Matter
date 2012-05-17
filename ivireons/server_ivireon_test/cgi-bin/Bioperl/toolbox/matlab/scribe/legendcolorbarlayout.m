function legendcolorbarlayout(ax,action,varargin)
%LEGENDCOLORBARLAYOUT Layout legend and/or colorbar around axes
%   This is a helper function for legend and colorbar. Do not call
%   directly.

%   LEGENDCOLORBARLAYOUT(AX,'layout') lays out any
%   legends and colorbars around axes AX
%   LEGENDCOLORBARLAYOUT(AX,'on') turns on the listeners for laying
%   out legends and colorbars for axes AX.
%   LEGENDCOLORBARLAYOUT(AX,'off') turns off the listeners.
%   LEGENDCOLORBARLAYOUT(AX,'remove') deletes the listeners.
%   LEGENDCOLORBARLAYOUT(AX,'addToLayoutList',h) adds h to layout
%   list. Does not perform a layout afterwards.
%   LEGENDCOLORBARLAYOUT(AX,'removeFromLayoutList',h) removes h
%   from layout list. Does not perform a layout afterwards.
%   LEGENDCOLORBARLAYOUT(AX,'objectChanged',h) update layout
%   because of h.
%   LEGENDCOLORBARLAYOUT(AX,'resetOuterLayout') resets the position
%   of AX to fill where the outside legends and colorbars were.
%   LEGENDCOLORBARLAYOUT(AX,'resetOuterLayout','force') forces
%   the outer layout to reset even if the layout listeners don't exist
%   LEGENDCOLORBARLAYOUT(AX,'layoutNoPixelBounds')

%   Copyright 1984-2009 The MathWorks, Inc.

if feature('HGUsingMATLABClasses')
    legendcolorbarlayoutHGUsingMATLABClasses(ax,action,varargin{:});
    return;
end

switch(action)

    case 'layout'
        doLayout(double(ax));

    case 'on'
        list = getListeners(ax);
        if isempty(list)
            list = createListeners(ax);
        end
        set(list,'enable','on');

    case 'off'
        list = getListeners(ax);
        if ~isempty(list)
            set(list,'enable','on');
        end

    case 'remove'
        if ~isempty(getListeners(ax))
            rmListeners(ax);
        end

    case 'objectChanged' % called when one object in the layout changes size
        h = varargin{1};
        location = get(h,'Location');
        if strncmp(fliplr(location),'edistuO',7) % match 'FooOutside'
            legendcolorbarlayout(ax,'resetOuterLayout');
        elseif isa(handle(h),'scribe.legend') && any(strcmp(location,{'Best','none'}))
            h = handle(h);
            if strcmp(location,'none')
                resizeManualLegend(h);
            else
                doBestLegendLayout(ax,h);
            end
            return;
        end

        doLayout(ax);

    case 'removeFromLayoutList'
        h = varargin{1};
        if isempty(ax) || ~ishandle(ax) || ...
                isempty(h) || ~ishandle(h) || ...
                isempty(getListeners(ax))
            if ishandle(ax) % TODO: really needed? hgload
                reclaimSpace(ax,[]);
            end
            return;
        end
        hax = handle(ax);

        list = getappdata(ax,'LegendColorbarOuterList');
        list(~ishandle(list)) = [];
        isouter = list == handle(h);
        if any(isouter)
            list(isouter) = [];
            reclaimSpace(ax,list);
        end
        setappdata(hax,'LegendColorbarOuterList',list)
        list2 = getappdata(ax,'LegendColorbarInnerList');
        list2(~ishandle(list2)) = [];
        list2(list2 == handle(h)) = [];
        setappdata(hax,'LegendColorbarInnerList',list2)

    case 'addToLayoutList'
        h = varargin{1};
        if isempty(ax) || ~ishandle(ax) || ...
                isempty(h) || ~ishandle(h) || ...
                isempty(getListeners(ax))
            return;
        end
        hax = handle(ax);

        hh = handle(h);
        location = get(h,'Location');
        if strcmp(location,'BestOutside')
            location = calculate_best_outside(h);
        end
        if strncmp(fliplr(location),'edistuO',7)
            list = getappdata(ax,'LegendColorbarOuterList');
            list(~ishandle(list)) = [];
            if any(list == hh), return; end
            if isempty(list), initInsetAppdata(ax); end
            list = [hh;list];
            setappdata(hax,'LegendColorbarOuterList',list)
            makeSpace(ax,hh,location);
        elseif ~strcmp(location,'none') && ~strcmp(location,'manual')
            if strcmp(location,'Best')
                doBestLegendLayout(ax,h);
            end
            list = getappdata(ax,'LegendColorbarInnerList');
            list(~ishandle(list)) = [];
            if any(list == hh), return; end
            list = [hh;list];
            setappdata(hax,'LegendColorbarInnerList',list)
        end

    case 'resetOuterLayout'
        if isempty(ax) || ~ishandle(ax) || ...
                isempty(getListeners(ax))
            if nargin > 2 && ishandle(ax) && strcmp(varargin{1},'force')
                reclaimSpace(ax,[]);
            end
            return;
        end
        list = getappdata(ax,'LegendColorbarOuterList');
        list(~ishandle(list)) = [];
        if ~isempty(list)
            reclaimSpace(ax,list);
        end

    case 'layoutNoPixelBounds'
        doLayout(double(ax),false);

end

%----------------------------------------------------------------%
% Create the instance properties to hold handle layout lists
function initProperties(hax)
% list is stored on the axis as non-serializable instance property
if ~isappdata(hax,'LegendColorbarInnerList')
    setappdata(hax,'LegendColorbarInnerList',[]);
end
% list is stored on the axis as non-serializable instance property
if ~isappdata(hax,'LegendColorbarOuterList')
    setappdata(hax,'LegendColorbarOuterList',[]);
end

%----------------------------------------------------------------%
% Initialize the layout appdata for the original insets and size
function initInsetAppdata(ax)
loose = offsetsInUnits(ax,get(ax,'LooseInset'),get(ax,'Units'),'normalized');
fig = ancestor(ax,'figure');
par = get(ax,'Parent');
fpos = hgconvertunits(fig,get(par,'Position'),get(par,'Units'),'points',...
    get(par,'Parent'));
setappdata(ax,'LegendColorbarOriginalInset',loose);
setappdata(ax,'LegendColorbarOriginalSize',fpos);

%needed for SP2 hgload
setappdata(ax,'LegendColorbarLayoutDirty',[]);
setappdata(ax,'inLayout',[]);


%----------------------------------------------------------------%
% Get peer axis listeners, if any
function res = getListeners(ax)
res = [];
hax = handle(ax);
if ~isempty(findprop(hax,'LegendColorbarListeners'))
    res = get(hax,'LegendColorbarListeners');
end

%----------------------------------------------------------------%
% Remove peer axis listeners, if any
function rmListeners(ax)
hax = handle(ax);
if ~isempty(hax) && ~isempty(findprop(hax,'LegendColorbarListeners'))
    set(get(hax,'LegendColorbarListeners'),'enable','off')
    set(hax,'LegendColorbarListeners',[]);
end

%----------------------------------------------------------------%
function list = createListeners(ax)
t = findobj(allchild(ax),'flat','Tag','LegendColorbarLayout');
if length(t) ~= 2
    t1 = text(0,0,' ','Parent',ax,'Units','normalized',...
        'HorizontalAlignment','center',...
        'VerticalAlignment','middle',...
        'HandleVisibility','off','Visible','on','HitTest','off',...
        'Tag','LegendColorbarLayout',...
        'DeleteFcn','legendcolorbarlayout(get(gcbo,''Parent''),''remove'')',...
        'BackgroundColor','none');
    t2 = text(1,1,' ','Parent',ax,'Units','normalized',...
        'HorizontalAlignment','center',...
        'VerticalAlignment','middle',...
        'Tag','LegendColorbarLayout',...
        'HandleVisibility','off','Visible','on','HitTest','off',...
        'BackgroundColor','none');
else
    t1 = t(1);
    t2 = t(2);
    if any(get(t1,'Position') > .1)
        [t1,t2] = deal(t2,t1);
    end
end
t = [t1 t2];
setappdata(ax,'LegendColorbarText',t);
hax = handle(ax);

parent = get(ax,'Parent');
initProperties(hax);
ht1 = handle(t1);
ht2 = handle(t2);

list = handle.listener([ht1 ht2],findprop(ht1,'PixelBounds'),...
    'PropertyPostSet',@doPixelBoundsCB);
list(end+1) = handle.listener([ht1 ht2],findprop(ht1,'Visible'),...
    'PropertyPostSet',@doTextVisibleCB);
list(end+1) = handle.listener(handle(parent),'ResizeEvent',...
    @doParentResize);

% Listen to the "String" properties of the Title, XLabel and YLabel:
xLab = handle(get(hax,'XLabel'));
yLab = handle(get(hax,'YLabel'));
titleLab = handle(get(hax,'Title'));
hProps = [findprop(xLab,'String');findprop(xLab,'FontSize');...
    findprop(xLab,'FontName');findprop(xLab,'Position')];
list(end+1) = handle.listener([xLab yLab titleLab],hProps,...
    'PropertyPostSet',{@doLayoutCB,hax});

% We should also listen to the "XAxisLocation" and "YAxisLocation"
% properties of the axes:
hProps = [findprop(hax,'XAxisLocation');findprop(hax,'YAxisLocation')];
list(end+1) = handle.listener(hax,hProps,'PropertyPostSet',@(obj,evd)(doLayout(ax)));

% Also need to listen to the "Position" property of the axes
list(end+1) = handle.listener(hax,findprop(hax,'Position'),'PropertyPostSet','');
set(list(end),'Callback',{@localChangePosition,list(end)});

% listeners are stored on the axis as non-serializable instance property
if isempty(findprop(hax,'LegendColorbarListeners'))
    prop = schema.prop(hax,'LegendColorbarListeners','handle vector');
    prop.AccessFlags.Serialize = 'off';
    prop.Visible = 'off';
end
set(hax,'LegendColorbarListeners',list)

%----------------------------------------------------------------%
function localChangePosition(obj,evd,list) %#ok<INUSL>
% When the position of the axes changes, update the expected Axes position
% if the change was a result of the subplot layout manager.

hAx = double(evd.AffectedObject);
% If we are in manual layout mode, remove the listener
if isappdata(hAx,'LegendColorbarManualSpace')
    allList = getappdata(hAx,'LegendColorbarListeners');
    allList(allList == list) = [];
    setappdata(hAx,'LegendColorbarListeners',allList);
end
if isappdata(hAx,'InSubplotLayout')
    setappdata(hAx,'LegendColorbarExpectedPosition',evd.NewValue);
end

%----------------------------------------------------------------%
function doLayoutCB(obj,evd,hax) %#ok
% Does the legend/colorbar layout to account for XLabel and YLabel
hObj = evd.AffectedObject;

% DIsable tex/latex warnings to prevent too much information being
% output to the command window
warnState = warning('off','MATLAB:tex');
warnState(2) = warning('off','MATLAB:gui:latexsup:BadTeXString');

% Short circuit if we are in the process of reclaiming space
if isappdata(double(hax),'LegendColorbarReclaimSpace')
    warning(warnState);
    return;
end

% Short circuit if the label has been thrown into "Manual" mode or the user
% has manually specified the label. The "CachedPosition" property is
% temporary and will go away in a future release as there will be a
% "PositionMode" property on the text object.
if ~isprop(hObj,'CachedPosition') || ...
        ~isequal(get(hObj,'CachedPosition'),get(hObj,'Position'))
    if isappdata(double(hObj),'LegendColorbarLayoutTextMode')
        warning(warnState);
        return;
    else
        setappdata(double(hObj),'LegendColorbarLayoutTextMode','manual');
    end
else
    if isappdata(double(hObj),'LegendColorbarLayoutTextMode')
        rmappdata(double(hObj),'LegendColorbarLayoutTextMode');
    end
end

doLayout(double(hax));

% Restore tex/latex warnings which were disabled at the beginning of this
% function
warning(warnState);

%----------------------------------------------------------------%
% Callback when the parent of the legends/colorbar is resized.
% The behavior is to reposition the data axes to make space for
% the legends/colorbar outside the plot box.
function doParentResize(hSrc,eventdata) %#ok
child = allchild(double(hSrc));
ppos = get(hSrc,'Position');
if any(isnan(ppos)) || any(ppos(3:4) <= 0)
    return;
end
par = double(hSrc);
fig = ancestor(par,'figure');
ppos = hgconvertunits(fig,ppos,get(par,'Units'),'points',get(par,'Parent'));
for k=1:length(child)
    ch = child(k);
    if strcmp(get(ch,'type'),'axes')
        if isappdata(ch,'LegendColorbarText') && ...
                isappdata(ch,'LegendColorbarInnerList')
            setappdata(ch,'LegendColorbarOriginalSize',ppos);
            if strcmp(get(ch,'ActivePositionProperty'),'outerposition')
                legendcolorbarlayout(ch,'resetOuterLayout');
            end
            doLayout(ch);
        end
    end
end

%----------------------------------------------------------------%
% Check to make sure someone isn't turning our text objects invisible
% since that stops the PixelBounds updating
function doTextVisibleCB(hSrc,eventdata) %#ok
obj = double(eventdata.affectedObject); % a text object
if strcmp(eventdata.newValue,'off')
    set(obj,'Visible','on');
end

%----------------------------------------------------------------%
% Layout objects on the inside of the plot box based on text
% object PixelBounds
function doPixelBoundsCB(hSrc,eventdata) %#ok
obj = double(eventdata.affectedObject); % a text object
% only redo layout if pixel bounds changed by more than a pixel since
% axis bounds can bounce around by a pixel due to rounding
oldpixbounds = getappdata(obj,'LegendColorbarLayoutPixBounds');
if isempty(oldpixbounds) || any(abs(eventdata.newValue-oldpixbounds) > 1)
    setappdata(obj,'LegendColorbarLayoutPixBounds',eventdata.newValue);
    doLayout(get(obj,'Parent'));
end

%----------------------------------------------------------------%
% Convert pixels to points
function vals=toPoints(vals,fig)
vals = hgconvertunits(fig,[0 0 vals],'pixels','points',fig);
vals = vals(3:4);

%----------------------------------------------------------------%
function localValidateLists(hAx)
% Given an axes, make sure that the handles stored on the appdata are peers
% of the axes and not cruft from a copy.

hAx = handle(hAx);
outlist = getappdata(double(hAx),'LegendColorbarOuterList');
outlist(~ishandle(outlist)) = [];
if ~isempty(outlist)
    axList = get(outlist,'Axes');
    if iscell(axList)
        axList = cell2mat(axList);
    end
    outlist(axList~=hAx) = [];
    setappdata(double(hAx),'LegendColorbarOuterList',outlist);
end
inlist = getappdata(double(hAx),'LegendColorbarInnerList');
inlist(~ishandle(inlist)) = [];
if ~isempty(inlist)
    axList = get(inlist,'Axes');
    if iscell(axList)
        axList = cell2mat(axList);
    end
    inlist(axList~=hAx) = [];
    setappdata(double(hAx),'LegendColorbarInnerList',inlist);
end

%----------------------------------------------------------------%
% If the reference text objects are valid layout inner and outer
% legends and colorbars around the plot box. The flag withPixBounds
% indicates if the PixelBounds property should be used.
function doLayout(ax,withPixBounds)
textObjects = getappdata(double(ax),'LegendColorbarText');
localValidateLists(ax);
if validateTextObjects(textObjects,ax)
    if nargin == 1, withPixBounds = true; end
    outlist = getappdata(ax,'LegendColorbarOuterList');
    inlist = getappdata(ax,'LegendColorbarInnerList');
    if ~isempty(inlist) || ~isempty(outlist)
        listenerlist = getListeners(ax);
        oldstate = get(listenerlist,'enable');
        set(listenerlist,'enable','off')
        oldlayout = getappdata(ax,'inLayout');
        setappdata(ax,'inLayout',true);

        textObjects = getappdata(ax,'LegendColorbarText');
        par = get(ax,'Parent');
        fig = par;
        if ~strcmp(get(fig,'Type'),'figure')
            fig = ancestor(fig,'figure');
        end
        if is2D(ax)
            [corner1,corner2] = getPixelBounds(ax,textObjects,withPixBounds);
            corner1 = toPoints((corner1(1:2)+corner1(3:4))/2,fig);
            corner2 = toPoints((corner2(1:2)+corner2(3:4))/2,fig);
        else
            pixpos = getpixelposition(ax,true);
            corner1 = toPoints(pixpos(1:2),fig);
            corner2 = toPoints(pixpos(1:2) + pixpos(3:4),fig);
            % flip y direction for screen orientation
            figpos = hgconvertunits(fig,get(fig,'Position'),get(fig,'Units'),...
                'points',0);
            corner1(2) = figpos(4)-corner1(2);
            corner2(2) = figpos(4)-corner2(2);
        end

        if ~isempty(inlist)
            doInOutLayout(par,fig,inlist,corner1,corner2,true);
        end
        if ~isempty(outlist)
            doInOutLayout(par,fig,outlist,corner1,corner2,false);
        end

        % cache the position for the legend pre-get listener
        axPos = get(ax,'Position');
        setappdata(ax,'LegendComputePosCache',axPos);

        setappdata(ax,'inLayout',oldlayout);
        set(listenerlist,{'enable'},oldstate)
    end
end

%----------------------------------------------------------------%
% Place colorbars and legends that are inside or outside the plot box in the right
% positions relative to the PixelBounds of the plot box corners.
function doInOutLayout(par,fig,list,corner1,corner2,inner)
if inner
    corner1 = corner1+[5 -5];
    corner2 = corner2+[-5 5];
    corners = [corner1 ; corner2];
    origc = corners;
else
    % could use TightInsets here but then the legend/colorbars bounce too much
    % during rotating/panning etc so instead use a fixed offset.
    origc = [corner1 ; corner2];
    corner1 = corner1-[10 -10];
    corner2 = corner2-[-10 10];
    corners = [corner1 ; corner2];
end
for k=1:length(list)
    obj = list(k);
    if ~ishandle(obj), continue; end
    location = get(obj,'Location');
    if strcmp(location,'BestOutside')
        location = calculate_best_outside(obj);
    end
    if strcmp(location,'Best')
        pos = getappdata(double(obj),'LegendBestLocation');
        ax = get(obj,'Axes');
        axpos = get(ax,'Position');
        axpos = hgconvertunits(fig,axpos,get(ax,'Units'),'normalized',par);
        pos = axpos(1:2) + pos.*axpos(3:4);
        pos = hgconvertunits(fig,[pos 0 0],'normalized',get(obj,'Units'),par);
        oldpos = get(obj,'Position');
        set(obj,'Position',[pos(1:2) oldpos(3:4)]);
        continue;
    end
    oldpos = get(obj,'Position');
    oldpos = hgconvertunits(fig,oldpos,get(obj,'Units'),'points', par);
    if isa(obj,'scribe.legend')
        siz_norm = methods(handle(obj),'getsize');
        if ~all(isfinite(siz_norm))
            continue;
        end
        siz_point =  hgconvertunits(fig,[0 0 siz_norm],'normalized','points',par);
        [newpos,corners] = layoutLegend(location,corners,origc,siz_point(3:4),inner);
    else
        [newpos,corners] = layoutColorbar(location,corners,origc);
    end
    fpos = getpixelposition(fig);
    fpos = hgconvertunits(fig,fpos,'pixels','points',fig);
    newpos(2) = fpos(4) - newpos(2);
    if par ~= fig
        parpos = getpixelposition(par,true);
        parpos = hgconvertunits(fig,parpos,'pixels','points',get(par,'Parent'));
        newpos(1:2) = newpos(1:2) - parpos(1:2);
    end
    if any(abs(newpos(1:2)-oldpos(1:2))>2) || ...
            any(abs(newpos(1:2)+newpos(3:4)-oldpos(1:2)-oldpos(3:4))>2)
        newpos =  hgconvertunits(fig,newpos,'points',get(obj,'Units'),par);
        % In order to ensure that the computations are correct, keep track
        % of the location of the object and the x and y axes.
        ind = location_to_xy_index(location);
        x = ind(1);
        y = ind(2);
        xAxisLoc = get(obj.Axes,'XAxisLocation');
        yAxisLoc = get(obj.Axes,'YAxisLocation');
        if ~any(isnan(newpos)) && all(newpos(3:4) > 0)
            % If we had to shift the computations based on the XLabel and
            % YLabel, make sure to shift the objects back:
            if ~isa(obj,'scribe.legend')
                if x ~= 3 %Anything except North* and South*
                    labPos = localGetXLabelHeight(obj.Axes,obj.Units);
                    if strcmpi(xAxisLoc,'Bottom')
                        newpos(2) = newpos(2) + labPos;
                    end
                    newpos(4) = newpos(4) - labPos;
                    labPos = localGetTitleHeight(obj.Axes,obj.Units);
                    newpos(4) = newpos(4) - labPos;
                elseif x == 3 % North* and South*
                    labPos = localGetYLabelWidth(obj.Axes,obj.Units);
                    if strcmpi(yAxisLoc,'Left')
                        newpos(1) = newpos(1) + labPos;
                    end
                    newpos(3) = newpos(3) - labPos;
                end
                if strcmpi(xAxisLoc,'Bottom')
                    if (x == 3) && (y == 4) % South
                        labPos = localGetXLabelHeight(obj.Axes,obj.Units);
                        newpos(2) = newpos(2) + labPos;
                    end
                else
                    if (x == 3) && (y  == 2)  % North
                        labPos = localGetXLabelHeight(obj.Axes,obj.Units);
                        newpos(2) = newpos(2) - labPos;
                    end
                end
                if strcmpi(yAxisLoc,'Left')
                    if (x == 2) && (y == 3) % West
                        labPos = localGetYLabelWidth(obj.Axes,obj.Units);
                        newpos(1) = newpos(1) + labPos;
                    end
                else
                    if (x == 4) && (y == 3) % East
                        labPos = localGetYLabelWidth(obj.Axes,obj.Units);
                        newpos(1) = newpos(1) - labPos;
                    end
                end
                if (x == 3) && (y == 2) % North
                    labPos = localGetTitleHeight(obj.Axes,obj.Units);
                    newpos(2) = newpos(2) - labPos;
                end
            else
                % Legends have a preferred width (not mirroring the axes), so
                % we need to do a bit more work.
                if strcmpi(yAxisLoc,'Left')
                    if x == 2 % Anything West and Inside
                        labPos = localGetYLabelWidth(obj.Axes,obj.Units);
                        newpos(1) = newpos(1) + labPos;
                    end
                else
                    if x == 4 % Anything East and Inside
                        labPos = localGetYLabelWidth(obj.Axes,obj.Units);
                        newpos(1) = newpos(1) - labPos;
                    end
                end
                if y == 3 % East or West
                    labPos = localGetXLabelHeight(obj.Axes,obj.Units);
                    % Divide by two because we want to move the center down.
                    if strcmpi(xAxisLoc,'Bottom')
                        newpos(2) = newpos(2) + labPos/2;
                    else
                        newpos(2) = newpos(2) - labPos/2;
                    end
                    labPos = localGetTitleHeight(obj.Axes,obj.Units);
                    newpos(2) = newpos(2) - labPos/2;
                end
                if (x == 3) && ((y == 2) || (y == 4)) % North or South
                    labPos = localGetYLabelWidth(obj.Axes,obj.Units);
                    if strcmpi(yAxisLoc,'Left')
                        % Divide by two because we want to move the center over.
                        newpos(1) = newpos(1) + labPos/2;
                    else
                        % Divide by two because we want to move the center over.
                        newpos(1) = newpos(1) - labPos/2;
                    end
                end
                if y == 2 % Anything North, but not Outside
                    labPos = localGetTitleHeight(obj.Axes,obj.Units);
                    newpos(2) = newpos(2) - labPos;
                end
                if strcmpi(xAxisLoc,'Bottom')
                    if y == 4 % Anything South, but not Outside
                        labPos = localGetXLabelHeight(obj.Axes,obj.Units);
                        newpos(2) = newpos(2) + labPos;
                    end
                else
                    if y == 2 % Anything North, but not Outside
                        labPos = localGetXLabelHeight(obj.Axes,obj.Units);
                        newpos(2) = newpos(2) - labPos;
                    end
                end
                if (x == 3) && ((y == 1) || (y == 5)) % North or South Outside
                    labPos = localGetYLabelWidth(obj.Axes,obj.Units);
                    if strcmpi(yAxisLoc,'Left')
                        % Divide by two because we want to move the center over.
                        newpos(1) = newpos(1) + labPos/2;
                    else
                        % Divide by two because we want to move the center over.
                        newpos(1) = newpos(1) - labPos/2;
                    end
                end
            end
            set(obj,'Position',newpos);
        end
    end
end

%----------------------------------------------------------------%
% Get the plot box pixel bounds using the reference text objects
% The withPixelBounds flag indicates if the PixelBounds property
% should be used or topixels should be called.
function [corner1,corner2] = getPixelBounds(ax,textObjects,withPixBounds)
corner1 = get(textObjects(1),'PixelBounds');
corner2 = get(textObjects(2),'PixelBounds');
if ~withPixBounds || all(corner1 == 0) || all(corner2 == 0)
    opos = get(textObjects,'Position');
    set(textObjects,'Units','data');
    corner1 = get(textObjects(1),'Position');
    corner2 = get(textObjects(2),'Position');
    p = topixels(ax,[corner1; corner2]);
    set(textObjects,'Units','normalized');
    set(textObjects,{'Position'},opos);
    corner1 = [p(1,:) p(1,:)];
    corner2 = [p(2,:) p(2,:)];
end

% The text objects do not take the XLabel or YLabels into account. Add an
% offset for the X-Label and Y-Label for the bottom left corner.
leftChange = localGetYLabelWidth(ax,'Pixels');
% If the Y-axis is on the right, change the top right corner
if strcmpi(get(ax,'YAxisLocation'),'Right')
    corner2(1) = corner2(1) + leftChange;
    corner2(3) = corner2(3) + leftChange;
else % Otherwise change the bottom left corner
    corner1(1) = corner1(1) - leftChange;
    corner1(3) = corner1(3) - leftChange;
end
bottomChange = localGetXLabelHeight(ax,'Pixels');
% If the X-axis is on top, change the top right corner
if strcmpi(get(ax,'XAxisLocation'),'Top')
    corner2(2) = corner2(2) - bottomChange;
    corner2(4) = corner2(4) - bottomChange;
else % Otherwise change the bottom left corner
    corner1(2) = corner1(2) + bottomChange;
    corner1(4) = corner1(4) + bottomChange;
end
% We also need to deal with titles;
topChange = localGetTitleHeight(ax,'Pixels');
corner2(2) = corner2(2) - topChange;
corner2(4) = corner2(4) - topChange;

%----------------------------------------------------------------%
function height = localGetXLabelHeight(ax,units)
% Returns the height (in the units specified) of an axes XLabel.

% If we are not a 2-D axes, return early
if ~is2D(ax)
    height = 0;
    return;
end

xLab = get(ax,'XLabel');

% If there is no string, the height is 0
if isempty(get(xLab,'String'))
    height = 0;
    return;
end
% If the label is in "manual" mode, don't use it in computations:
if ~isprop(xLab,'CachedPosition') || ...
        ~isequal(get(xLab,'CachedPosition'),get(xLab,'Position'))
    height = 0;
    return;
end
pixBounds = get(xLab,'PixelBounds');
bottomChange = pixBounds(4) - pixBounds(2);
hFig = ancestor(ax,'Figure');
height = hgconvertunits(hFig,[0 0 0 bottomChange],'Pixels',units,get(ax,'Parent'));
height = height(4);

%----------------------------------------------------------------%
function height = localGetTitleHeight(ax,units)
% Returns the height (in the units specified) of an axes Title.

% If we are not a 2-D axes, return early
if ~is2D(ax)
    height = 0;
    return;
end

titleLab = get(ax,'Title');
if isempty(get(titleLab,'String'))
    height = 0;
    return;
end
% If the label is in "manual" mode, don't use it in computations:
if ~isprop(titleLab,'CachedPosition') || ...
        ~isequal(get(titleLab,'CachedPosition'),get(titleLab,'Position'))
    height = 0;
    return;
end
pixBounds = get(titleLab,'PixelBounds');
bottomChange = pixBounds(4) - pixBounds(2);
hFig = ancestor(ax,'Figure');
height = hgconvertunits(hFig,[0 0 0 bottomChange],'Pixels',units,get(ax,'Parent'));
height = height(4);

%----------------------------------------------------------------%
function width = localGetYLabelWidth(ax,units)
% Returns the height (in the units specified) of an axes YLabel.

% If we are not a 2-D axes, return early
if ~is2D(ax)
    width = 0;
    return;
end

yLab = get(ax,'YLabel');
if isempty(get(yLab,'String'))
    width = 0;
    return;
end
% If the label is in "manual" mode, don't use it in computations:
if ~isprop(yLab,'CachedPosition') || ...
        ~isequal(get(yLab,'CachedPosition'),get(yLab,'Position'))
    width = 0;
    return;
end
pixBounds = get(yLab,'PixelBounds');
% Add a small offset to keep things nice
leftChange = pixBounds(3) - pixBounds(1) + 10;
hFig = ancestor(ax,'Figure');
width = hgconvertunits(hFig,[0 0 leftChange 0],'Pixels',units,get(ax,'Parent'));
width = width(3);

%----------------------------------------------------------------%
% Layout a legend inside or outside axes and update bounds.
% pos is in points, returns newpos in points. Note coordinate system
% is flipped from HG (due to pixelbounds)
function [newpos,corners] = layoutLegend(location,corners,origc,legsize,inner)
xyind = location_to_xy_index(location);
switch xyind(1)
    case 1
        newpos(1) = corners(1,1)-legsize(1);
        corners(1,1) = newpos(1);
    case 2
        newpos(1) = corners(1,1);
        if xyind(2) == 3
            corners(1,1) = corners(1,1)+legsize(1);
        end
    case 3
        newpos(1) = (corners(1,1) + corners(2,1))/2 - legsize(1)/2;
    case 4
        newpos(1) = corners(2,1)-legsize(1);
        if xyind(2) == 3
            corners(2,1) = corners(2,1)-legsize(1);
        end
    case 5
        newpos(1) = corners(2,1);
        corners(2,1) = corners(2,1)+legsize(1);
end
switch xyind(2)
    case 1
        newpos(2) = corners(2,2);
        if xyind(1) == 3
            corners(2,2) = newpos(2)-legsize(2);
        end
    case 2
        if inner
            newpos(2) = corners(2,2)+legsize(2);
            if xyind(1) == 3
                corners(2,2) = corners(2,2)+legsize(2);
            end
        else
            newpos(2) = origc(2,2)+legsize(2);
        end
    case 3
        newpos(2) = (corners(1,2) + corners(2,2))/2 + legsize(2)/2;
    case 4
        if inner
            newpos(2) = corners(1,2);
            if xyind(1) == 3
                corners(1,2) = corners(1,2)-legsize(2);
            end
        else
            newpos(2) = origc(1,2);
        end
    case 5
        newpos(2) = corners(1,2)+legsize(2);
        if xyind(1) == 3
            corners(1,2) = newpos(2);
        end
end
newpos(3:4) = legsize;

%----------------------------------------------------------------%
% Compute the preferred colorbar Position width and height. See
% also makeSpace for preferred colorbar spacing.
function [width,height] = preferredColorbarSize(corners)
width = (corners(2,1)-corners(1,1))*.15;
height = (corners(1,2)-corners(2,2))*.15;
width = min(max(width,5),20);
height = min(max(height,5),20);

%----------------------------------------------------------------%
% layout colorbar. pos is in points, returns newpos in points
function [newpos,corners] = layoutColorbar(location,corners,origc)
[width,height]=preferredColorbarSize(origc);
% note 5 point inset on top of regular inset is for the tick label
% text overhanging the colorbar ends
switch location
    case 'East'
        newpos = [corners(2,1)-width origc(1,2)-5 width origc(1,2)-origc(2,2)-10];
        corners(2,1) = corners(2,1)-20-width;
    case 'West'
        newpos = [corners(1,1) origc(1,2)-5 width origc(1,2)-origc(2,2)-10];
        corners(1,1) = corners(1,1)+20+width;
    case 'North'
        newpos = [origc(1,1)+5 corners(2,2)+height origc(2,1)-origc(1,1)-10 height];
        corners(2,2) = corners(2,2)+10+height;
    case 'South'
        newpos = [origc(1,1)+5 corners(1,2)-5 origc(2,1)-origc(1,1)-10 height];
        corners(1,2) = corners(1,2)-10-height;
    case 'EastOutside'
        newpos = [corners(2,1)+5 origc(1,2) width origc(1,2)-origc(2,2)];
        corners(2,1) = corners(2,1)+20+width;
    case 'WestOutside'
        newpos = [corners(1,1)-5-width origc(1,2) width origc(1,2)-origc(2,2)];
        corners(1,1) = corners(1,1)-20-width;
    case 'NorthOutside'
        newpos = [origc(1,1) corners(2,2)-5 origc(2,1)-origc(1,1) height];
        corners(2,2) = corners(2,2)-10-height;
    case 'SouthOutside'
        newpos = [origc(1,1) corners(1,2)+5+height origc(2,1)-origc(1,1) height];
        corners(1,2) = corners(1,2)+10+height;
end

%----------------------------------------------------------------%
% Insert hh into the space taken up by ax in given location.
% The "space" is computed based on the OuterPosition of ax
% and the LooseInsets.
function makeSpace(ax,hh,location)

if isappdata(ax,'LegendColorbarManualSpace')
    % the user manually sized the peer axes so we don't modify that choice
    return;
end
active = get(ax,'ActivePositionProperty');
activePos = strcmp(active,'position');
pos = get(ax,active);
axunits = get(ax,'Units');
par = get(ax,'parent');
fig = par;
if ~strcmp(get(fig,'type'),'figure')
    fig = ancestor(par,'figure');
end
origpos = pos;
pos = hgconvertunits(fig,pos,axunits,'normalized',par);
if isa(hh,'scribe.legend')
    siz = methods(hh,'getsize');
    if ~all(isfinite(siz))
        return;
    end
else
    % see also preferredColorbarSize for sizing
    ppos = hgconvertunits(fig,origpos,axunits,'points',par);
    siz = min(max(ppos(3:4)*0.3,20),40);
    siz = hgconvertunits(fig,[0 0 siz],'points','normalized',par);
    siz = siz(3:4);
end
[newpos,fixedgap,side] = requestSpace(pos,siz,location);
oldlayout = getappdata(ax,'inLayout');
setappdata(ax,'inLayout',true);
oldSides = getappdata(ax,'LegendColorbarLayoutSides');
if ~isempty(oldSides) && any(oldSides & side)
    % there is already an item on this side so don't make extra space
    newpos = hgconvertunits(fig,newpos,'normalized',axunits,par);
else
    % this is the first item on this side so make extra space
    newpospts = hgconvertunits(fig,newpos,'normalized','points',par);
    newpospts = newpospts+fixedgap;
    newpos = hgconvertunits(fig,newpospts,'points',axunits,par);
    if isempty(oldSides)
        oldSides = side;
    else
        oldSides = oldSides | side;
    end
    setappdata(ax,'LegendColorbarLayoutSides',oldSides);
end
pos = hgconvertunits(fig,pos,'normalized',axunits,par);
loose = get(ax,'LooseInset');
% could use TightInsets here as well to give more space to data axes
if activePos
    op = getOuterFromPosAndLoose(pos,loose,axunits);
    actpos = newpos;
else
    op = get(ax,'OuterPosition');
    actpos = pos;
end
if strcmp(axunits,'normalized')
    loose = loose.*[op(3:4) op(3:4)];
end
diffs = newpos(1:2)-pos(1:2);
diffs = [diffs pos(3:4)-newpos(3:4)-diffs];
loose = loose+diffs;
if strcmp(axunits,'normalized')
    loose = loose./[op(3:4) op(3:4)];
end
loose = max(loose,[0 0 0 0]);
if ~any(isnan(actpos)) && all(actpos(3:4) > 0)
    set(ax,active,actpos,'LooseInset',loose)
    setappdata(ax,'LegendColorbarExpectedPosition',get(ax,'Position'));
end
setappdata(ax,'inLayout',oldlayout);

%----------------------------------------------------------------%
% Given a reference position and legend size and location return
% the updated reference position and requested legend position
function [op,fixedgap,side] = requestSpace(op, siz, location)
switch location
    case {'WestOutside','SouthWestOutside','NorthWestOutside'}
        op(1) = op(1)+siz(1);
        op(3) = op(3)-siz(1);
        fixedgap = [12 0 -12 0];
        side = [1 0 0 0];
    case {'EastOutside','SouthEastOutside','NorthEastOutside'}
        op(3) = op(3)-siz(1);
        fixedgap = [0 0 -12 0];
        side = [0 0 1 0];
    case 'SouthOutside'
        op(2) = op(2)+siz(2);
        op(4) = op(4)-siz(2);
        fixedgap = [0 12 0 -12];
        side = [0 1 0 0];
    case 'NorthOutside'
        op(4) = op(4)-siz(2);
        fixedgap = [0 0 0 -12];
        side = [0 0 0 1];
end
side = logical(side);

%----------------------------------------------------------------%
% Compute reference OuterPos from pos and loose. Note that
% loose insets are relative to outerposition
function outer = getOuterFromPosAndLoose(pos,loose,units)
if strcmp(units,'normalized')
    % compute outer width and height and normalize loose to them
    w = pos(3)/(1-loose(1)-loose(3));
    h = pos(4)/(1-loose(2)-loose(4));
    loose = [w h w h].*loose;
end
outer = [pos(1:2)-loose(1:2) pos(3:4)+loose(1:2)+loose(3:4)];

%----------------------------------------------------------------%
% give back space to data axes - Position or OuterPosition
% move others, too.
function reclaimSpace(ax,list)

if isappdata(ax,'LegendColorbarManualSpace')
    % the user manually sized the peer axes so we don't modify that choice
    return;
end

% Short circuit if we are in the process of reclaiming space
if isappdata(double(ax),'LegendColorbarReclaimSpace')
    return;
end

% Signal that we are doing some layout management.
setappdata(double(ax),'LegendColorbarReclaimSpace',true);
posprop = get(ax,'ActivePositionProperty');
inset = getappdata(ax,'LegendColorbarOriginalInset');
if isempty(inset)
    % during load the appdata might not be present
    inset = get(get(ax,'Parent'),'DefaultAxesLooseInset');
end
inset = offsetsInUnits(ax,inset,'normalized',get(ax,'Units'));
if strcmp(posprop,'outerposition')
    set(ax,'LooseInset',inset);
else
    pos = get(ax,'Position');
    % if someone positioned the axes by hand then don't resize it ever
    if isappdata(ax,'LegendColorbarExpectedPosition');
        expPos = getappdata(ax,'LegendColorbarExpectedPosition');
        if ~all(abs(expPos-pos) < eps(0))
            rmappdata(ax,'LegendColorbarExpectedPosition');
            setappdata(ax,'LegendColorbarManualSpace',1)
            rmappdata(double(ax),'LegendColorbarReclaimSpace');
            return;
        end
    end
    loose = get(ax,'LooseInset');
    opos = getOuterFromPosAndLoose(pos,loose,get(ax,'Units'));
    originset = inset;
    if strcmp(get(ax,'Units'),'normalized')
        inset = [opos(3:4) opos(3:4)].*inset;
    end
    pos = [opos(1:2)+inset(1:2) opos(3:4)-inset(1:2)-inset(3:4)];
    if ~any(isnan(pos)) && all(pos(3:4) > 0)
        set(ax,'Position',pos,'LooseInset',originset);
    end
end
setappdata(ax,'LegendColorbarLayoutSides',logical([0 0 0 0]));
if ~isempty(list)
    for k=1:length(list)
        obj = list(k);
        if ~ishandle(obj), continue; end
        location = get(obj,'Location');
        if strcmp(location,'BestOutside')
            location = calculate_best_outside(obj);
        end
        makeSpace(ax,obj,location);
    end
end
rmappdata(double(ax),'LegendColorbarReclaimSpace');

%----------------------------------------------------------------%
% Gets the best outside location for a given legend
function loc = calculate_best_outside(h)
if strcmp(get(h,'Orientation'),'vertical')
    loc = 'NorthEastOutside';
else
    loc = 'SouthOutside';
end

%----------------------------------------------------------------%
% translate location string to row,column number from top left
%
% 1 2    3   4  5
%  -------------
% 2|           |
%  |           |
% 3|           |
%  |           |
% 4|           |
%  -------------
% 5
function ind = location_to_xy_index(locstr)
persistent vals;
if isempty(vals)
    vals.NorthOutside = [3,1];
    vals.NorthWestOutside = [1,2];
    vals.NorthWest = [2,2];
    vals.North = [3,2];
    vals.NorthEast = [4,2];
    vals.NorthEastOutside = [5,2];
    vals.WestOutside = [1,3];
    vals.West = [2,3];
    vals.East = [4,3];
    vals.EastOutside = [5,3];
    vals.SouthWestOutside = [1,4];
    vals.SouthWest = [2,4];
    vals.South = [3,4];
    vals.SouthEast = [4,4];
    vals.SouthEastOutside = [5,4];
    vals.SouthOutside = [3,5];
    vals.BestOutside = [0,0];
    vals.none = [0,0];
    vals.manual = [0,0];
end
ind = vals.(locstr);

%----------------------------------------------------------------%
% return true if the helper text objects are valid and in the expected axes
% also restack axes in case the peer jumped in front of legends/colorbars
function out = validateTextObjects(textObjs,ax)
out = true;
if length(textObjs) ~= 2
    out = false;
elseif ~ishandle(textObjs(1)) || ~ishandle(textObjs(2))
    out = false;
else
    p = get(textObjs,'Parent');
    if p{1} ~= ax || p{2} ~= ax
        out = false;
    end
end
%also validate child order wrt peer axis and legends/colorbars
inlist = getappdata(ax,'LegendColorbarInnerList');
outlist = getappdata(ax,'LegendColorbarOuterList');
list = [inlist(:);outlist(:)].';
children = allchild(get(ax,'Parent'));
peerIndex = find(double(ax) == children);
needs_restack = false;
for ch=list
    ind = find(double(ch) == children);
    if ind > peerIndex
        children = [children(1:peerIndex-1);children(ind);...
            children(peerIndex:ind-1); ...
            children(ind+1:end)];
        peerIndex = peerIndex+1;
        needs_restack = true;
    end
end
if needs_restack
    set(get(ax,'Parent'),'Children',children);
end

%----------------------------------------------------------------%
% Resizes the legend when in manual mode if the legend
% is too small to accommodate its contents
function resizeManualLegend(h)
parent = get(h,'Parent');
fig = ancestor(h,'figure');
startLegPos = get(h,'Position');
startLegUnits = get(h,'Units');
% the minimum width and height to accommoate legend contents
minLegSize = methods(h,'getsize');
if ~all(isfinite(minLegSize)) || ~all(minLegSize > 0);
    return;
end

% convert to normalized units
normLegPos = hgconvertunits(fig,startLegPos,startLegUnits,'normalized',parent);
startLegSizeTooSmall = any(normLegPos(3:4) < minLegSize);
if startLegSizeTooSmall
    center = normLegPos(1:2) + normLegPos(3:4)/2;
    tmpLegPos = [(center - minLegSize/2) minLegSize];
    % convert back to original units
    newLegPos = hgconvertunits(fig, tmpLegPos, 'normalized', startLegUnits, parent);
    % temporarily disable listeners
    listen = h.PropertyListeners; 
    if ~isempty(listen)
        oldstate = get(listen, 'enable');
        set(listen, 'enable', 'off');
    end
    set(h, 'Position', newLegPos);
    if ~isempty(listen)
        set(listen, {'enable'}, oldstate);
    end    
end

%----------------------------------------------------------------%
% Positions the legend according to the 'best' location
function doBestLegendLayout(ax,h)
oldlayout = getappdata(ax,'inLayout');
setappdata(ax,'inLayout',true);
pos = methods(handle(h),'get_best_location');
if ~any(isnan(pos)) && all(pos(3:4) > 0)
    normpos = pos;
    pos = hgconvertunits(ancestor(ax,'figure'),pos,...
        'normalized',get(h,'Units'),get(ax,'Parent'));
    axpos = get(ax,'Position');
    fig = ancestor(ax,'figure');
    axpos = hgconvertunits(fig,axpos,get(ax,'Units'),'normalized',get(ax,'Parent'));
    bestpt = (normpos(1:2)-axpos(1:2))./axpos(3:4);
    setappdata(double(h),'LegendBestLocation',bestpt);
    set(h,'Position',pos);
end
setappdata(ax,'inLayout',oldlayout);

%----------------------------------------------------------------%
% Convert units of offsets like LooseInset or TightInset
function out = offsetsInUnits(ax,in,from,to)
fig = ancestor(ax,'figure');
par = get(ax,'Parent');
p1 = hgconvertunits(fig,[0 0 in(1:2)],from,to,par);
p2 = hgconvertunits(fig,[0 0 in(3:4)],from,to,par);
out = [p1(3:4) p2(3:4)];

%----------------------------------------------------------------%
%    topixels - Obtain the pixel coordinates given the data coords (vert)
function p = topixels(ax, vert)

if strcmp(get(ax,'XScale'),'log')
    if all(get(ax,'XLim') > 0)
        vert(:,1) = log10(vert(:,1));
    else
        vert(:,1) = -log10(-vert(:,1));
    end
end
if strcmp(get(ax,'YScale'),'log')
    if all(get(ax,'YLim') > 0)
        vert(:,2) = log10(vert(:,2));
    else
        vert(:,2) = -log10(-vert(:,2));
    end
end
if strcmp(get(ax,'ZScale'),'log')
    if all(get(ax,'ZLim') > 0)
        vert(:,3) = log10(vert(:,3));
    else
        vert(:,3) = -log10(-vert(:,3));
    end
end
% Get needed transforms
xform = get(ax,'x_RenderTransform');
offset = get(ax,'x_RenderOffset');
scale = get(ax,'x_RenderScale');

% Equivalent: nvert = vert/scale - offset;
nvert(:,1) = vert(:,1)./scale(1) - offset(1);
nvert(:,2) = vert(:,2)./scale(2) - offset(2);
nvert(:,3) = vert(:,3)./scale(3) - offset(3);

% Equivalent xvert = xform*xvert;
w = xform(4,1) * nvert(:,1) + xform(4,2) * nvert(:,2) + xform(4,3) * nvert(:,3) + xform(4,4);
xvert(:,1) = xform(1,1) * nvert(:,1) + xform(1,2) * nvert(:,2) + xform(1,3) * nvert(:,3) + xform(1,4);
xvert(:,2) = xform(2,1) * nvert(:,1) + xform(2,2) * nvert(:,2) + xform(2,3) * nvert(:,3) + xform(2,4);

% w may be 0 for perspective plots
ind = find(w==0);
w(ind) = 1; % avoid divide by zero warning
xvert(ind,:) = 0; % set pixel to 0

p(:,1) = xvert(:,1) ./ w;
p(:,2) = xvert(:,2) ./ w;
