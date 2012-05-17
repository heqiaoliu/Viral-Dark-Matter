function scribeContextMenuCallback(obj,evd,callbackName,varargin)
% Executes a callback and registers the change (if any) with the undo
% stack.

%   Copyright 2006-2007 The MathWorks, Inc.

% This is a switchyard function for plot edit callbacks
feval(callbackName,obj,evd,varargin{:});

%----------------------------------------------------------------------%
function localUpdateValue(obj,evd,hFig,propName,value,undoName) %#ok<INUSL>
% Update the property value specified by the callback:

% Make sure the mode is active. Some context menus (legend and colorbar)
% may execute their callbacks when the mode is not active. In this case, we
% use a different tack. It should be noted that if we are not in plot edit
% mode, the callbacks will *not* be registered with undo/redo
% We check the "scribeActive" flag in case we are in the middle of
% initialization.
if isactiveuimode(hFig,'Standard.EditPlot') || isappdata(hFig,'scribeActive')
    % Get a handle to the mode. Though this creates an interdependency, it is
    % mitigated by the guarantee that this callback is only executed while the
    % mode is active, and thus already created.
    hPlotEdit = plotedit(hFig,'getmode');
    hMode = hPlotEdit.ModeStateData.PlotSelectMode;
    hObjs = hMode.ModeStateData.SelectedObjects;
    localConstructPropertyUndo(hFig,hMode,undoName,propName,get(hObjs,propName),value);
else
    hMenu = ancestor(obj,'UIContextMenu');
    if ishandle(hMenu) && isappdata(hMenu,'CallbackObject')
        hObjs = getappdata(hMenu,'CallbackObject');
    else
        hObjs = hittest(hFig);
    end
end

if iscell(propName)
    cellfun(@(x)(set(hObjs,x,value)),propName);
else
    set(hObjs,propName,value);
end

%----------------------------------------------------------------------%
function localExecuteColorCallback(obj,evd,hFig,propName,undoName) %#ok<DEFNU>
% Brings up a color dialog linked to "propName". The object is determined
% by the currently selected objects of the plot select mode.

% Get a handle to the mode. Though this creates an interdependency, it is
% mitigated by the guarantee that this callback is only executed while the
% mode is active, and thus already created.
if isactiveuimode(hFig,'Standard.EditPlot')
    hPlotEdit = plotedit(hFig,'getmode');
    hMode = hPlotEdit.ModeStateData.PlotSelectMode;
    hObjs = hMode.ModeStateData.SelectedObjects;
else
    hMenu = ancestor(obj,'UIContextMenu');
    if isappdata(hMenu,'CallbackObject')
        hObjs = getappdata(hMenu,'CallbackObject');
    else
        hObjs = hittest(hFig);
    end
end
if isempty(hObjs)
    hObjs = hFig;
end
if iscell(propName)
    pName = propName{1};
else
    pName = propName;
end
c = uisetcolor(get(hObjs(end),pName));
if ~isequal(c,0)
    localUpdateValue(obj,evd,hFig,propName,c,undoName)
end

%-----------------------------------------------------------------------%
function localExecuteFontCallback(obj,evd,hFig,undoName) %#ok<DEFNU,INUSL>
% Brings up a font dialog linked to an object. The object is determined by
% the currently selected object of the plot select mode.

% Get a handle to the mode. Though this creates an interdependency, it is
% mitigated by the guarantee that this callback is only executed while the
% mode is active, and thus already created.
if isactiveuimode(hFig,'Standard.EditPlot')
    hPlotEdit = plotedit(hFig,'getmode');
    hMode = hPlotEdit.ModeStateData.PlotSelectMode;
    hObjs = hMode.ModeStateData.SelectedObjects;
else
    hMenu = ancestor(obj,'UIContextMenu');
    if isappdata(hMenu,'CallbackObject')
        hObjs = getappdata(hMenu,'CallbackObject');
    else
        hObjs = hittest(hFig);
    end
    hMode = [];
end
props = {'FontName','FontSize','FontUnits','FontWeight','FontAngle'};
pv = [props; get(hObjs(end),props)]; % 2-by-n array to be flattened
s = uisetfont(struct(pv{:}));
% On MAC, the structure returned may not have a "FontUnits" field. In this
% case, create one to prevent problems down the line.
if isstruct(s) && ~isfield(s,'FontUnits')
    s.FontUnits = 'Points';
end
if ~isequal(s,0)
    if ~isempty(hMode)
        localConstructPropertyUndo(hFig,hMode,undoName,props,get(hObjs,props),s);
    end
    set(hObjs,s);
end

%-----------------------------------------------------------------------%
function localConstructPropertyUndoCallback(obj,evd,hFig,hMode,Name,propName,oldValue,newValue) %#ok<INUSL,DEFNU>
% Externally called by functions that want to register with undo/redo

localConstructPropertyUndo(hFig,hMode,Name,propName,oldValue,newValue);

%-----------------------------------------------------------------------%
function localConstructPropertyUndo(hFig,hMode,Name,propName,oldValue,newValue)
% Create undo/redo entries for the GUI setters

% If the old value and new values are equal, return early:
if isequal(oldValue,newValue)
    return;
end

% Create the command structure:
opName = sprintf('Change %s',Name);
% Create the proxy list:
hObjs = hMode.ModeStateData.SelectedObjects;
proxyList = zeros(size(hObjs));
for i = 1:length(hObjs)
    proxyList(i) = hMode.ModeStateData.ChangedObjectProxy(hMode.ModeStateData.ChangedObjectHandles == hObjs(i));
end

cmd.Name = opName;
cmd.Function = @localChangeProperty;
cmd.Varargin = {hMode,proxyList,propName,newValue};
cmd.InverseFunction = @localChangeProperty;
cmd.InverseVarargin = {hMode,proxyList,propName,oldValue};

% Register with undo/redo
uiundo(hFig,'function',cmd);

%-----------------------------------------------------------------------%
function localChangeProperty(hMode,proxyList,propName,value)
% Change a property on an object

% Given the proxy list, construct the object list:
hObjs = handle(zeros(size(proxyList))-1);
for i = 1:length(proxyList)
    hObjs(i) = hMode.ModeStateData.ChangedObjectHandles(hMode.ModeStateData.ChangedObjectProxy == proxyList(i));
end

% Remove invalid handles
hObjs(~ishandle(hObjs)) = [];

if ~iscell(propName)
    propName = {propName};
end
% Deal with a structure of values
if isstruct(value)
    set(hObjs,value)
else
    for i=1:length(propName)
        if ~iscell(value)
            set(hObjs,propName{i},value);
        else
            arrayfun(@set,double(hObjs(:)),repmat({propName{i}},size(hObjs(:))),value(:,i));
        end
    end
end