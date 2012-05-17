function selectobject(handles,action)
%SELECTOBJECT Select object for plotedit.

%   SELECTOBJECT(H) selects the object H
%   SELECTOBJECT(H,ONOFF) if ONOFF is 'on', selects and if ONOFF is 'off'
%   deselects the object H 
%   SELECTOBJECT(H,'replace') replaces currently selected objects with the
%   vector of handles H
%
%   See also GETSELECTOBJECTS, DESELECTALL.

%   Copyright 1984-2009 The MathWorks, Inc.
%   $  $  $  $

error(nargchk(1,2,nargin,'struct'));

if iscell(handles), handles = [handles{:}]; end
if ~all(ishghandle(handles))
    error('MATLAB:selectobject:invalidargument','The first argument must be a handle or vector of handles.');
end
if nargin>1 && ...
        (~ischar(action) || ...
        ~(strcmpi(action,'on')||strcmpi(action,'off')||strcmpi(action,'replace')))
    error('MATLAB:selectobject:invalidargument','The second argument must be ''on'',''off'' or ''replace''.');
end
if nargin==1
    action='on';
end

if isempty(handles)
    return;
end

% Since this may be called from outside the mode, obtain the mode for the
% given figure handle.
hFig = ancestor(handles(1),'Figure');
hMan = uigetmodemanager(hFig);
hCurrMode = hMan.CurrentMode;
hPlotEdit = [];
if ~isempty(hCurrMode)
    hPlotEdit = hCurrMode.getuimode('Standard.EditPlot');
end
if isempty(hPlotEdit)
    hPlotEdit = plotedit(hFig,'getmode');
end
hMode = hPlotEdit.ModeStateData.PlotSelectMode;

% Make sure we have valid handles to deal with. Otherwise, explosions may
% occur
localFixSelectedObjs(hMode);

% Go through the handles and give them proxies, if they don't already have
% them.
% Add this object to the proxy list
for i = 1:length(handles)
    proxyVals = now+(1:length(handles));
    if ~feature('HGUsingMATLABClasses')
        appDataObj = double(handles(i));
    else
        appDataObj = handles(i);
    end
    if ~any(hMode.ModeStateData.ChangedObjectHandles == handle(handles(i)))
        if ~feature('HGUsingMATLABClasses')
            appdataObj = double(handles(i));
        else
            appdataObj = handles(i);
        end
        hMode.ModeStateData.ChangedObjectHandles(end+1) = handle(handles(i));
        if isappdata(appdataObj,'ScribeProxyValue')
            hMode.ModeStateData.ChangedObjectProxy(end+1) = getappdata(appdataObj,'ScribeProxyValue');
        else
            hMode.ModeStateData.ChangedObjectProxy(end+1) = proxyVals(i);
            setappdata(appDataObj,'ScribeProxyValue',hMode.ModeStateData.ChangedObjectProxy(end));
        end
    end
end

% Filter out any handles that are not selectable:
filteredIndices = false(size(handles));
for i = 1:length(handles)
    hB = hggetbehavior(handles(i),'plotedit','-peek');
    if ~isempty(hB) && ~hB.EnableSelect
        filteredIndices(i) = true;
    elseif strcmpi(get(handles(i),'tag'),'DataTipMarker')
        filteredIndices(i) = true;
    end
end
handles(filteredIndices) = [];

switch action
    case 'on'
        for i = 1:length(handles)
            if ~feature('HGUsingMATLABClasses')
                setObj = double(handles(i));
            else
                setObj = handles(i);
            end
            hMode.ModeStateData.SelectedObjects(end+1) = handle(handles(i));
            hMode.ModeStateData.MoveVector(end+1) = localCanMove(handles(i));
            hMode.ModeStateData.CutCopyVector(end+1) = localCanCutCopy(handles(i));
            hMode.ModeStateData.PasteVector(end+1) = localCanPaste(handles(i));
            hMode.ModeStateData.DeleteVector(end+1) = localCanDelete(handles(i));
            hMode.ModeStateData.CurrentClasses{end+1} = class(handle(handles(i)));
            if ishghandle(handles(i),'axes')
                set(hFig,'CurrentAxes',setObj);
            end
            set(hFig,'CurrentObject',setObj);
        end
        set(handles,'Selected',hMode.Enable);
    case 'off'
        for i = 1:length(handles)
            index = find(hMode.ModeStateData.SelectedObjects == handle(handles(i)));
            hMode.ModeStateData.SelectedObjects(index) = [];
            hMode.ModeStateData.MoveVector(index) = [];
            hMode.ModeStateData.CutCopyVector(index) = [];
            hMode.ModeStateData.PasteVector(index) = [];
            hMode.ModeStateData.DeleteVector(index) = [];
            hMode.ModeStateData.CurrentClasses(index) = [];
        end
        set(handles,'Selected','off');
    case 'replace'
        set(hMode.ModeStateData.SelectedObjects,'Selected','off');
        if ~feature('HGUsingMATLABClasses')
            hMode.ModeStateData.SelectedObjects = handle([]);
        else
            hMode.ModeStateData.SelectedObjects = plotedit({'getEmptyHandleVector'});
        end
        hMode.ModeStateData.MoveVector = [];
        hMode.ModeStateData.CutCopyVector = [];
        hMode.ModeStateData.PasteVector = [];
        hMode.ModeStateData.DeleteVector = [];
        hMode.ModeStateData.CurrentClasses = {};
        for i = 1:length(handles)
            if ~feature('HGUsingMATLABClasses')
                setObj = double(handles(i));
            else
                setObj = handles(i);
            end
            hMode.ModeStateData.SelectedObjects(end+1) = handle(handles(i));
            hMode.ModeStateData.MoveVector(end+1) = localCanMove(handles(i));
            hMode.ModeStateData.CutCopyVector(end+1) = localCanCutCopy(handles(i));
            hMode.ModeStateData.PasteVector(end+1) = localCanPaste(handles(i));
            hMode.ModeStateData.DeleteVector(end+1) = localCanDelete(handles(i));
            hMode.ModeStateData.CurrentClasses{end+1} = class(handle(handles(i)));
            if ishghandle(handles(i),'axes')
                set(hFig,'CurrentAxes',setObj);
            end
            set(hFig,'CurrentObject',setObj);
        end
        set(handles,'Selected',hMode.Enable);
end

% Workaround for a rendering issue.
if ~isempty(hFig) && ishghandle(hFig)
    refresh(hFig);
end


% Update the mode state:
hMode.ModeStateData.MovePossible = min(hMode.ModeStateData.MoveVector);
hMode.ModeStateData.CutCopyPossible = min(hMode.ModeStateData.CutCopyVector);
hMode.ModeStateData.PastePossible = min(hMode.ModeStateData.PasteVector);
hMode.ModeStateData.DeletePossible = min(hMode.ModeStateData.DeleteVector);
hMode.ModeStateData.IsHomogeneous = isempty(hMode.ModeStateData.SelectedObjects) || isscalar(hMode.ModeStateData.SelectedObjects) || isequal(hMode.ModeStateData.CurrentClasses{:});

% For reverse compatibility, add this information to the scribe axes:
hScribeAxes = graph2dhelper('findScribeLayer',hFig);
if ~feature('HGUsingMATLABClasses')
    hScribeAxes.SelectedObjects = hMode.ModeStateData.SelectedObjects;
end

% Send an event broadcasting the change in object selection:
pm = getappdata(hFig,'PlotManager');
if ~isempty(pm) && ishandle(pm)
    evdata = scribe.scribeevent(pm,'PlotEditBeforePaste');
    set(evdata,'SelectedObjects',hMode.ModeStateData.SelectedObjects);
    send(pm,'PlotSelectionChange',evdata);
end

% Since what we can and cannot do has changed, updated the edit menu.
plotedit({'update_edit_menu',hFig,false});        

%--------------------------------------------------------------------%
function localFixSelectedObjs(hMode)

% remove invalid handles from slectobjs list
hMode.ModeStateData.SelectedObjects(~ishandle(hMode.ModeStateData.SelectedObjects)) = [];

%-----------------------------------------------------------------------%
function res = localCanMove(obj)
% Returns true if the object has the potential to move. This is defined as
% either containing a "move" method, or having a defined, enabled behavior.

if isa(handle(obj),'hg.figure')
    res = false;
    return;
end

res = false;
if ismethod(handle(obj),'move')
    res = true;
else
    if isprop(obj,'Position') && isprop(obj,'Units')
        res = true;
    else
        return;
    end
end

% Also check the plot edit behavior:
hBehavior = hggetbehavior(obj,'plotedit','-peek');
if ~isempty(hBehavior)
    res = hBehavior.EnableMove;
end

%-----------------------------------------------------------------------%
function res = localCanCutCopy(obj)
% By default, all objects may be cut and copied unless their "Serialize" 
% property is set to "off".

if isa(handle(obj),'hg.figure')
    res = false;
    return;
end

if strcmpi(get(obj,'Serializable'),'on')
    res = true;
else
    res = false;
    return;
end

% Also check the plot edit behavior:
hBehavior = hggetbehavior(obj,'plotedit','-peek');
if ~isempty(hBehavior)
    res = hBehavior.EnableCopy;
end

%-----------------------------------------------------------------------%
function res = localCanDelete(obj)
% By default, all objects may be deleted unless their "Serialize" 
% property is set to "off".

if isa(handle(obj),'hg.figure')
    res = false;
    return;
end

if strcmpi(get(obj,'Serializable'),'on')
    res = true;
else
    res = false;
    return;
end

% Also check the plot edit behavior:
hBehavior = hggetbehavior(obj,'plotedit','-peek');
if ~isempty(hBehavior)
    res = hBehavior.EnableDelete;
end

%-----------------------------------------------------------------------%
function res = localCanPaste(obj)
% By default, only figures, axes and uipanel objects may be paste
% destinations.

obj = handle(obj);
if ~isa(obj,'hg.axes') && ~isa(obj,'hg.figure') && ~isa(obj,'hg.uipanel')
    res = false;
    return;
else
    res = true;
end

% Also check the plot edit behavior:
hBehavior = hggetbehavior(obj,'plotedit','-peek');
if ~isempty(hBehavior)
    res = hBehavior.EnablePaste;
end