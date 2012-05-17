function [hThis] = datatip(varargin)

%   Copyright 2002-2008 The MathWorks, Inc.

isDeserializing = false;

% Syntax: graphics.datatip(host,param1,val1,...)
if ishandle(varargin{1})
    host = varargin{1};
    varargin = {varargin{2:end}};

    % Syntax: graphics.datatip('Parent',hAxes) as called by hgload
elseif length(varargin)==2
    hAxes = varargin{2};
    host = hAxes;
    varargin = {varargin{3:end}};
    isDeserializing = true;
end

% Assign this object's parent
hAxes = ancestor(host,'axes');

% Constructor
hThis = graphics.datatip('Parent',hAxes);

% Create datacursor object which is used for
% vertex picking
hThis.DataCursorHandle = graphics.datacursor;

% Set serialization flag
set(hThis,'IsDeserializing',isDeserializing);

% Assign input host to this datatip
hThis.Host = handle(host);

% Add property listeners
localAddSelfListeners(hThis);

% Add listeners to host
localAddHostListeners(hThis);

% Create visual marker and text box
localCreateNewMarker(hThis);
localCreateNewTextBox(hThis);

visiblepropval = [];
set_orientation = true;

% Loop through and set specified properties
if nargin>1
    for n = 1:2:length(varargin)
        propname = varargin{n};
        propval = varargin{n+1};
        % Set the visible property at the end of this constructor
        % since the visible listener requires the datatip to
        % be fully initialized.
        if strcmpi(propname,'StringFcn')
            % Don't fire updatestring until at the end of the constructor
            set(hThis.SelfListenerHandles,'Enable','off');
            set(hThis,propname,propval);
            set(hThis.SelfListenerHandles,'Enable','on');
        elseif strcmpi(propname,'Visible')
            % Don't set visible property until at the end of the
            % constructor
            visiblepropval = propval;
        elseif strcmpi(propname,'Orientation') || ...
                strcmpi(propname,'OrientationMode')
            set_orientation = false;
        else
            set(hThis,propname,propval);
        end
    end
end

set(hThis.DataCursorHandle,'Target',host);

% Defensive code, datacursor defaults might change
set(hThis.DataCursorHandle,'Interpolate','off'); % datatip default
set(hThis,'UIContextMenu',get(host,'UIContextMenu'));

%Determine the value for the ZStackMinimum property
minZ(hThis,hAxes);

% Set datatip position and string
update(hThis);

movetofront(hThis);

% Update orientation property if necessary
if set_orientation
    set(hThis,'OrientationMode','manual');
end

% Finally, set the visible property if it was passed into the
% constructor
if ~isempty(visiblepropval)
    set(hThis,'Visible',visiblepropval)
end

%localDebug(hThis,'@datatip\datatip.m : end Datatip constructor');

% Do not allow user to edit datatip in plotedit mode
hBehavior = hggetbehavior(hThis,'Plotedit');
set(hBehavior,'EnableSelect',false);

% Complete with deserialization
%set(hThis,'IsDeserializing',false);

%-------------------------------------------------%
function [hMarker] = localCreateNewMarker(hThis,varargin)
% Create visual datatip marker
% Ignore varargin, required since used in callback

% This function is copied from Control Team's tipack

%localDebug(hThis,'@datatip\datatip.m : start localCreateNewMarker');

% Get axes and figure
hAxes = get(hThis,'HostAxes');
hFigure = ancestor(hAxes,'figure');

lprops = [];
lprops.Tag = 'DataTipMarker';
lprops.Xdata = [];
lprops.YData = [];
lprops.LineStyle = 'none';
lprops.Marker = hThis.Marker;
lprops.MarkerSize = hThis.MarkerSize;
lprops.MarkerFaceColor = hThis.MarkerFaceColor;
lprops.MarkerEdgeColor = hThis.MarkerEdgeColor;
lprops.LineWidth = 2;
lprops.HandleVisibility = 'off';
lprops.Clipping = 'off';
lprops.Parent = hThis;
lprops.Visible = hThis.Visible;
lprops.XLimInclude = 'off';
lprops.YLimInclude = 'off';
lprops.Serializable = hThis.Serializable;
% Don't allow the datatip to be involved in any coputations
lprops.IncludeRenderer = 'off';
lprops.XLimInclude = 'off';
lprops.YLimInclude = 'off';
lprops.ZLimInclude = 'off';

% get function handle for marker's ButtonDownFcn
down = startDrag(hThis);
lprops.ButtonDownFcn = {down,hThis,hFigure};


%hMarker = line('Visible','on');

hMarker = line(lprops);

% Work around for deserializing
set(hMarker,'CreateFcn','delete(gcbo)');

% Unregister from legend
hasbehavior(hMarker,'legend',false);

% Uncomment this code to get a cross hair marker inside a
% circle marker.
%lprops.Marker = '+';
%lprops.MarkerSize = 8;
%lprops.EraseMode = 'normal';
%lprops.MarkerEdgeColor = [1 1 1];
%hMarker(1,1) = line(lprops);

hThis.MarkerHandle = handle(hMarker);
hThis.MarkerHandleButtonDownFcn = hThis.MarkerHandle.ButtonDownFcn;

%localDebug(hThis,'@datatip\datatip.m : end localCreateNewMarker');

%-------------------------------------------------%
function [hTextBox] = localCreateNewTextBox(hThis,varargin)
% Create visual datatip marker
% Ignore varargin, required since used in callback

% This function is copied from Control Team's tipack

%localDebug(hThis,'@datatip\datatip.m : start localCreateNewTextBox');

hAxes = getaxes(hThis);
if isempty(hAxes)
    error('MATLAB:graphics:datatip:emptyAxes','Assert')
end

hFigure = ancestor(hAxes,'figure');

tprops.Tag = 'DataTipMarker';
tprops.Color = hThis.TextColor;
tprops.Margin = 4;
tprops.EdgeColor = hThis.EdgeColor;
tprops.LineStyle = '-' ;
tprops.BackgroundColor = hThis.BackgroundColor;
tprops.Position = [0 0];
tprops.String = 'error';
tprops.HorizontalAlignment = 'left';
tprops.VerticalAlignment = 'top';
tprops.Interpreter = 'none';
tprops.FontSize = hThis.FontSize;
tprops.HandleVisibility = 'off';
tprops.Clipping = 'off';
tprops.Parent = hThis;
tprops.Visible = hThis.Visible;
tprops.ButtonDownFcn = {@localTextBoxButtonDownFcn,hThis,hFigure};
tprops.Serializable = hThis.Serializable;

% Don't allow the datatip to be involved in any coputations
tprops.IncludeRenderer = 'off';
tprops.XLimInclude = 'off';
tprops.YLimInclude = 'off';
tprops.ZLimInclude = 'off';
hTextBox = text(tprops);

% Work around for deserializing
set(hTextBox,'CreateFcn','delete(gcbo)');

hThis.TextBoxHandle = handle(hTextBox);
hThis.TextBoxHandleButtonDownFcn = hThis.TextBoxHandle.ButtonDown;

%localDebug(hThis,'@datatip\datatip.m : end localCreateNewTextBox');

%-------------------------------------------------%
function localTextBoxButtonDownFcn(obj,evd,hThis,hFigure)
hThis.textBoxButtonDownFcn(obj,evd,hThis,hFigure);

%-------------------------------------------------%

function localAddSelfListeners(hThis)
% Add listeners for this datatip

%localDebug(hThis,'@datatip\datatip.m : start localAddSelfListeners');

l(1) = handle.listener(hThis,findprop(hThis,'String'),...
    'PropertyPostSet', {@localSetString});


% font stuff
p(1) = findprop(hThis,'FontAngle');
p(end+1) = findprop(hThis,'FontName');
p(end+1) = findprop(hThis,'FontSize');
p(end+1) = findprop(hThis,'FontUnits');
p(end+1) = findprop(hThis,'FontWeight');
p(end+1) = findprop(hThis,'TextBoxHandle');
p(end+1) = findprop(hThis,'EdgeColor');
p(end+1) = findprop(hThis,'TextColor');
p(end+1) = findprop(hThis,'BackgroundColor');
l(end+1) = handle.listener(hThis,p,'PropertyPostSet',...
    {@localSetFont});

% marker stuff
p2(1) = findprop(hThis,'Marker');
p2(end+1) = findprop(hThis,'MarkerSize');
p2(end+1) = findprop(hThis,'MarkerEdgeColor');
p2(end+1) = findprop(hThis,'MarkerFaceColor');
l(end+1) = handle.listener(hThis,p2,'PropertyPostSet',...
    {@localSetMarker});

l(end+1) = handle.listener(hThis,findprop(hThis,'Visible'),...
    'PropertyPostSet',{@localSetVisible});

l(end+1) = handle.listener(hThis,findprop(hThis,'StringFcn'),...
    'PropertyPostSet',{@localSetStringFcn});

l(end+1) = handle.listener(hThis,findprop(hThis,'Orientation'),...
    'PropertyPostSet',{@localSetOrientation});
hThis.OrientationPropertyListener = l(end);
l(end+1) = handle.listener(hThis,findprop(hThis,'OrientationMode'),...
    'PropertyPostSet',{@localSetOrientationMode});

l(end+1) = handle.listener(hThis,findprop(hThis,'Position'),...
    'PropertyPostSet',{@localSetPosition,hThis});

l(end+1) = handle.listener(hThis,findprop(hThis,'UIContextMenu'),...
    'PropertyPostSet',{@localSetUIContextMenu});

l(end+1) = handle.listener(hThis,findprop(hThis,'Host'),...
    'PropertyPostSet', {@localAddHostListeners});

l(end+1) = handle.listener(hThis,findprop(hThis,'Interpolate'),...
    'PropertyPostSet', {@localSetInterpolate});

% Clean up if datatip is deleted
l(end+1) = handle.listener(hThis,'ObjectBeingDestroyed',...
    {@localDestroy});

% Force first argument of all callbacks to hThis
set(l,'CallbackTarget',hThis);

% Store listeners
hThis.SelfListenerHandles = l;

%localDebug(hThis,'@datatip\datatip.m : end localAddSelfListeners');

%-------------------------------------------------%
function localAddHostListeners(hThis,varargin)
% Add listeners to the host and its parents
% varargin contains unused callback objects

%localDebug(hThis,'@datatip\datatip.m : start localAddHostListeners');

hHost = hThis.Host;
if ~ishandle(hHost)
    return;
end

hAxes = handle(getaxes(hThis));
hFigure = handle(ancestor(hAxes,'figure'));

% Cache information on whether the target has
% datatip methods so we don't have to make an
% expensive call to ISMETHOD during update events.
hDataCursorInfo = get(hThis,'DataCursor');
set(hDataCursorInfo,'Target',hHost);
if ismethod(hHost,'getDatatipText')
    set(hDataCursorInfo,'TargetHasGetDatatipTextMethod',true);
else
    set(hDataCursorInfo,'TargetHasGetDatatipTextMethod',false);
end

if ismethod(hHost,'updateDataCursor')
    set(hDataCursorInfo,'TargetHasUpdateDataCursorMethod',true);
else
    set(hDataCursorInfo,'TargetHasUpdateDataCursorMethod',false);
end

hBehavior = hggetbehavior(hHost,'DataCursor','-peek');
if ~isempty(hBehavior)
    fcn = get(hBehavior,'UpdateFcn');
    set(hDataCursorInfo,'UpdateFcnCache',fcn);
else
    set(hDataCursorInfo,'UpdateFcnCache',[]);
end

set(hThis,'HostAxes',hAxes);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Remove datatip if the host is deleted or reparented
l = handle.listener(hHost,'ObjectBeingDestroyed',@localDestroy);
l(end+1) = handle.listener(hHost,'ObjectParentChanged',@localDestroy);

% Update datatip if any host data property changes
host_prop = [ findprop(hHost,'XData'), ...
    findprop(hHost,'YData'), ...
    findprop(hHost,'ZData'), ...
    findprop(hHost,'CData')];
l(end+1) = handle.listener(hHost,host_prop,'PropertyPostSet',...
    @localHostDataUpdate);

% Update datatip visibility if host visibility changes
l(end+1) = handle.listener(hHost,findprop(hHost,'Visible'),...
    'PropertyPostSet',@localSetHostVisible);

% LISTEN TO AXES UPDATE
% This is a challenge because there are a variety of axes property and events
% to listen to but none of them fire at the correct time. For example,
% listening to AxesInvalidEvent doesn't fire late enough when doing
% zoom operations. This causes the text box to separate from the
% line marker. Listening to pixel bounds can cause race conditions (see
% g207403). The best compromise is to listen to tick changes which seem
% to fire to often.
axes_prop(1) = findprop(hAxes,'XTick');
axes_prop(2) = findprop(hAxes,'YTick');
axes_prop(3) = findprop(hAxes,'ZTick');
l(end+1) = handle.listener(hAxes,axes_prop, ...
    'PropertyPostSet',...
    @localAxesUpdate);

% Force first argument of all callbacks to hThis
set(l,'CallbackTarget',hThis);

% Store listeners
hThis.HostListenerHandles = l;

%localDebug(hThis,'@datatip\datatip.m : end localAddHostListeners');

%-------------------------------------------------%
function localSetHostVisible(hThis,hEventData)
% This gets called when the host visible property changes

%localDebug(hThis,'@datatip\datatip.m : start localHostSetVisible');

if strcmp(hEventData.NewValue,'on')
    % TBD: check a VisibleMode property
    set(hThis,'Visible','on');
    % There are scenarios where this may short-circuit. In order to ensure
    % proper visibiliy, we will manually update the visibility as well:
    localSetVisible(hThis,hEventData);
else
    set(hThis,'Visible','off');
    % There are scenarios where this may short-circuit. In order to ensure
    % proper visibiliy, we will manually update the visibility as well:    
    localSetVisible(hThis,hEventData);
end

%localDebug(hThis,'@datatip\datatip.m : end localHostSetVisible');

%-------------------------------------------------%
function localSetVisible(hThis,hEventData)
% This gets called when the datatip visible property changes

%localDebug(hThis,'@datatip\datatip.m : start localSetVisible',hEventData);

% Return early if no datacursor
if isempty(ishandle(hThis.DataCursorHandle)) || ...
        isempty(hThis.DataCursorHandle.Position)
    hThis.Visible = 'off';
    %localDebug(hThis,'@datatip\datatip.m : end localSetVisible','no data cursor');
    return;
end

hMarker = hThis.MarkerHandle;
hTextBox = hThis.TextBoxHandle;

if strcmp(hEventData.NewValue,'on')
    set(hMarker,'Visible','on');
    set(hTextBox,'Visible','on');
else
    set(hMarker,'Visible','off');
    set(hTextBox,'Visible','off');
end

% If the view style is "Marker", make sure not to show the text box.
if strcmpi(get(hThis,'ViewStyle'),'Marker')
    set(hTextBox,'Visible','off');
end

%localDebug(hThis,'@datatip\datatip.m : end localSetVisible');

%-------------------------------------------------%
function localSetOrientationMode(hThis,varargin)
% varargin contains unused callback objects

%localDebug(hThis,'@datatip\datatip.m : start localSetOrientationMode');

% If the datatip is not in an invalid state
if ~get(hThis,'Invalid')
    if strcmp(hThis.OrientationMode,'manual')
        % do nothing
    elseif strcmp(hThis.OrientationMode,'auto')
        localSetBestOrientation(hThis);
    end
end

%localDebug(hThis,'@datatip\datatip.m : end localSetOrientationMode');

%-------------------------------------------------%
function localSetBestOrientation(h)
% Finds the best orientation of the datatip based
% on location of axes.

%localDebug(h,'@datatip\datatip.m : start localSetBestOrientation');

set(h,'Invalid',true);
set(h.OrientationPropertyListener,'enabled','off');
h.Orientation = 'top-right';
localApplyCurrentOrientation(h);
set(h.OrientationPropertyListener,'enabled','on');
set(h,'Invalid',false);

% Portions of this implementation was taken from
% the Control's team tippack.

% Find initial text position in normalized units so we not to clip
% the axis. We have to juggle the units property in order to
% maintain data position.
orig_units = get(h.TextBoxHandle,'units');
set(h.TextBoxHandle,'Units','data');
PP = get(h.TextBoxHandle,'Position');
set(h.TextBoxHandle,'Units','normalized');
E = get(h.TextBoxHandle,'Extent');
set(h.TextBoxHandle,'Units','data');
set(h.TextBoxHandle,'Position',PP);
set(h.TextBoxHandle,'Units',orig_units);

hAxes = get(h,'HostAxes');
orig_units = get(hAxes,'Units');
set(hAxes,'units','normalized');
A = get(hAxes,'Position');
set(hAxes,'units',orig_units);

E13 = E(1)+E(3);
A13 = A(1)+A(3);
E24 = E(2)+E(4);
A24 = A(2)+A(4);

% If we are to the left of the axes, move datatip to the
% right side with alignment on the left.
if E13 < A13
    set(h.TextBoxHandle,'HorizontalAlignment','left');
end

% If we are to the right of the axes, move datatip to the
% left side with alignment on the left.
if E13 >= A13
    set(h.TextBoxHandle,'HorizontalAlignment','right');
end

% If we are below the axes, move the datatip to the
% top with alignment on the bottom.
if E24 < A24
    set(h.TextBoxHandle,'VerticalAlignment','bottom');
end

% If we are above the axes, move the datatip to the
% bottom with alignment on the top.
if E24 >= A24
    set(h.TextBoxHandle,'VerticalAlignment','top');
end

VA = get(h.TextBoxHandle,'VerticalAlignment');
HA = get(h.TextBoxHandle,'HorizontalAlignment');

if  strcmpi(VA,'top') && strcmpi(HA,'right')
    final_orientation = 'bottom-left';
elseif strcmpi(VA,'top') && strcmpi(HA,'left')
    final_orientation = 'bottom-right';
elseif strcmpi(VA,'bottom') && strcmpi(HA,'right')
    final_orientation = 'top-left';
elseif strcmpi(VA,'bottom') && strcmpi(HA,'left')
    final_orientation = 'top-right';
end

set(h.OrientationPropertyListener,'enabled','off');
h.Orientation = final_orientation;
localApplyCurrentOrientation(h);
set(h.OrientationPropertyListener,'enabled','on');

%localDebug(h,'@datatip\datatip.m : end localSetBestOrientation');

%-------------------------------------------------%
function localSetOrientation(hThis,varargin)
% varargin contains unused callback objects

%localDebug(hThis,'@datatip\datatip.m : start localSetOrientation');

% As with all hg objects, explicity setting the
% property will implicitly change the
% corresponding mode property from 'auto' to 'manual'
if strcmp(hThis.OrientationMode,'auto')
    hThis.OrientationMode = 'manual';
end
localApplyCurrentOrientation(hThis);

%localDebug(hThis,'@datatip\datatip.m : end localSetOrientation');

%-------------------------------------------------%
function localApplyCurrentOrientation(hThis)
% Determine low level text box properties based on
% high level datatip orientation property

%localDebug(hThis,'@datatip\datatip.m : start localApplyCurrentOrientation');
offset = hThis.PointsOffset;
orientation = hThis.Orientation;
rightOffset = 1.75;

% Update textbox low level properties
hText = hThis.TextBoxHandle;
orig_units = hText.Units;
points_pos = localGetDatatipPointsPosition(hThis);
hText.Units = 'points'; 
pos = get(hText,'Extent');
if strcmp(orientation,'top-left')
    points_offset = [rightOffset-offset(1)-pos(3), offset(2)];
    halignment = 'left';
    valignment = 'bottom';
elseif strcmp(orientation,'bottom-left')
    points_offset = [rightOffset-offset(1)-pos(3), 1-offset(2)];
    halignment = 'left';
    valignment = 'top';
elseif strcmp(orientation,'bottom-right')
    points_offset = [offset(1), 1-offset(2)];
    halignment = 'left';
    valignment = 'top';
elseif strcmp(orientation,'top-right')
    points_offset = [offset(1), offset(2)];
    halignment = 'left';
    valignment = 'bottom';
else
    error('MATLAB:graphics:datatip:invalidOrientation','Invalid orientation value')
end

hText.Position(1:2) = points_pos(1:2) + points_offset;
hText.HorizontalAlignment = halignment;
hText.VerticalAlignment = valignment;

set(hText,'Units',orig_units);
pos = get(hText,'Position');
set(hText,'position',pos);

%localDebug(hThis,'@datatip\datatip.m : end localApplyCurrentOrientation');

%-------------------------------------------------%
function localSetPosition(obj,evd,hThis)

new_position  = get(evd,'NewValue');

if ~ishandle(hThis)
    return;
end

% *Check for stale handles*
% The current datatip implementation is not very safe
% wrt stale handles. Moving the implementation to use a
% group object should fix most of these problems since
% deletion will be implicit.
hText = hThis.TextBoxHandle;
if ~isa(hText,'hg.text')
    return;
end

hMarker = hThis.MarkerHandle;
if ~isa(hMarker,'hg.line')
    return;
end

hDataCursor = hThis.DataCursorHandle;

% Return early if we are in an invalid state
if any(isempty(ishandle([hText,hMarker,hDataCursor]))) || ...
        isempty(hThis.Position) || ...
        ~isa(hDataCursor,'graphics.datacursor')
    return;
end

set(hDataCursor,'Position',new_position);
localUpdatePositionFromDataCursor(hThis);

%-------------------------------------------------%
function localUpdatePositionFromDataCursor(hThis)

if ~ishandle(hThis)
    return;
end

persistent was3D;

%localDebug(hThis,'@datatip\datatip.m : start localSetPosition');

% *Check for stale handles*
% The current datatip implementation is not very safe
% wrt stale handles. Moving the implementation to use a
% group object should fix most of these problems since
% deletion will be implicit.
hText = hThis.TextBoxHandle;
if ~isa(hText,'hg.text')
    return;
end

hMarker = hThis.MarkerHandle;
if ~isa(hMarker,'hg.line')
    return;
end

if isempty(was3D)
    was3D = ~is2D(get(hThis,'HostAxes'));
end

hDataCursor = hThis.DataCursorHandle;

% Return early if we are in an invalid state
if any(isempty(ishandle([hText,hMarker,hDataCursor]))) || ...
        isempty(hThis.Position) || ...
        ~isa(hDataCursor,'graphics.datacursor')
    return;
end

new_position = get(hDataCursor,'TargetPoint');
if isempty(new_position) || (get(hThis,'EnableZStacking') ...
        && is2D(get(hThis,'HostAxes')))
    new_position = get(hDataCursor,'Position');
end
set(hThis,'Position',new_position);
dm = hThis.DataManagerHandle;
if ~isempty(dm) & dm.CurrentDataCursor == hThis
    if is2D(get(hThis,'HostAxes'))
        if was3D
            movetofront(hThis);
            new_position = get(hThis,'Position');
            was3D = false;
        end
    else
        was3D = true;
    end
end
if isempty(new_position)
    % We should never get here
    error('MATLAB:graphics:datatip:emptyPosition','Assert')
end

% Update parent since this may be changing
% if we have subplots
hAxes = get(hThis,'HostAxes');
set(hThis,'Parent',hAxes);
set(hText,'Parent',hThis);
set(hMarker,'Parent',hThis);

% Set marker position
hMarker = hThis.MarkerHandle;
set(hMarker,'XData',new_position(1));
set(hMarker,'YData',new_position(2));
if length(new_position)>2
    set(hMarker,'ZData',new_position(3));
else
    set(hMarker,'ZData',[]);
end

% If orientation is in manual mode
if strcmp(hThis.OrientationMode,'manual')
    localApplyCurrentOrientation(hThis);
elseif strcmp(hThis.OrientationMode,'auto')
    localSetBestOrientation(hThis);
end

% If Z-Stacking is enabled
if ( get(hThis,'EnableZStacking') ...
        && is2D(get(hThis,'HostAxes')) ...
        && length(new_position)>2)
    set(hText,'units','data');
    pos = get(hText,'position');
    pos(3) = new_position(3);
    set(hText,'Position',pos);
end

%localDebug(hThis,'@datatip\datatip : end localSetPosition');

%-------------------------------------------------%
function localSetString(hThis,varargin)
% varargin contains unused callback objects

evd = varargin{1};

str = get(evd,'NewValue');
if ~ischar(str) && ~iscellstr(str)
    return
end

private_set_string(hThis,str);

%-------------------------------------------------%
function localAxesUpdate(hThis,varargin)
% This gets fired when the axes limits update

if isappdata(hThis.HostAxes,'datatip_fireDataTipUpdate')
    return;
end

hListeners = get(hThis,'HostListenerHandles');
if ishandle(hThis)
    % Update string and position of datatip
    set(hListeners,'Enabled','off');
    localUpdatePositionFromDataCursor(hThis);
    updatePositionAndString(hThis);
    set(hListeners,'Enable','on')
end

%-------------------------------------------------%
function localHostDataUpdate(hThis,varargin)
% The datatip's host object data has been updated.
% Therefore, update the datatip's position and data
% cursor so that the index and interpolation factor
% are preserved. If the original index goes beyond
% the new data, then delete the datatip altogether.

%localDebug(hThis,'@datatip\datatip.m : start localDataUpdate',varargin{:});

evd = varargin{1};
prop = evd.Source;

hHost = hThis.Host;
hAxes = get(hThis,'HostAxes');
hDataCursor = hThis.DataCursorHandle;
ind = hDataCursor.DataIndex;
pfactor = hDataCursor.InterpolationFactor;

if isempty(ind)
    % Delete datatip if we don't have an index to reference and
    % we are not deserializing (via hgload).
    if ~get(hThis,'IsDeserializing')
        delete(hThis);
    end
    return;
else
    % Eventually move this code into data cursor
    % interface. For now just handle 2-D line scenario.
    if isa(hHost,'hg.line') && is2D(hAxes);
        xdata = get(hHost,'xdata');
        ydata = get(hHost,'ydata');
        zdata = get(hHost,'zdata');
        % Check to see if we are in a bad state that is likely to get
        % rectified soon.
        if length(xdata) ~= length(ydata)
            return;
        end
        len = length(xdata);
        if len<=0
            delete(hThis);
            return;
        end
        if strcmpi(hThis.Interpolate,'off')
            if ind<=len
                pos(1) = xdata(ind);
                pos(2) = ydata(ind);
                if ~isempty(zdata)
                    pos(3) = zdata(ind);
                end
            else
                delete(hThis);
            end
        else
            if pfactor > 0 && ind>=len
                pos(1) = xdata(end);
                pos(2) = ydata(end);
                if ~isempty(zdata)
                    pos(3) = zdata(end);
                end
            elseif pfactor > 0 && ind+1 <= len
                pos(1) = xdata(ind) + pfactor*(xdata(ind+1)-xdata(ind));
                pos(2) = ydata(ind) + pfactor*(ydata(ind+1)-ydata(ind));
                if ~isempty(zdata)
                    pos(3) = zdata(ind) + pfactor*(zdata(ind+1)-zdata(ind));
                end
            elseif pfactor < 0 && ind <= len
                pos(1) = xdata(ind) + pfactor*(xdata(ind)-xdata(ind-1));
                pos(2) = ydata(ind) + pfactor*(ydata(ind)-ydata(ind-1));
                if ~isempty(zdata)
                    pos(3) = zdata(ind) + pfactor*(zdata(ind)-zdata(ind-1));
                end
            elseif pfactor == 0 && ind<=len
                pos(1) = xdata(ind);
                pos(2) = ydata(ind);
                if ~isempty(zdata)
                    pos(3) = zdata(ind);
                end
            else
                delete(hThis);
                return;
            end
        end
        hDataCursor.Position = pos;
        hDataCursor.TargetPoint = pos;
        % hThis.Position = pos;
        updatePositionAndString(hThis,hDataCursor);
        % There is a BUG HERE. The datatip does not appear
        % correctly when doing:
        %    h = plot(1:10);
        %    dt = graphics.datatip(h,'Visible','on');
        %    set(h,'xdata',1:2,'ydata',1:2);
    else
        % TBD, support all hg primitives and 3-D lines
        delete(hThis);
        return;
    end
end

%localDebug(hThis,'@datatip\datatip.m : end localDataUpdate');

%-------------------------------------------------%
function localInvalidate(hThis,varargin)
% varargin contains unused callback objects

%localDebug(hThis,'@datatip\datatip.m : localInvalidate');

hThis.Invalid = logical(1);
hThis.Visible = 'off';

%-------------------------------------------------%
function localSetUIContextMenu(hThis,varargin)
% varargin contains unused callback objects

%localDebug(hThis,'@datatip\datatip.m : localSetUIContextMenu');

h = hThis.MarkerHandle;
h(2) = hThis.TextBoxHandle;
set(h,'UIContextMenu',hThis.UIContextMenu);

%-------------------------------------------------%
function localSetFont(hThis,varargin)
% varargin contains unused callback objects

%localDebug(hThis,'@datatip\datatip.m : localSetFont');

hTextBox = hThis.TextBoxHandle;
hTextBox.FontAngle = hThis.FontAngle;
hTextBox.FontName = hThis.FontName;
hTextBox.FontSize = hThis.FontSize;
hTextBox.FontWeight = hThis.FontWeight;
hTextBox.BackgroundColor = hThis.BackgroundColor;
hTextBox.Color = hThis.TextColor;
% This may change the size of the text box. We should reapply the
% orientation callback as a result (only if the datatip already has a
% position set, i.e. it is not in limbo):
if(~isempty(hThis.Position))
    localApplyCurrentOrientation(hThis);
end

%-------------------------------------------------%
function localSetMarker(hThis,varargin)
% varargin contains unused callback objects

%localDebug(hThis,'@datatip\datatip.m : localSetMarker');

hMarker = hThis.MarkerHandle;
set(hMarker,'Marker',hThis.Marker);
set(hMarker,'MarkerSize',hThis.MarkerSize);
set(hMarker,'MarkerEdgeColor',hThis.MarkerEdgeColor);
set(hMarker,'MarkerFaceColor',hThis.MarkerFaceColor);

%-------------------------------------------------%
function localSetStringFcn(hThis,varargin)
% varargin contains unused callback objects

%localDebug(hThis,'@datatip\datatip.m : localSetStringFcn');

updatestring(hThis);

%-------------------------------------------------%
function localSetInterpolate(hThis,varargin)
% varargin contains unused callback objects

%localDebug(hThis,'@datatip\datatip.m : localSetInterpolate');

% Pass down interpolate state to data cursor
hDataCursor = hThis.DataCursorHandle;
hDataCursor.Interpolate = hThis.Interpolate;

% Ideally, we would now update the position of the
% datatip for the new interpolation mode. Currently,
% this is not possible since we don't store
% the original target and/or position for both
% interpolation states.
%update(hThis,target);

%-------------------------------------------------%
function localDestroy(hThis,varargin)
% varargin contains unused callback objects

%localDebug(hThis,'@datatip\datatip.m : start localDestroy');

% Clean up, make sure handle is valid before deleting
if ishandle(hThis.DataCursorHandle)
    h.DataCursorHandle = [];
    delete(hThis.DataCursorHandle);
end
if all(ishandle(hThis.MarkerHandle))
    delete(hThis.MarkerHandle);
end
if ishandle(hThis.TextBoxHandle)
    delete(hThis.TextBoxHandle);
end
if ishandle(hThis)
    delete(hThis);
end

%localDebug(hThis,'@datatip\datatip.m : end localDestroy');


%-------------------------------------------------%
function localTestUpdate(hThis,varargin)

%localDebug(hThis,'localTestUpdate',varargin{:});

%-------------------------------------------------%
function localDebug(hThis,str,varargin)
% utility for debugging UDD event callbacks

if ~isa(hThis,'graphics.datatip')
    return;
end

if ~hThis.Debug
    return;
end

if length(varargin)>0
    hEvent = varargin{1};
    if isa(hEvent,'handle.EventData')
        hSrc = hEvent.Source;
        if isa(hSrc,'schema.prop')
            disp(sprintf('%s: %s',str,hSrc.Name))
            return;
        elseif ischar(hEvent)
            disp(sprintf('%s : %s',str,hEvent));
            return
        end
    end
end

disp(str);

%-------------------------------------------------%
function [points_pos] = localGetDatatipPointsPosition(hThis)

%localDebug(hThis,'@datatip\datatip.m : start localGetDatatipPointsPosition');

hMarker = hThis.MarkerHandle;
hText = hThis.TextBoxHandle;
%Prevent update function from firing too much:
setappdata(hThis.HostAxes,'datatip_fireDataTipUpdate',false);
orig_text_pos = get(hText,'Position');
orig_text_units = get(hText,'Units');
rmappdata(hThis.HostAxes,'datatip_fireDataTipUpdate');

% Ideally we can transform from data to points via HG
% but currently there is no hook. We can get this
% transform indirectly via a text object.
hText.Units = 'data';
% Do not use hThis.Position here, that property may be temporarily stale
% and is intended for client code only
pos = hThis.DataCursorHandle.Position;
if isempty(pos)
    error('MATLAB:graphics:datatip:emptyPosition','Data cursor position is empty');
end
hText.Position = pos;
hText.Units = 'points';
points_pos = hText.Position;

% Restore text object state
hText.Units = orig_text_units;
hText.Position = orig_text_pos;

%localDebug(hThis,'@datatip\datatip.m : end
%localGetDatatipPointsPosition');

%-------------------------------------------------%
function [mouse_pos] = localGetAxesMousePointsPosition(hAxes)
% Get mouse points position relative to axes

%localDebug(hThis,'@datatip\datatip.m : start localGetAxesMousePointsPosition');

% Get mouse points position relative to figure
hFig = ancestor(hAxes,'figure');
mouse_pos = hgconvertunits(hFig,[0 0 get(hFig,'CurrentPoint')],...
    get(hFig,'Units'),'points',0);
mouse_pos = mouse_pos(3:4);

% Get axes points position
axes_pos = hgconvertunits(hFig,get(hAxes,'Position'),...
    get(hAxes,'Units'),'points',get(hAxes,'Parent'));

% Get mouse position relative to axes position
mouse_pos = mouse_pos(1:2) - axes_pos(1:2);

%localDebug(hThis,'@datatip\datatip.m : end
%localGetAxesMousePointsPosition');