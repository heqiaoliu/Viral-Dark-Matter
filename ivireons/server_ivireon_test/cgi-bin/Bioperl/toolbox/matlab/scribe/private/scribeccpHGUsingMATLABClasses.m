function scribeccpHGUsingMATLABClasses(varargin)
%SCRIBECCP  Tools for copying/cutting & pasting plot objects
%
%   SCRIBECCP(FIG, ACTION) performs the specified ACTION on the selected objects of figure FIG.
%   SCRIBECCP(ACTION) performs the specified ACTION on the selected objects of gcf.
%      ACTION can be one of the strings:
%          CUT - Cuts the selected objects into the clipboard
%          COPY - Copies the selected objects into the clipboard
%          PASTE - Pastes from the clipboard
%          CLEAR - Clears the clipboard
%          DELETE - Removes the object and does not copy to the clipboard.
%          CREATE - Pretends to paste, but just adds the serialized data to
%                   the undo stack.
%   
%   PLOTEDIT must be ON, for this functionality to be available
%   See also PLOTEDIT.

%   Copyright 1984-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $ $Date: 2010/05/20 02:27:28 $

narg = nargin;
if (narg < 1 || narg > 3)
    error('MATLAB:scribeccp:InvalidNumberOfArgs','Invalid number of arguments.');
end

% Get the figure and the action from the args
if (nargin == 1)
  fig = gcf; %Need to change this!!!
  action = lower(varargin{1});
else
  fig = varargin{1};
  action = lower(varargin{2});
end

hPlotEdit = plotedit(fig,'getmode');
if ~isactiveuimode(hPlotEdit,'Standard.PlotSelect') && ~strcmpi(action,'create')
    activateuimode(hPlotEdit,'Standard.PlotSelect');
end
hMode = hPlotEdit.ModeStateData.PlotSelectMode;

% Change the cursor to an hourglass
ptr = get(fig, 'pointer');
set(fig, 'pointer', 'watch');

% Perform the actual requested action
switch action
    case 'copy'
        selobjs = localGetCopyData(hMode);        
        ccpCopy(hMode, selobjs, 0, true);
        ccpCopyPostProcess(hMode,selobjs);
        hMode.ModeStateData.OperationData = [];
    case 'cut'
        selobjs = localGetCopyData(hMode);
        ccpCopy(hMode, selobjs, 0, true);
        % To ensure that everything gets serialized, deselect everything
        % and then copy again:
        deselectall(fig);
        selobjs = ccpCopyPostProcess(hMode,selobjs);
        res = ccpCopy(hMode, selobjs, 1, false);
        localCreateCutUndo(hMode,'Cut',selobjs,res);
    case 'delete'
        selobjs = localGetCopyData(hMode);
        % To ensure that everything gets serialized, deselect everything
        % and then copy again:
        deselectall(fig);
        selobjs = ccpCopyPostProcess(hMode,selobjs);
        res = ccpCopy(hMode, selobjs, 1, false);
        localCreateCutUndo(hMode,'Delete',selobjs,res);
    case 'paste'
        serialized = getappdata(0, 'ScribeCopyBuffer');
        res = ccpPaste(hMode,serialized,true);
        if ~isempty(res)
            res = localGetCopyData(hMode,res);
            serialized = ccpCopy(hMode,res, 0, false);
            res = ccpCopyPostProcess(hMode,res);
            localCreatePasteUndo(hMode,'Paste',res,serialized);
        end
    case 'create'
        selobjs = localGetCopyData(hMode);
        handles = handle(unique(findall(selobjs)));
        serialized = ccpCopy(hMode, handles, 0, false);
        localCreatePasteUndo(hMode,'New Object',handles,serialized);
    case 'clear'
        ccpClearBuffer(fig);
end
% If nothing is selected, default to selecting the figure:
if isempty(hMode.ModeStateData.SelectedObjects)
    hMode.ModeStateData.SelectedObjects = hg2.SceneNode.empty;
    selectobject(fig);
end

% Reset the cursor back to its original state
set(fig, 'pointer', ptr);

%-------------------------------------------------------------------------%
function selobjs = localGetCopyData(hMode,selobjs)
% Preprocess the selected objects to play nice with undo/redo.

if nargin == 1
    selobjs = hMode.ModeStateData.SelectedObjects;
end
selobjs = ccpCopyPreProcess(hMode,selobjs);
% Remove stale handles
selobjs(~ishghandle(selobjs)) = [];

% Store the parents of the selected objects in the OperationData:
hParents = get(selobjs,'Parent');
if ~iscell(hParents)
    hParents = {hParents};
end
parentProxy = zeros(size(hParents));
for i = 1:length(hParents)
    parentP = hMode.ModeStateData.ChangedObjectProxy(hMode.ModeStateData.ChangedObjectHandles == hParents{i});
    if ~isempty(parentP)
        parentProxy(i) = parentP;
    else
        % If the parent is not registered, register it:
        hMode.ModeStateData.ChangedObjectHandles(end+1) = handle(hParents{i});
        hMode.ModeStateData.ChangedObjectProxy(end+1) = now + rand;
        setappdata(hParents{i},'ScribeProxyValue',hMode.ModeStateData.ChangedObjectProxy(end));
        parentProxy(i) = hMode.ModeStateData.ChangedObjectProxy(end);
    end
end
hMode.ModeStateData.OperationData.Parents = parentProxy;

%-------------------------------------------------------------------------%
function localCreatePasteUndo(hMode,commandName,handles,serialized)
% Register the undo with the figure and the mode

handles = findall(handle(handles));
proxyList = zeros(size(handles));
% Store the handle proxies rather than the handles
for i = 1:length(handles)
    proxyVal = hMode.ModeStateData.ChangedObjectProxy(hMode.ModeStateData.ChangedObjectHandles == handle(handles(i)));
    if ~isempty(proxyVal)
        proxyList(i) = proxyVal;
    end
end
proxyList(proxyList == 0) = [];

% Create command structure
cmd.Name = commandName;
cmd.Function = @localUndoCut;
cmd.Varargin = {hMode,serialized,hMode.ModeStateData.OperationData.Parents};
cmd.InverseFunction = @localDoCut;
cmd.InverseVarargin = {hMode,proxyList};

% Register with undo/redo
uiundo(hMode.FigureHandle,'function',cmd);
% Clear the operation data:
hMode.ModeStateData.OperationData = [];

%-------------------------------------------------------------------------%
function localCreateCutUndo(hMode,action,handles,serialized)
% Register the undo with the figure and the mode. 

proxyList = zeros(size(handles));
% Store the handle proxies rather than the handles
for i = 1:length(handles)
    proxyVal = hMode.ModeStateData.ChangedObjectProxy(hMode.ModeStateData.ChangedObjectHandles == handle(handles(i)));
    if ~isempty(proxyVal)
        proxyList(i) = proxyVal;
    end
end
proxyList(proxyList == 0) = [];

% Create command structure
cmd.Name = action;
cmd.Function = @localDoCut;
cmd.Varargin = {hMode,proxyList};
cmd.InverseFunction = @localUndoCut;
% Parent information is in the Operation Data
cmd.InverseVarargin = {hMode,serialized,hMode.ModeStateData.OperationData.Parents};
    
% Register with undo/redo
uiundo(hMode.FigureHandle,'function',cmd);
% Clear the operation data:
hMode.ModeStateData.OperationData = [];

%-------------------------------------------------------------------------%
function localDoCut(hMode,proxyList)
% Given a list of proxies, delete the associated objects

handles = plotedit({'getEmptyHandleVector'});

for i = length(proxyList):-1:1
    handles(i) = hMode.ModeStateData.ChangedObjectHandles(hMode.ModeStateData.ChangedObjectProxy == proxyList(i));
end

% Remove invalid handles
handles(~ishghandle(handles)) = [];

ccpCopy(hMode,handles,true,false);

%-------------------------------------------------------------------------%
function localUndoCut(hMode,serialized,parentProxy)
% Given a list of proxies and serialized data, restore the original
% objects.

% First, extract the parents:
hParents = plotedit({'getEmptyHandleVector'});
for i = length(parentProxy):-1:1
    hParents(i) = hMode.ModeStateData.ChangedObjectHandles(hMode.ModeStateData.ChangedObjectProxy == parentProxy(i));
end

ccpPaste(hMode,serialized,false,hParents,false);

%-------------------------------------------------------------------------%
function serialized = ccpCopy(hMode, selobjs, bDelete, copyToClipBoard)
% Do the copy operation.

serialized = {};

for i=1:length(selobjs)
    obj = selobjs(i);
    if ~isvalid(obj);
        continue;
    end
    if false
    else
        serialized{end+1} = getCopyStructureFromObject(obj); %#ok<AGROW>
    end
end

if bDelete
    % If all selected objects share the same parent, the parent will be
    % selected after the "cut" operation.
    hPar = get(selobjs,'Parent');
    toSelect = [];
    if ~iscell(hPar)
        hPar = {hPar;hPar};
    end
    if isequal(hPar{:})
        toSelect = hPar{1};
    end
    if ~isempty(toSelect) && strcmpi(get(toSelect,'Visible'),'on')
        selectobject(toSelect,'replace');
    else
        deselectall(hMode.FigureHandle);
    end
    delete(selobjs);
end

if copyToClipBoard
    setappdata(0,'ScribeCopyBuffer', serialized);
end

%-------------------------------------------------------------------------%
function selobjs = ccpCopyPreProcess(hMode,selobjs)
% Before we do the copy, we want to make sure that we don't duplicate
% effort (i.e. creating extra axes children).

len = length(selobjs);
i = 1;
currIndex = 1;
while i<=len
    obj = selobjs(i);
    if ishghandle(obj)
        parent = get(obj, 'Parent');
        if any(selobjs == parent) %The parent is also selected
            selobjs(i) = [];
            i=i-1; len=len-1;
        end
        % If we have selected an object and some of its children, remove
        % the unselected children for the purposes of the copy.
        if isprop(obj,'Children')
            chil = obj.Children;
            selChil = intersect(chil,selobjs);
            if ~isempty(selChil)
                nonChil = setdiff(chil,selChil);
                chilStruct.ParentProxy = plotedit({'getProxyValueFromHandle',obj});
                % We want to cache the child order
                chilStruct.Children = chil; 
                chilStruct.Unselected = nonChil;
                % Disconnect the children from the parent
                set(nonChil,'Parent',hg2.Group.empty);
                hMode.ModeStateData.OperationData.CachedChildren(currIndex) = chilStruct;
                currIndex = currIndex+1;
            end
        end
    end
    i=i+1;
end

%-------------------------------------------------------------------------%
function selobjs = ccpCopyPostProcess(hMode,selobjs)
% Restore any disconnected children, if we have any
if isfield(hMode.ModeStateData.OperationData,'CachedChildren')
    cachedChildren = hMode.ModeStateData.OperationData.CachedChildren;
    for i=1:numel(cachedChildren)
        chilStruct = cachedChildren(i);
        par = plotedit({'getHandleFromProxyValue',hMode.FigureHandle,chilStruct.ParentProxy});
        set(chilStruct.Unselected,'Parent',par);
        % Restore the child order.
        set(par,'Children',chilStruct.Children);
    end
end

%-------------------------------------------------------------------------%
function newObjs = ccpPaste(hMode,serialized,updateProxyList,hParents,doOffset)
fig = hMode.FigureHandle;
pm = getappdata(fig,'PlotManager');

if nargin < 4;
    hParents = [];
end
if nargin < 5
    doOffset = true;
end

selAxes = hg2.Group.empty;
selParent = hg2.Group.empty;
if ~isempty(hMode.ModeStateData.SelectedObjects)
    selAxes = findobj(hMode.ModeStateData.SelectedObjects,'-function',@(obj)(isa(obj,'matlab.graphics.axis.Axes')),'-depth',0);
    selParent = findobj(hMode.ModeStateData.SelectedObjects,'-function',@(obj)(isa(obj,'matlab.ui.container.Panel')),'-depth',0);
end

if isempty(selAxes)
    selAxes = hg2.Group.empty;
end
if isempty(selParent)
    selParent = hg2.Group.empty;
end

% deselect all selected objects in the destination figure
deselectall(hMode.FigureHandle);

% Fire an event that a paste is about to happen for tools to prepare (e.g.
% Basic Fitting).
if ~isempty(pm) && ishandle(pm)
    evdata = scribe.scribeevent(pm,'PlotEditBeforePaste');
    send(pm,'PlotEditBeforePaste',evdata);
end
newObjs = hg2.SceneNode.empty;
toSelect = [];

for i=1:length(serialized)
    if isempty(serialized{i})
        return;
    end
    select = [];
    % Take special care when undoing a paste of a line or an axes into a
    % uipanel.
    if ~isempty(hParents)
        selAxes = findobj(hParents,'-function',@(obj)(isa(obj,'matlab.graphics.axis.Axes')),'-depth',0);
        selParent = findobj(hParents,'-function',@(obj)(isa(obj,'matlab.ui.container.Panel')),'-depth',0);
    end
    
    if isempty(selAxes)
        selAxes = hg2.Group.empty;
    end
    
    if isempty(selParent)
        selParent = fig;
    end
    
    obj = getObjectFromCopyStructure(serialized{i});
    
    if isempty(obj)
        continue;
    end
    
    % If we have a container type, we will use the selected parent as the
    % true parent. Otherwise, use the selected axes, if it exists. If no
    % axes exists, we will create a new axes for every selected parent.
    if localIsAxesChild(obj)
        currParent = selAxes;
        if isempty(selAxes)
            for j=numel(selParent):-1:1
                currParent(j) = axes('Parent',selParent(j),'Box','on');
            end
            selAxes = currParent;
            offsetObjectsToUniqueLocation(fig,currParent,selParent);
            % Capture that the selected axes is also newly created:
            newObjs = [newObjs currParent]; %#ok<AGROW>
            toSelect = [toSelect false(size(currParent))]; %#ok<AGROW>
        end
    else
        currParent = selParent;
    end
    
    if ismethod(obj,'getTargetParent')
        currParent = obj.getTargetParent(selParent);
    end
    
    % When we have multiple parents selected, we need to have multiple
    % objects created.
    for j=2:numel(currParent)
        obj(j) = getObjectFromCopyStructure(serialized{i});
    end
    
    % If we are pasting a line into the axes from which it came, this
    % should be a no-op. Remove these lines before continuing further:
    if localIsAxesChild(obj(1))
        proxyVal = getappdata(obj(1),'ScribeProxyValue');
        for j=1:numel(currParent)
            duplicates = findobj(currParent,'-function',@(x)(localDoesProxyMatch(x,proxyVal)));
            if ~isempty(duplicates)
                delete(obj(j).UIContextMenu);
                delete(obj(j));
            end
        end
        inds = ~isvalid(obj);
        obj(inds) = [];
        currParent(inds) = [];
    end
    
    if isempty(obj)
        continue;
    end
      
    % If we are pasting and the object may be over a duplicate, make sure
    % to offset the object to a unique location.
    if doOffset && isprop(obj(1),'Position') && isprop(obj(1),'Units') && numel(obj(1).Position) == 4
        offsetObjectsToUniqueLocation(fig,obj,currParent);
    end

    for j=1:numel(obj)
        set(obj(j),'Parent',currParent(j));
        set(obj(j).UIContextMenu,'Parent',fig);
    end
    
    if ~isempty(select)
        newObjs = [newObjs obj]; %#ok<AGROW>
        toSelect = [toSelect select]; %#ok<AGROW>
    else
        newObjs = [newObjs obj]; %#ok<AGROW>
        toSelect = [toSelect true(size(obj))]; %#ok<AGROW>
    end
end

if ~isempty(newObjs)
    if updateProxyList
        % Convert found items to a row-vector
        newHandles = unique(findall(newObjs)).';
        for j = 1:length(newHandles)
            if isappdata(newHandles(j),'ScribeProxyValue')
                rmappdata(newHandles(j),'ScribeProxyValue');
            end
        end
        hMode.ModeStateData.ChangedObjectHandles = [hMode.ModeStateData.ChangedObjectHandles newHandles];
        proxyVals = now+(1:length(newHandles));
        hMode.ModeStateData.ChangedObjectProxy = [hMode.ModeStateData.ChangedObjectProxy proxyVals];
        for j = 1:length(newHandles)
            setappdata(newHandles(j),'ScribeProxyValue',proxyVals(j));
        end
    else
        % Update the proxies appropriately:
        newHandles = unique(findall(newObjs)).';
        for j = 1:length(newHandles)
            if isappdata(newHandles(j),'ScribeProxyValue')
                proxyVal = getappdata(newHandles(j),'ScribeProxyValue');
                hMode.ModeStateData.ChangedObjectHandles(hMode.ModeStateData.ChangedObjectProxy == proxyVal) = newHandles(j);
            end
        end
    end
end

selectobject(newObjs(logical(toSelect)),'replace');

% Fire event for plottools to update
if ~isempty(pm) && ishandle(pm)
    evdata = scribe.scribeevent(pm,'PlotEditPaste');
    set(evdata,'ObjectsCreated',newObjs);
    send(pm,'PlotEditPaste',evdata);
end

%-------------------------------------------------------------------------%
function res = localDoesProxyMatch(obj,val)

res = false;
if ~isappdata(obj,'ScribeProxyValue')
    return;
end
proxyVal = getappdata(obj,'ScribeProxyValue');
res = proxyVal == val;

%-------------------------------------------------------------------------%
function offsetObjectsToUniqueLocation(fig,obj,currParent)

pasteOffset = [10 -10 0 0];
for j=1:numel(obj)
    objPos = hgconvertunits(fig,obj(j).Position,obj(j).Units,'pixels',currParent(j));
    peers = findobj(currParent(j),'-class',class(obj(j)));
    if ~isempty(peers)
        peerPos = get(peers,'Position');
        if ~iscell(peerPos)
            peerPos = {peerPos};
        end
        for k=1:numel(peers)
            peerPos{k} = hgconvertunits(fig,peerPos{k},get(peers(k),'Units'),'pixels',currParent(j));
        end
        while any(cellfun(@(x)(all(abs(x-objPos)<1)),peerPos))
            objPos = objPos + pasteOffset;
        end
        obj.Position = hgconvertunits(fig,objPos,'pixels',obj(j).Units,currParent(j));
    end
end

%-------------------------------------------------------------------------%
function res = localIsAxesChild(obj)

res = isa(obj,'hg2.DataObject');

%-------------------------------------------------------------------------%
function ccpClearBuffer(fig)
if isappdata(0, 'ScribeCopyBuffer')
    rmappdata(0, 'ScribeCopyBuffer');
end
% Since what we can and cannot do has changed, updated the edit menu.
plotedit({'update_edit_menu',fig,false});
