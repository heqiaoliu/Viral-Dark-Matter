function ret=plotedittoolbar(hfig,varargin)
%PLOTEDITTOOLBAR Annotation toolbar.

%   Copyright 1984-2010 The MathWorks, Inc.

Udata = getUdata(hfig);
r = [];

if nargin==1
    r = plotedittoolbar(hfig,'show');
    arg = '';
elseif nargin==2
    arg = lower(varargin{1});
    if ~strcmp(arg, 'init') && isempty(Udata)
        r = plotedittoolbar(hfig,'init');
        Udata = getUdata(hfig);
    end
elseif nargin==3
    arg = 'settoggprop';
elseif nargin==4
    arg = 'set';
else
    return;
end
emptyUdata = isempty(Udata);
switch arg
    case 'init'
        stb = findall(hfig, 'tag', 'PlotEditToolBar');
        if isempty(stb)
            r = createToolbar(hfig);
        end
        initUdata(hfig);
        Udata = getUdata(hfig);
        setUdata(hfig,Udata)
    case 'show'
        set(Udata.mainToolbarHandle, 'visible', 'on');
    case 'hide'
        set(Udata.mainToolbarHandle, 'visible', 'off');
    case 'toggle'
        if emptyUdata
            plotedittoolbar(hfig,'init');
        else
            h = Udata.mainToolbarHandle;
            val = get(h,'visible');
            if strcmpi(val,'off')
                set(h,'visible','on');
            else
                set(h,'visible','off');
            end
        end
    case 'getvisible'
        if isempty(Udata)
            r = 0;
        else
            h = Udata.mainToolbarHandle;
            r = strcmp(get(h, 'visible'), 'on');
        end
    case 'close'
        if ishghandle(Udata.mainToolbarHandle)
            delete(Udata.mainToolbarHandle);
        end
        setUdata(hfig,[]);
    case 'settoggprop'
        if isnumeric(varargin{2}) || ...
                (ischar(varargin{2}) && ...
                (strcmpi(varargin{2},'none') || ...
                strcmpi(varargin{2},'auto') || ...
                strcmpi(varargin{2},'flat') || ...
                strcmpi(varargin{2},'interp')))
            % set cdata
            setColortoggleCdata(hfig,varargin{1},varargin{2})
        elseif ischar(varargin{2})
            % set tooltip
            setToggleTooltip(hfig,varargin{1},varargin{2})
        end
    case 'set'
        % ploteditToolbar(item,prop,onoff);
        setToolbarItemProperties(hfig,varargin{:})
    otherwise
        processItem(hfig,arg);
end

if nargout>0
    ret = r;
end
%--------------------------------------------------------------%
function h=createToolbar(hfig)

hPlotEdit = plotedit(hfig,'getmode');
hMode = hPlotEdit.ModeStateData.PlotSelectMode;

h = uitoolbar(hfig, 'HandleVisibility','off');
Udata.mainToolbarHandle = h;
mlroot = matlabroot;
iconroot = [mlroot '/toolbox/matlab/icons/'];
uicprops.Parent = h;
uicprops.HandleVisibility = 'off';

% Face Color
uicprops.ClickedCallback = '';
uicprops.OnCallback = {@localProcessItem,hMode,'FaceColor'};
uicprops.OffCallback = '';
uicprops.CreateFcn = '';
uicprops.ToolTip = 'Face Color';
uicprops.Tag = 'figToolScribeFaceColor';
uicprops.CData = loadicon([iconroot 'tool_shape_fill_face.png']);
utogg = uitoggletool(uicprops);

% Edge/Line Color
uicprops.ClickedCallback = '';
uicprops.OnCallback = {@localProcessItem,hMode,'EdgeColor'};
uicprops.OffCallback = '';
uicprops.CreateFcn = '';
uicprops.ToolTip = 'Edge Color';
uicprops.Tag = 'figToolScribeEdgeColor';
uicprops.CData = loadicon([iconroot 'tool_shape_fill_stroke.png']);
utogg(end+1) = uitoggletool(uicprops);

% Text Color
uicprops.ClickedCallback = '';
uicprops.OnCallback = {@localProcessItem,hMode,'TextColor'};
uicprops.OffCallback = '';
uicprops.CreateFcn = '';
uicprops.ToolTip = 'Text Color';
uicprops.Tag = 'figToolScribeTextColor';
uicprops.CData = loadicon([iconroot 'tool_font.png']);
utogg(end+1) = uitoggletool(uicprops,'Separator','on');

% Font
uicprops.ClickedCallback = '';
uicprops.OnCallback = {@localProcessItem,hMode,'TextFont'};
uicprops.OffCallback = '';
uicprops.CreateFcn = '';
uicprops.ToolTip = 'Font';
uicprops.Tag = 'figToolScribeTextFont';
uicprops.CData = loadicon([iconroot 'tool_font.png']);
utogg(end+1) = uitoggletool(uicprops);

% Text Bold
uicprops.ClickedCallback = '';
uicprops.OnCallback = {@localProcessItem,hMode,'TextBold'};
uicprops.OffCallback = {@localProcessItem,hMode,'TextNoBold'};
uicprops.CreateFcn = '';
uicprops.ToolTip = 'Bold';
uicprops.Tag = 'figToolScribeTextBold';
uicprops.CData = loadicon([iconroot 'tool_font_bold.png']);
utogg(end+1) = uitoggletool(uicprops,'Separator','on');

% Text Italic
uicprops.ClickedCallback = '';
uicprops.OnCallback = {@localProcessItem,hMode,'TextItalic'};
uicprops.OffCallback = {@localProcessItem,hMode,'TextNoItalic'};
uicprops.CreateFcn = '';
uicprops.ToolTip = 'Italic';
uicprops.Tag = 'figToolScribeTextItalic';
uicprops.CData = loadicon([iconroot 'tool_font_italic.png']);
utogg(end+1) = uitoggletool(uicprops);

% Left Align
uicprops.ClickedCallback = '';
uicprops.OnCallback = {@localProcessItem,hMode,'TextLeft'};
uicprops.OffCallback = '';
uicprops.CreateFcn = '';
uicprops.ToolTip = 'Align Left';
uicprops.Tag = 'figToolScribeLeftTextAlign';
uicprops.CData = loadicon([iconroot 'tool_text_align_left.png']);
utogg(end+1) = uitoggletool(uicprops,'Separator','on');

% Center Align
uicprops.ClickedCallback = '';
uicprops.OnCallback = {@localProcessItem,hMode,'TextCenter'};
uicprops.OffCallback = '';
uicprops.CreateFcn = '';
uicprops.ToolTip = 'Align Center';
uicprops.Tag = 'figToolScribeCenterTextAlign';
uicprops.CData = loadicon([iconroot 'tool_text_align_center.png']);
utogg(end+1) = uitoggletool(uicprops);

% Right Align
uicprops.ClickedCallback = '';
uicprops.OnCallback = {@localProcessItem,hMode,'TextRight'};
uicprops.OffCallback = '';
uicprops.CreateFcn = '';
uicprops.ToolTip = 'Align Right';
uicprops.Tag = 'figToolScribeRightTextAlign';
uicprops.CData = loadicon([iconroot 'tool_text_align_right.png']);
utogg(end+1) = uitoggletool(uicprops);

% Standard scribe annotations
u =uitoolfactory(h,'Annotation.InsertLine');
set(u,'Separator','on');
uitoolfactory(h,'Annotation.InsertArrow');
uitoolfactory(h,'Annotation.InsertDoubleArrow');
uitoolfactory(h,'Annotation.InsertTextArrow');
uitoolfactory(h,'Annotation.InsertTextbox');
uitoolfactory(h,'Annotation.InsertRectangle');
uitoolfactory(h,'Annotation.InsertEllipse');
% Standard scribe actions
u = uitoolfactory(h,'Annotation.Pin');
set(u,'Separator','on');
uitoolfactory(h,'Annotation.AlignDistribute');

% Save handle arrays
Udata.handles = utogg;

% Add a listener on the selected object state on the plot manager:
% Send an event broadcasting the change in object selection:
plotmgr = [];
if isappdata(hfig, 'PlotManager')
    plotmgr = getappdata(hfig, 'PlotManager');
    if ~isa(plotmgr, 'graphics.plotmanager')
        plotmgr = [];
    end
end
if isempty(plotmgr)
    plotmgr = graphics.plotmanager;
    setappdata (hfig, 'PlotManager', plotmgr);
end

hListeners = handle.listener(plotmgr,'PlotSelectionChange',{@localUpdateToolbar,hMode});
set(hListeners,'Enable',hMode.Enable);
hListeners(end+1) = handle.listener(hMode,findprop(hMode,'Enable'),'PropertyPostSet',{@localEnableListener,hListeners(1),hMode});
Udata.modeListeners = hListeners;
setUdata(hfig,Udata);

set(Udata.mainToolbarHandle, 'tag', 'PlotEditToolBar', 'visible', 'off','serializable','off');

% Initialize the toolbar based on the selected objects
localUpdateToolbar([],[],hMode);

%--------------------------------------------------------------%
function localUpdateToolbar(~,~,hMode)
% Every time the selection changes, update the toolbar

% First, disable all the toolbar items. We will reenable them based on the
% selected objects.
hFig = hMode.FigureHandle;
setToolbarItemProperties(hFig,'all',{'Enable','State'},{'off','off'});

% Deal with the pin button: If nothing pinnable exists in the figure, then
% disable the button.
hPinButton = uigettool(hFig,'Annotation.Pin');
% We define a pinnable object as a child of the annotation layer:
hScribeLayer = graph2dhelper('findScribeLayer',hFig);
if isempty(get(double(hScribeLayer),'Children'))
    set(hPinButton,'Enable','off');
else
    set(hPinButton,'Enable','on');
end

% If the mode is not active, return early
if ~strcmpi(hMode.Enable,'on')
    return;
end

% If nothing is selected, bail out:
hSelected = getselectobjects(hFig);
if isempty(hSelected)
    return;
end

% If the selected objects are not homogeneous, bail out.
if ~hMode.ModeStateData.IsHomogeneous
    return;
end
% Use the last object in the selected item list to determine initial
% values:
hObj = hSelected(end);

% Face Color:
[propName toolTipName] = localGetPropName(hObj,'FaceColor');
if isempty(propName)
    setToolbarItemProperties(hFig,'FaceColor',{'State','Enable'},{'off','off'});
else
    setColortoggleCdata(hFig,'FaceColor',get(hObj,propName));
    setToolbarItemProperties(hFig,'FaceColor',{'State','Enable',...
        'ToolTipString'},{'off','on',toolTipName});
end
% Edge Color:
[propName toolTipName] = localGetPropName(hObj,'EdgeColor');
if isempty(propName)
    setToolbarItemProperties(hFig,'EdgeColor',{'State','Enable'},{'off','off'});
else
    setColortoggleCdata(hFig,'EdgeColor',get(hObj,propName));
    setToolbarItemProperties(hFig,'EdgeColor',{'State','Enable',...
        'ToolTipString'},{'off','on',toolTipName});
end
% Text Color:
[propName toolTipName] = localGetPropName(hObj,'TextColor');
if isempty(propName)
    setToolbarItemProperties(hFig,'TextColor',{'State','Enable'},{'off','off'});
else
    setColortoggleCdata(hFig,'TextColor',get(hObj,propName));
    setToolbarItemProperties(hFig,'TextColor',{'State','Enable',...
        'ToolTipString'},{'off','on',toolTipName});
end
% Font:
[propName toolTipName] = localGetPropName(hObj,'Font');
if isempty(propName)
    setToolbarItemProperties(hFig,'Font',{'State','Enable'},{'off','off'});
else
    setToolbarItemProperties(hFig,'Font',{'State','Enable',...
        'ToolTipString'},{'off','on',toolTipName});
end
% Bold:
[propName toolTipName] = localGetPropName(hObj,'Bold');
if isempty(propName)
    setToolbarItemProperties(hFig,'Bold',{'State','Enable'},{'off','off'});
else
    if strcmpi(get(hObj,propName),'Bold')
        buttonState = 'on';
    else
        buttonState = 'off';
    end
    setToolbarItemProperties(hFig,'Bold',{'State','Enable',...
        'ToolTipString'},{buttonState,'on',toolTipName});
end
% Italic:
[propName toolTipName] = localGetPropName(hObj,'Italic');
if isempty(propName)
    setToolbarItemProperties(hFig,'Italic',{'State','Enable'},{'off','off'});
else
    if strcmpi(get(hObj,propName),'Italic')
        buttonState = 'on';
    else
        buttonState = 'off';
    end
    setToolbarItemProperties(hFig,'Italic',{'State','Enable',...
        'ToolTipString'},{buttonState,'on',toolTipName});
end
% Alignment Properties:
[propName toolTipName] = localGetPropName(hObj,'LeftAlign');
if isempty(propName)
    setToolbarItemProperties(hFig,'LeftAlign',{'State','Enable'},{'off','off'});
else
    if strcmpi(get(hObj,propName),'left')
        buttonState = 'on';
    else
        buttonState = 'off';
    end
    setToolbarItemProperties(hFig,'LeftAlign',{'State','Enable',...
        'ToolTipString'},{buttonState,'on',toolTipName});
end
[propName toolTipName] = localGetPropName(hObj,'RightAlign');
if isempty(propName)
    setToolbarItemProperties(hFig,'RightAlign',{'State','Enable'},{'off','off'});
else
    if strcmpi(get(hObj,propName),'right')
        buttonState = 'on';
    else
        buttonState = 'off';
    end
    setToolbarItemProperties(hFig,'RightAlign',{'State','Enable',...
        'ToolTipString'},{buttonState,'on',toolTipName});
end
[propName toolTipName] = localGetPropName(hObj,'CenterAlign');
if isempty(propName)
    setToolbarItemProperties(hFig,'CenterAlign',{'State','Enable'},{'off','off'});
else
    if strcmpi(get(hObj,propName),'center')
        buttonState = 'on';
    else
        buttonState = 'off';
    end
    setToolbarItemProperties(hFig,'CenterAlign',{'State','Enable',...
        'ToolTipString'},{buttonState,'on',toolTipName});
end

%--------------------------------------------------------------%
function localEnableListener(obj,evd,hListener,hMode) %#ok<INUSL>
% Enable or disable the selection listener based on the state of Plot
% Select Mode.

set(hListener,'Enable',evd.NewValue);
% Make sure the toolbar is in sync when the mode is on and toolbar items
% are disabled when the mode is off.
if strcmpi(evd.NewValue,'on')
    localUpdateToolbar([],[],hMode);
else
    setToolbarItemProperties(hMode.FigureHandle,'all',{'Enable','State'},{'off','off'});
end

%--------------------------------------------------------------%
function [propName, description] = localGetPropName(hObj,item)
% Given an object and a toolbar button property, return the property name
% (if any) and the property description to be used
propName = '';
description = '';

switch lower(item)
    case 'facecolor'
        if isprop(hObj,'FaceColorProperty')
            propName = get(hObj,'FaceColorProperty');
            description = get(hObj,'FaceColorDescription');
        elseif isprop(hObj,'BackgroundColor')
            propName = 'BackgroundColor';
            description = 'Background Color';
        elseif ishghandle(hObj,'figure') || ishghandle(hObj,'axes')
            propName = 'Color';
            description = 'Color';
        end
    case 'edgecolor'
        if isprop(hObj,'EdgeColorProperty')
            propName = get(hObj,'EdgeColorProperty');
            description = get(hObj,'EdgeColorDescription');
        elseif ishghandle(hObj,'line')
            propName = 'Color';
            description = 'Color';
        elseif isprop(hObj,'EdgeColor')
            propName = 'EdgeColor';
            description = 'Edge Color';
        end
    case 'textcolor'
        if isprop(hObj,'TextColorProperty')
            propName = get(hObj,'TextColorProperty');
            description = get(hObj,'TextColorDescription');
        elseif isprop(hObj,'TextColor')
            propName = 'TextColor';
            description = 'Text Color';
        elseif ishghandle(hObj,'text')
            propName = 'Color';
            description = 'Color';
        end
    case 'bold'
        if isprop(hObj,'FontWeight')
            propName = 'FontWeight';
            description = 'Bold';
        end
    case 'italic'
        if isprop(hObj,'FontAngle')
            propName = 'FontAngle';
            description = 'Italic';
        end
    case 'font'
        if isprop(hObj,'FontName')
            propName = 'FontName';
            description = 'Font';
        end
    case {'rightalign','leftalign','centeralign'}
        if isprop(hObj,'HorizontalAlignment')
            propName = 'HorizontalAlignment';
            if strcmpi(item,'rightalign')
                description = 'Align Right';
            elseif strcmpi(item,'leftalign')
                description = 'Align Left';
            else
                description = 'Align Center';
            end
        end
end

%--------------------------------------------------------------%
function setToolbarItemProperties(hfig,item,prop,onoff)
switch lower(item)
    case 'facecolor'
        togg = findall(hfig,'tag','figToolScribeFaceColor');
    case 'edgecolor'
        togg = findall(hfig,'tag','figToolScribeEdgeColor');
    case 'textcolor'
        togg = findall(hfig,'tag','figToolScribeTextColor');
    case 'font'
        togg = findall(hfig,'tag','figToolScribeTextFont');
    case 'bold'
        togg = findall(hfig,'tag','figToolScribeTextBold');
    case 'italic'
        togg = findall(hfig,'tag','figToolScribeTextItalic');
    case 'leftalign'
        togg = findall(hfig,'tag','figToolScribeLeftTextAlign');
    case 'centeralign'
        togg = findall(hfig,'tag','figToolScribeCenterTextAlign');
    case 'rightalign'
        togg = findall(hfig,'tag','figToolScribeRightTextAlign');
    case 'all'
        Udata = getUdata(hfig);
        togg = Udata.handles;
end
set(togg,prop,onoff);

%--------------------------------------------------------------%
function setColortoggleCdata(hfig,item,color)

switch lower(item)
    case 'facecolor'
        togg = findall(hfig,'tag','figToolScribeFaceColor');
    case 'edgecolor'
        togg = findall(hfig,'tag','figToolScribeEdgeColor');
    case 'textcolor'
        togg = findall(hfig,'tag','figToolScribeTextColor');
    otherwise
        return;
end

% sets bottom 3 rows to new color
cdata = get(togg,'cdata');
emptycolor = cdata(1,1,:);
if ischar(color)
    for k=1:3
        cdata(15,:,k) = emptycolor(k);
    end
    cdata(14,:,:) = 0;
    cdata(16,:,:) = 0;
    cdata(15,1,:) = 0;
    cdata(15,16,:) = 0;
else
    for k=1:3
        cdata(14:16,:,k) = color(k);
    end
end
set(togg,'cdata',cdata);

%--------------------------------------------------------------%
function setToggleTooltip(hfig,item,tip)

switch item
    case 'facecolor'
        togg = findall(hfig,'tag','figToolScribeFaceColor');
    case 'edgecolor'
        togg = findall(hfig,'tag','figToolScribeEdgeColor');
    case 'textcolor'
        togg = findall(hfig,'tag','figToolScribeTextColor');
    otherwise
        return;
end

set(togg,'tooltip',tip);

%--------------------------------------------------------------%
function localProcessItem(obj,evd,hMode,item)

hFig = hMode.FigureHandle;

switch lower(item)
    case 'facecolor'
        hObjs = hMode.ModeStateData.SelectedObjects;
        [propName, undoName] = localGetPropName(hObjs(end),'FaceColor');
        graph2dhelper('scribeContextMenuCallback',obj,evd,'localExecuteColorCallback',hFig,propName,undoName);
        set(obj,'State','off');
        setColortoggleCdata(hFig,'FaceColor',get(hObjs(1),propName));
    case 'edgecolor'
        hObjs = hMode.ModeStateData.SelectedObjects;
        [propName, undoName] = localGetPropName(hObjs(end),'EdgeColor');
        graph2dhelper('scribeContextMenuCallback',obj,evd,'localExecuteColorCallback',hFig,propName,undoName);
        set(obj,'State','off');
        setColortoggleCdata(hFig,'EdgeColor',get(hObjs(1),propName));
    case 'textcolor'
        hObjs = hMode.ModeStateData.SelectedObjects;
        [propName, undoName] = localGetPropName(hObjs(end),'TextColor');
        graph2dhelper('scribeContextMenuCallback',obj,evd,'localExecuteColorCallback',hFig,propName,undoName);
        set(obj,'State','off');
        setColortoggleCdata(hFig,'TextColor',get(hObjs(1),propName));
    case 'textfont'
        hObjs = hMode.ModeStateData.SelectedObjects;
        [~, undoName] = localGetPropName(hObjs(end),'Font');
        graph2dhelper('scribeContextMenuCallback',obj,evd,'localExecuteFontCallback',hFig,undoName);
        set(obj,'State','off');
    case 'textbold'
        hObjs = hMode.ModeStateData.SelectedObjects;
        [propName, undoName] = localGetPropName(hObjs(end),'Bold');
        graph2dhelper('scribeContextMenuCallback',obj,evd,'localUpdateValue',hFig,propName,'bold',undoName);
    case 'textnobold'
        hObjs = hMode.ModeStateData.SelectedObjects;
        propName = '';
        undoName = '';
        if hMode.ModeStateData.IsHomogeneous
            [propName, undoName] = localGetPropName(hObjs(end),'Bold');
        end
        if ~isempty(propName)
            graph2dhelper('scribeContextMenuCallback',obj,evd,'localUpdateValue',hFig,propName,'normal',undoName);
        end
    case 'textitalic'
        hObjs = hMode.ModeStateData.SelectedObjects;
        [propName, undoName] = localGetPropName(hObjs(end),'Italic');
        graph2dhelper('scribeContextMenuCallback',obj,evd,'localUpdateValue',hFig,propName,'italic',undoName);
    case 'textnoitalic'
        hObjs = hMode.ModeStateData.SelectedObjects;
        propName = '';
        undoName = '';
        if hMode.ModeStateData.IsHomogeneous
            [propName, undoName] = localGetPropName(hObjs(end),'Italic');
        end
        if ~isempty(propName)
            graph2dhelper('scribeContextMenuCallback',obj,evd,'localUpdateValue',hFig,propName,'normal',undoName);
        end
    case 'textleft'
        hObjs = hMode.ModeStateData.SelectedObjects;
        [propName, undoName] = localGetPropName(hObjs(end),'LeftAlign');
        graph2dhelper('scribeContextMenuCallback',obj,evd,'localUpdateValue',hFig,propName,'left',undoName);
        % Set the right and center buttons to the "off" position:
        setToolbarItemProperties(hFig,'centeralign','State','off');
        setToolbarItemProperties(hFig,'rightalign','State','off');
    case 'textcenter'
        hObjs = hMode.ModeStateData.SelectedObjects;
        [propName, undoName] = localGetPropName(hObjs(end),'CenterAlign');
        graph2dhelper('scribeContextMenuCallback',obj,evd,'localUpdateValue',hFig,propName,'center',undoName);
        % Set the right and left buttons to the "off" position:
        setToolbarItemProperties(hFig,'leftalign','State','off');
        setToolbarItemProperties(hFig,'rightalign','State','off');
    case 'textright'
        hObjs = hMode.ModeStateData.SelectedObjects;
        [propName, undoName] = localGetPropName(hObjs(end),'RightAlign');
        graph2dhelper('scribeContextMenuCallback',obj,evd,'localUpdateValue',hFig,propName,'right',undoName);
        % Set the left and center buttons to the "off" position:
        setToolbarItemProperties(hFig,'centeralign','State','off');
        setToolbarItemProperties(hFig,'leftalign','State','off');

end

%-------------------------------------------------------%
function Udata = getUdata(hfig)

uddfig = handle(hfig);

if isprop(uddfig,'PlotEditToolbarHandles')
    Udata = uddfig.PlotEditToolbarHandles;
else
    Udata = [];
end

%--------------------------------------------------------------%
function setUdata(hfig,Udata)

uddfig = handle(hfig);
if ~isprop(uddfig,'PlotEditToolbarHandles')
    if ~isobject(uddfig)
        hprop = schema.prop(uddfig,'PlotEditToolbarHandles','MATLAB array');
        hprop.AccessFlags.Serialize = 'off';
        hprop.Visible = 'off';
    else
        hprop = addprop(hfig,'PlotEditToolbarHandles');
        hprop.Transient = true;
        hprop.Hidden = true;
    end
end
uddfig.PlotEditToolbarHandles = Udata;


%--------------------------------------------------------------%
function initUdata(hfig)

Udata = getUdata(hfig);
setUdata(hfig,Udata);

function cdata = loadicon(filename)

% Load cdata from *.png file
if length(filename)>3 && strncmp(filename(end-3:end),'.png',4)
    [cdata, ~, alpha] = imread(filename,'Background','none');
    % Converting 16-bit integer colors to MATLAB colorspec
    cdata = double(cdata) / 65535.0;
    % Set all transparent pixels to be transparent (nan)
    cdata(alpha==0) = NaN;
else
    cdata = NaN;
end
