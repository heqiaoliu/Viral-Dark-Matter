function [out] = brush(arg1,arg2)
%BRUSH Interactively highlight, delete, and modify observations in graphs.
%  BRUSH ON turns on brushing.
%  BRUSH OFF turns it off.
%  BRUSH by itself toggles the state.
%  BRUSH COLOR sets the current color used for brushing graphics to the
%  specified ColorSpec. Note that this does not affect the brush state.
%  BRUSH(FIG,OPTION) applies the brush command to the figure specified by
%  FIG. OPTION can be any of the above arguments.
%
%  H = BRUSH(FIG) returns the figure's brush mode object for customization.
%        The following properties can be modified using set/get:
%
%        Enable  'on'|{'off'}
%        Specifies whether this figure mode is currently 
%        enabled on the figure.
%
%        FigureHandle <handle>
%        The associated figure handle. This property supports GET only.
%
%        Color <MATLAB array>
%        Specifies the current color used for brushing
%
%  EXAMPLE 1:
%
%  plot(1:10);
%  brush on
%  % brush graphics in the plot
%
%  EXAMPLE 2:
%
%  plot(1:10);
%  h = brush;
%  set(h,'Color',[1 0 0],'Enable','on');
%  % brush graphics on the plot in red.
%
%
%  See also ZOOM, PAN, ROTATE3D, LINKAXES.

% Copyright 2008-2010 The MathWorks, Inc.

brushColor = [];
state = '';
if nargin==0
    f = gcf;
    if nargout>0
        out = locGetObj(f);
        return
    end
    if isactiveuimode(f,'Exploration.Brushing')
        state = 'off';
    else
        state = 'on';
    end
elseif nargin==1
    if length(arg1)==1 && ishghandle(arg1) && strcmp(get(arg1,'type'),'figure')
        f = arg1;
        if nargout>0
           out = locGetObj(f);
           return
        end
        if isactiveuimode(f,'Exploration.Brushing')
            state = 'off';
        else
            state = 'on';
        end
    elseif ischar(arg1)
        f = gcf;
        if nargout>0 && ~strcmpi(arg1,'ison')
            error('MATLAB:brush:NoColorOut',...
                'Do not specify an output when attempting to set brushing color or brush mode state')
        end
        if strcmp(arg1,'on') || strcmp(arg1,'off')
            state = arg1;
        elseif strcmp(arg1,'ison')
            out = isactiveuimode(f,'Exploration.Brushing');
            return;
        else
            brushColor = arg1;
        end
    elseif isnumeric(arg1) && length(arg1)==3
        if nargout>0
            error('MATLAB:brush:NoColorOut',...
                'Do not specify an output when attempting to set brushing color')
        end
        f = gcf;
        brushColor = arg1;
    end
elseif nargin==2
    if nargout>0 && ~strcmpi(arg2,'ison')
            error('MATLAB:brush:NoColorOut',...
                'Do not specify an output when attempting to set brushing color or brush mode state')
    end
    if ~ishghandle(arg1) || ~strcmp(get(arg1,'type'),'figure')
        error('MATLAB:brush:InvalidFigure', 'Unknown or invalid figure.');
    else
        f = arg1;
    end
    if ischar(arg2) && any(strcmpi(arg2,{'on','off','ison'}))
        if strcmp(arg2,'on') || strcmp(arg2,'off')
             state = arg2;
        elseif strcmp(arg2,'ison')
            out = isactiveuimode(f,'Exploration.Brushing');
            return
        end
    else
        brushColor = arg2;
    end
end
    
if strcmp(state,'off') && isactiveuimode(f,'Exploration.Brushing')
    activateuimode(f,'');
elseif strcmp(state,'on')
    ptrCache = get(f,'Pointer');
    set(f,'Pointer','watch');
    drawnow expose
    locGetMode(f); % Creates the mode 
    set(f,'Pointer',ptrCache);
    activateuimode(f,'Exploration.Brushing'); 
    
    % Create the scribe layer camera now since it will be needed
    % once the drag gesture creates the ROI
    if feature('HGUsingMATLABClasses')       
       graph2dhelper('findScribeLayer',f);
    end
end

if ~isempty(brushColor)
    hMode = locGetMode(f);
    locGetObj(f); % Make sure mode accessor is there
    if ischar(brushColor)
        hMode.ModeStateData.color = localConvertColorSpecString(brushColor);
    elseif isnumeric(brushColor) && isvector(brushColor) && length(brushColor)==3 && ...
            ~any(isnan(brushColor)) && min(brushColor)>=0 && max(brushColor)<=1
        hMode.ModeStateData.color = brushColor;
    else
        error('MATLAB:brush:invColor','Invalid color vector');
    end
    localColorCallback(hMode,uigettool(f,'Exploration.Brushing'));    
end

% Callback for mode start/stop
function localModeStateChange(hMode,newstate)

fig = hMode.FigureHandle;
set(uigettool(fig,'Exploration.Brushing'),'State',newstate);
set(findall(fig,'tag','figBrush'),'Checked',newstate);
set(findall(fig,'Tag','figBrushTools'),'Enable',newstate);

% Enable/disable figure copy menu
set(findall(fig,'Tag','figMenuEditCopy'),'Enable',newstate);

function status = localButtonDownFilter(es,ed) %#ok<INUSD>

% Allow context menus and dragging for brushing annotations

status = strcmp(get(es,'Tag'),'Brushing');


function hBrush = locGetObj(hFig)

% Return the brush accessor object, if it exists.
hMode = locGetMode(hFig);
if isempty(hMode.ModeStateData.accessor) ||~ishandle(hMode.ModeStateData.accessor)
    hBrush = graphics.brush(hMode);
    hMode.ModeStateData.accessor = hBrush;
else
    hBrush = hMode.ModeStateData.accessor;
end


function [hMode] = locGetMode(hFig)

hMode = getuimode(hFig,'Exploration.Brushing');
if isempty(hMode)
    
    
    % Construct the mode object and set properties
    hMode = uimode(hFig,'Exploration.Brushing');
    if ~feature('HGUsingMATLABClasses')
        hMode.UseContextMenu = 'on';
        hMode.Uicontextmenu = uicontextmenu('Parent',hFig,'Serializable','off');
        hMode.ButtonDownFilter = @localButtonDownFilter;        
    end
    hMode.windowButtonDownFcn = @(es,ed) datamanager.brushdown(es,ed);
    hMode.windowButtonUpFcn = @(es,ed) datamanager.brushup(es,ed);
    hMode.windowButtonMotionFcn = @(es,ed) datamanager.brushdrag(es,ed);
    hMode.windowFocusLostFcn = @(es,ed) localClearROI(hMode);
    hMode.KeyPressFcn = @datamanager.brushkeypress;
    hMode.ModeStateData = ...
       struct('color',[1 0 0],'xLimMode','','yLimMode','',...
       'zLimMode','','brushIndex',[],'time',[],'SelectionObject',[],...
       'accessor',[],'brushObjects',[],'lastRegion',[],...
       'scribeLayer',[],'plotYYModeStateData',[]);
    
    % If necessary, add a BrushStyleMap instance property to the figure
    hFig_ = handle(hFig);
    if isempty(hFig_.findprop('BrushStyleMap'))
        if feature('HGUsingMATLABClasses')
            addprop(hFig_,'BrushStyleMap');
        else
            schema.prop(hFig_,'BrushStyleMap','MATLAB array');
        end
        hFig_.BrushStyleMap = [1 0 0;0 1 0; 0 0 1]; % default
    end

    % Activate the mode
    hMode.ModeStopFcn = {@localModeStateChange hMode  'off'};
    hMode.ModeStartFcn = {@localModeStateChange hMode  'on'};
    
    % Prebuild brushing objects (for performance reasons)
    if ~feature('HGUsingMATLABClasses') && isempty(hMode.ModeStateData.brushObjects)
        objs = datamanager.getBrushableObjs(hFig);
        for k=1:min(length(objs),20)
            datamanager.enableBrushing(objs(k));
        end
    end
end   
 
function localColorCallback(hMode,brushbtn)

modeColor = hMode.ModeStateData.color;
  
if ~isempty(brushbtn)
    cdata = get(brushbtn,'cdata');
    for row=11:15
        for col=11:15
            cdata(row,col,:) = modeColor;
        end
    end
    set(brushbtn,'CData',cdata);
end

function colorVector = localConvertColorSpecString(colorString)


colorVecArray = [1 1 0;...
                 1 0 1;...
                 0 1 1;...
                 1 0 0;...                     
                 0 1 0;...
                 0 0 1;...
                 1 1 1;...
                 0 0 0];
colorCharArray = {'y';'m';'c';'r';'g';'b';'w';'k'};
colorStrArray = {'yellow';'magenta';'cyan';'red';'green';'blue';'white';'black'};
if length(colorString)==1
    ind = find(strcmp(colorCharArray,colorString));
else
    ind = find(strcmp(colorStrArray,colorString));
end
if ~isempty(ind)
    colorVector = colorVecArray(ind,:);
else
    error('MATLAB:brush:invColorStr','Invalid color string');
end

function localClearROI(hMode)

if ~isempty(hMode.ModeStateData.SelectionObject)
    hMode.ModeStateData.SelectionObject.reset;
end