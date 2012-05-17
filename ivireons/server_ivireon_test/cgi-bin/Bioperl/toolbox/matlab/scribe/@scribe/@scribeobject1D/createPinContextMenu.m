function res = createPinContextMenu(hThis,hFig) %#ok<INUSL>
% Returns menu entries for pin-specific operations. These should be static
% on the abstract subclass

%   Copyright 2006 The MathWorks Inc.

hPlotEdit = plotedit(hFig,'getmode');
hMode = hPlotEdit.ModeStateData.PlotSelectMode;
hMenu = hMode.UIContextMenu;

res = findall(hFig,'Type','uimenu','Tag','scribe.scribeobject1d.pinuicontextmenu');
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
set(res,'Tag','scribe.scribeobject1d.pinuicontextmenu');

%-----------------------------------------------------------------------%
function localPinObject(obj,evd,hMode) %#ok<INUSL>
% Pin the currently selected object to the axes

hFig = hMode.FigureHandle;
% Since only one object should be selected, the object is all the selected
% objects, but index to make sure.
hObj = hMode.ModeStateData.SelectedObjects(1);

% With 1-D objects, it is possible to pin both endpoints, depending on
% where the mouse was clicked on the line. All computations will be done in
% normalized coordinates.
point = get(hFig,'CurrentPoint');
point = hgconvertunits(hFig,[point 0 0],get(hFig,'Units'),'Normalized',hFig);
point = point(1:2);
endPoint1 = [hObj.X(1) hObj.Y(1)];
endPoint1 = hgconvertunits(hFig,[endPoint1 0 0],get(hObj,'Units'),'Normalized',hFig);
endPoint1 = endPoint1(1:2);
endPoint2 = [hObj.X(2) hObj.Y(2)];
endPoint2 = hgconvertunits(hFig,[endPoint2 0 0],get(hObj,'Units'),'Normalized',hFig);
endPoint2 = endPoint2(1:2);

% Find out where along the line we are
d1 = sqrt(  (point(1) - endPoint1(1))^2 + (point(2) - endPoint1(2))^2 )+1e-5;
d2 = sqrt(  (point(1) - endPoint2(1))^2 + (point(2) - endPoint2(2))^2 )+1e-5;

if abs(d1/d2)>4
    hObj.pinAtAffordance(2);
    pinnedAffordance = 2;
elseif abs(d2/d1)>4
    hObj.pinAtAffordance(1);
    pinnedAffordance = 1;
else
    hObj.pinAtAffordance(1);
    hObj.pinAtAffordance(2);
    pinnedAffordance = [1 2];
end

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

% With 1-D objects, it is possible to pin both endpoints, depending on
% where the mouse was clicked on the line. All computations will be done in
% normalized coordinates.
point = get(hFig,'CurrentPoint');
point = hgconvertunits(hFig,[point 0 0],get(hFig,'Units'),'Normalized',hFig);
point = point(1:2);
endPoint1 = [hObj.X(1) hObj.Y(1)];
endPoint1 = hgconvertunits(hFig,[endPoint1 0 0],get(hObj,'Units'),'Normalized',hFig);
endPoint1 = endPoint1(1:2);
endPoint2 = [hObj.X(2) hObj.Y(2)];
endPoint2 = hgconvertunits(hFig,[endPoint2 0 0],get(hObj,'Units'),'Normalized',hFig);
endPoint2 = endPoint2(1:2);

% Find out where along the line we are
d1 = sqrt(  (point(1) - endPoint1(1))^2 + (point(2) - endPoint1(2))^2 )+1e-5;
d2 = sqrt(  (point(1) - endPoint2(1))^2 + (point(2) - endPoint2(2))^2 )+1e-5;

if abs(d1/d2)>4
    hObj.unpinAtAffordance(2);
    pinnedAffordance = 2;
elseif abs(d2/d1)>4
    hObj.unpinAtAffordance(1);
    pinnedAffordance = 1;
else
    hObj.unpinAtAffordance(1);
    hObj.unpinAtAffordance(2);
    pinnedAffordance = [1 2];
end

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