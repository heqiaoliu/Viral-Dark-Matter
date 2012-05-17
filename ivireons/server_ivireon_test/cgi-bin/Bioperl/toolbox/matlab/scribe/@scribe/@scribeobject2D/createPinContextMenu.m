function res = createPinContextMenu(hThis,hFig) %#ok<INUSL>
% Returns menu entries for pin-specific operations. These should be static
% on the abstract subclass

%   Copyright 2006-2007 The MathWorks Inc.

hPlotEdit = plotedit(hFig,'getmode');
hMode = hPlotEdit.ModeStateData.PlotSelectMode;
hMenu = hMode.UIContextMenu;

res = findall(hFig,'Type','uimenu','Tag','scribe.scribeobject2d.pinuicontextmenu');
if ~isempty(res)
    res = res(end:-1:1);
    return;
end

% There are two menu entries: "Pin to axes" and "Unpin".
% Create the context menu entries.
res = [];
% Start with "Pin to axes"
res(end+1) = uimenu(hMenu,...
    'HandleVisibility','off',...
    'Label','Pin to axes',...
    'Visible','off',...
    'Callback',{@localPinObject,hMode});
% "Unpin"
res(end+1) = uimenu(hMenu,...
    'HandleVisibility','off',...
    'Label','Unpin',...
    'Visible','off',...
    'Callback',{@localUnpinObject,hMode});

% Tag the menu entries for future 
set(res,'Tag','scribe.scribeobject2d.pinuicontextmenu');

%-----------------------------------------------------------------------%
function localPinObject(obj,evd,hMode) %#ok<INUSL>
% Pin the currently selected object to the axes

hFig = hMode.FigureHandle;
% Since only one object should be selected, the object is all the selected
% objects, but index to make sure.
hObj = hMode.ModeStateData.SelectedObjects(1);

% With 2-D objects, pin the default affordance
pinnedAffordance = hObj.PinAff;
hObj.pinAtAffordance(pinnedAffordance);

% Register with undo/redo
proxyValue = hMode.ModeStateData.ChangedObjectProxy(hMode.ModeStateData.ChangedObjectHandles == hObj);

cmd.Name = 'Pin to axes';
cmd.Function = @localPinObjectUndo;
cmd.Varargin = {hMode,proxyValue,pinnedAffordance};
cmd.InverseFunction = @localUnpinObjectUndo;
cmd.InverseVarargin = {hMode,proxyValue,pinnedAffordance};

% Register with undo/redo
uiundo(hFig,'function',cmd);

%------------------------------------------------------------------------%
function localPinObjectUndo(hMode,proxyValue,pinnedAffordance)
% Pin an object to the given affordance

hObj = hMode.ModeStateData.ChangedObjectHandles(hMode.ModeStateData.ChangedObjectProxy == proxyValue);
for i = 1:length(pinnedAffordance)
    hObj.pinAtAffordance(pinnedAffordance(i));
end

%-----------------------------------------------------------------------%
function localUnpinObject(obj,evd,hMode) %#ok<INUSL>
% Pin the currently selected object to the axes

hFig = hMode.FigureHandle;
% Since only one object should be selected, the object is all the selected
% objects, but index to make sure.
hObj = hMode.ModeStateData.SelectedObjects(1);

hPin = hObj.Pin;
% If there is nothing to unpin, return early.
if isempty(hPin)
    return;
end

pinnedAffordance = hPin.Affordance;
hObj.unpinAtAffordance(pinnedAffordance);

% Register with undo/redo
proxyValue = hMode.ModeStateData.ChangedObjectProxy(hMode.ModeStateData.ChangedObjectHandles == hObj);

cmd.Name = 'Unpin';
cmd.Function = @localUninObjectUndo;
cmd.Varargin = {hMode,proxyValue,pinnedAffordance};
cmd.InverseFunction = @localPinObjectUndo;
cmd.InverseVarargin = {hMode,proxyValue,pinnedAffordance};

% Register with undo/redo
uiundo(hFig,'function',cmd);

%------------------------------------------------------------------------%
function localUnpinObjectUndo(hMode,proxyValue,pinnedAffordance)
% Pin an object to the given affordance

hObj = hMode.ModeStateData.ChangedObjectHandles(hMode.ModeStateData.ChangedObjectProxy == proxyValue);
for i = 1:length(pinnedAffordance)
    hObj.unpinAtAffordance(pinnedAffordance(i));
end