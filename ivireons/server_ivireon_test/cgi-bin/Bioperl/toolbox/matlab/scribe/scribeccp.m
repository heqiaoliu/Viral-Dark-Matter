function scribeccp(varargin)
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

%   Copyright 1984-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.22 $ $Date: 2010/02/25 08:10:40 $

if feature('HGUsingMATLABClasses')
    scribeccpHGUsingMATLABClasses(varargin{:});
    return;
end

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
        hMode.ModeStateData.OperationData = [];
    case 'cut'
        selobjs = localGetCopyData(hMode);
        ccpCopy(hMode, selobjs, 0, true);
        % To ensure that everything gets serialized, deselect everything
        % and then copy again:
        deselectall(fig);
        selobjs = ccpCopyPostProcess(selobjs);
        res = ccpCopy(hMode, selobjs, 1, false);
        localCreateCutUndo(hMode,'Cut',selobjs,res);
    case 'delete'
        selobjs = localGetCopyData(hMode);
        % To ensure that everything gets serialized, deselect everything
        % and then copy again:
        deselectall(fig);
        selobjs = ccpCopyPostProcess(selobjs);
        res = ccpCopy(hMode, selobjs, 1, false);
        localCreateCutUndo(hMode,'Delete',selobjs,res);
    case 'paste'
        serialized = getappdata(0, 'ScribeCopyBuffer');
        res = ccpPaste(hMode,serialized,true);
        res = localGetCopyData(hMode,res);
        serialized = ccpCopy(hMode,res, 0, false);
        localCreatePasteUndo(hMode,'Paste',res,serialized);
    case 'create'
        selobjs = localGetCopyData(hMode);
        handles = handle(unique(find(selobjs)));
        serialized = ccpCopy(hMode, handles, 0, false);
        localCreatePasteUndo(hMode,'New Object',handles,serialized);
    case 'clear'
        ccpClearBuffer(fig);
end
% If nothing is selected, default to selecting the figure:
if isempty(hMode.ModeStateData.SelectedObjects)
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
selobjs = ccpCopyPreProcess(selobjs);
% Remove stale handles
selobjs(~ishandle(selobjs)) = [];

% Store the parents of the selected objects in the OperationData:
hParents = get(selobjs,'Parent');
if iscell(hParents)
    hParents = cell2mat(hParents);
end
parentProxy = zeros(size(hParents));
for i = 1:length(hParents)
    parentP = hMode.ModeStateData.ChangedObjectProxy(hMode.ModeStateData.ChangedObjectHandles == hParents(i));
    if ~isempty(parentP)
        parentProxy(i) = parentP;
    else
        % If the parent is not registered, register it:
        hMode.ModeStateData.ChangedObjectHandles(end+1) = handle(hParents(i));
        hMode.ModeStateData.ChangedObjectProxy(end+1) = now + rand;
        setappdata(hParents(i),'ScribeProxyValue',hMode.ModeStateData.ChangedObjectProxy(end));
        parentProxy(i) = hMode.ModeStateData.ChangedObjectProxy(end);
    end
end
hMode.ModeStateData.OperationData = parentProxy;

%-------------------------------------------------------------------------%
function localCreatePasteUndo(hMode,commandName,handles,serialized)
% Register the undo with the figure and the mode

handles = find(handle(handles));
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
cmd.Varargin = {hMode,serialized,hMode.ModeStateData.OperationData};
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
cmd.InverseVarargin = {hMode,serialized,hMode.ModeStateData.OperationData};
    
% Register with undo/redo
uiundo(hMode.FigureHandle,'function',cmd);
% Clear the operatio data:
hMode.ModeStateData.OperationData = [];

%-------------------------------------------------------------------------%
function localDoCut(hMode,proxyList)
% Given a list of proxies, delete the associated objects
handles = handle(zeros(size(proxyList))-1);
for i = 1:length(proxyList)
    handles(i) = hMode.ModeStateData.ChangedObjectHandles(hMode.ModeStateData.ChangedObjectProxy == proxyList(i));
end

% Remove invalid handles
handles(~ishandle(handles)) = [];

ccpCopy(hMode,handles,true,false);

%-------------------------------------------------------------------------%
function localUndoCut(hMode,serialized,parentProxy)
% Given a list of proxies and serialized data, restore the original
% objects.

% First, extract the parents:
hParents = handle(zeros(size(parentProxy))-1);
for i = 1:length(parentProxy)
    hParents(i) = hMode.ModeStateData.ChangedObjectHandles(hMode.ModeStateData.ChangedObjectProxy == parentProxy(i));
end

ccpPaste(hMode,serialized,false,hParents,false);

%-------------------------------------------------------------------------%
function serialized = ccpCopy(hMode, selobjs, bDelete, copyToClipBoard)

j=1; serialized = {};

for i=1:length(selobjs)
    obj = selobjs(i);
    hobj = handle(obj);
    if ~ishandle(obj), continue; end
    
    if ismethod(obj,'copy');
        serialized{end+1} = copy(obj); %#ok<AGROW>
    elseif isa(hobj, 'scribe.legend') || isa(hobj, 'scribe.colorbar')
        % The legend and colorbar cannot be copied. They can, however, be
        % deleted. If their peer axes is deleted as well, an undo operation
        % will capture them. If it is not, the legend and colorbar will not
        % reappear after an undo.
        hAx = hobj.Axes;
        if isempty(hAx) || any(hAx == selobjs)
            continue;
        else
            serialized{end+1} = copyAxesDecoration(double(hobj));
        end
    elseif isa(hobj, 'hg.axes')
        serialized{end+1} = copyAxes(double(hobj)); %#ok<AGROW>
    elseif isa(hobj, 'uicontrol') || isa(hobj,'uipanel')
        serialized{end+1} = handle2struct(double(obj)); %#ok<AGROW>
    elseif (isa(hobj, 'hggroup') || isa(hobj, 'hgtransform')) && ...
            isappdata(double(hobj), 'Scribe_CCPChildren')
        serialized{end+1} = copyGroup(obj); %#ok<AGROW>
    else
        serialized{end+1} = copyLine(obj); %#ok<AGROW>
    end    
    j = j+1;
end
if bDelete
  objs = double(selobjs); 
  % If all selected objects share the same parent, the parent will be
  % selected after the "cut" operation.
  hPar = get(objs,'Parent');
  toSelect = [];
  if ~iscell(hPar)
      hPar = {hPar;hPar};
  end
  hierarchy = [];
  if isequal(hPar{:})
      hPar = hPar{1};
        toSelect = hPar;
      % Keep track of the object hierarchy
      while ~isempty(hPar) && ~isa(handle(hPar),'hg.figure');
          hierarchy(end+1) = hPar;  %#ok<AGROW>
          hPar = get(hPar,'Parent');
      end
  end
  if ~isempty(toSelect) && strcmpi(get(toSelect,'Visible'),'on')
      selectobject(toSelect,'replace');
  else
      deselectall(hMode.FigureHandle);
  end
  delete(objs);
end
if copyToClipBoard
    setappdata(0, 'ScribeCopyBuffer', serialized);
end

%-------------------------------------------------------------------------%
function selobjs = ccpCopyPreProcess(selobjs)
len = length(selobjs);
i = 1;
while i<=len
    obj = selobjs(i);
    hobj = handle(obj);
    if ishandle(obj)
        if isa(hobj, 'hg.line') || isa(hobj, 'hg.surface') || ...
           isa(hobj, 'hg.patch') || isa(hobj, 'hg.text') || ... 
           isa(hobj, 'hg.hggroup') || isa(hobj, 'hg.hgtransform')
            parent = get(obj, 'parent');
            if ~isa(handle(parent), 'axes')
                selobjs(i) = [];
                i=i-1; len=len-1;
                while ~isa(handle(parent), 'axes')
                    copy_children = getappdata(double(parent), 'Scribe_CCPChildren');
                    if ~any(copy_children==obj)
                        copy_children(end+1) = obj;  %#ok<AGROW>
                    end
                    setappdata(double(parent), 'Scribe_CCPChildren', copy_children);
                    obj = parent;
                    parent = get(obj, 'parent');
                end
                if ~any(selobjs==obj)
                    selobjs(end+1) = obj;  %#ok<AGROW>
                end
            elseif any(selobjs == parent) %The parent axes is also selected
                selobjs(i) = [];
                i=i-1; len=len-1;
                copy_children = getappdata(double(parent), 'Scribe_CCPChildren');
                copy_children(end+1) = obj; %#ok<AGROW>
                setappdata(double(parent), 'Scribe_CCPChildren', copy_children);
            end
        end
    end
    i=i+1;
end

%-------------------------------------------------------------------------%
function selobjs = ccpCopyPostProcess(selobjs)
% After copying, for purposes of cut/paste undo redo, make sure that all
% children of an axes get serialized

for i = 1:length(selobjs)
    if isa(handle(selobjs(i)),'hg.axes')
        if isappdata(double(selobjs(i)),'Scribe_CCPChildren')
            rmappdata(double(selobjs(i)),'Scribe_CCPChildren');
        end
    end
end

%-------------------------------------------------------------------------%
function serialized = copyAxesDecoration(obj)
% Serialization method for legends and colorbars:

% Since we can't copy these objects, we know that we are only deleting.
% This is important for the paste step since that will only take place for
% an undo:

hPar = get(obj,'Parent');
parVal = plotedit({'getProxyValueFromHandle',hPar});
setappdata(double(obj),'ScribeCCPParentProxy',parVal);
peerVal = plotedit({'getProxyValueFromHandle',get(obj,'Axes')});
setappdata(double(obj),'ScribeCCPPeerProxy',peerVal);

% If the object is a legend, we have a preserialize step:
hObj = handle(obj);
isLegend = isa(hObj,'scribe.legend');
if isLegend
    methods(hObj,'preserialize')
end
serialized = handle2struct(obj);
if isLegend
    methods(hObj,'postserialize');
end
rmappdata(double(obj),'ScribeCCPParentProxy');
rmappdata(double(obj),'ScribeCCPPeerProxy');

%-------------------------------------------------------------------------%
function serialized = copyAxes(ax) 

hFig = ancestor(ax, 'figure');
% Get the legend and colorbar also
leg = findall(hFig,'type','axes','Axes',double(ax),'Tag','legend');
cb = findall(hFig,'type','axes','Axes',double(ax),'Tag','Colorbar')';
hleg  = handle(leg); hcb = handle(cb); hax = handle(ax);
selobjs = ax;
axSelState = get(selobjs,'Selected');
selAx = ax;

% Get the children of the axes to "copy" leaving out the ones that were
% "explicitly not selected"
if isappdata(ax, 'Scribe_CCPChildren')
  ch = getappdata(ax, 'Scribe_CCPChildren');
  selobjs = [ax ch(:).'];
  rmappdata(ax, 'Scribe_CCPChildren');
  ch = [ch(:).' get(ax, 'Title') get(ax, 'XLabel') ...
      get(ax, 'YLabel') get(ax, 'ZLabel')];
else
  ch = allchild(ax);
end

% Remove any children whose "Serializable" property is set to "off".
chSer = get(ch,'Serializable');
ch(strcmpi(chSer,'off')) = [];

set(selobjs,'Selected','off');

% Get all the contextmenus
uic_all = get(findall(ch), 'uicontextmenu');
if iscell(uic_all)
    % We need to convert the UIContextMenus to all be of type "double";
    uic_all = cellfun(@(x)(double(x)),uic_all,'UniformOutput',false);
    uic_all = cell2mat(uic_all);
end
uic = [get(ax, 'uicontextmenu') uic_all(:).'];
uic = unique(uic); %Get only the unique contextmenus

% Pre Serialize
if ~isempty(leg)  
  leg_olddata = hleg.preserialize();
  % Massage the legend to show only the selected children (when pasted)
  pc = double(get(leg, 'PlotChildren'));
  [selpc, leg_selindices] = intersect(pc,ch);
  setappdata(leg, 'PlotChildren', selpc);
  % Massaging the strings will be done after serialization in the
  % serialized structure
end
cb_olddata = cell(1,length(hcb));
for i=1:length(hcb)
   cb_olddata{i} = hcb(i).preserialize();
end
if ismethod(hax,'preserialize')
  olddata = hax.preserialize();
end

% Serialize everything
allobjs_toserialize = [uic(:) ; cb(:) ; leg(:) ; ax(:)]; % dimension flattening
serialized = handle2struct(double(allobjs_toserialize));
%Remove children from the axes that were "explicitly not selected"
allch = flipud(allchild(ax));
% Remove any children whose "Serializable" property is set to "off".
chSer = get(allch,'Serializable');
allch(strcmpi(chSer,'off')) = [];
[dummy,index] = intersect(allch,ch);
index = sort(index);
serialized(end).children = serialized(end).children(index);
% The special children (XLabel, YLabel, ZLabel and Title) need to be
% updated as well
for k = 1:length(serialized)
    if strcmpi(serialized(k).type,'axes')
        childHandles = {serialized(k).children.handle};
        for i=1:length(serialized(k).special)
            % For each special child, find out its new index
            ind = find(cellfun(@(x)(isequal(x,allch(serialized(k).special(i)))),childHandles));
            serialized(k).special(i) = ind;
        end
    end
end

% Post serialize
if ~isempty(leg)  
  hleg.postserialize(leg_olddata); 
  % Massage the legend(strings) to show only the selected children (when pasted)
  serialized(end-1).properties.String = serialized(end-1).properties.String(leg_selindices);
end
for i=1:length(hcb)
   hcb(i).postserialize(cb_olddata{i});
end
if ismethod(hax,'postserialize')
  hax.postserialize(olddata);
end

set(selobjs,'Selected','on');
set(selAx,'Selected',axSelState);

%-------------------------------------------------------------------------%
function serialized = copyLine(line)

if ismethod(line,'preserialize')
  olddata = line.preserialize;
end

serialized = handle2struct(double(line));
uic_ss = copyContextMenu(line);
if ~isempty(uic_ss)
    serialized.ContextMenu = uic_ss;
end
parentax = ancestor(line, 'axes');
if get(parentax,'Title') == line
    serialized.specialChild = 'Title';
elseif get(parentax,'XLabel') == line
    serialized.specialChild = 'XLabel';
elseif get(parentax,'YLabel') == line
    serialized.specialChild = 'YLabel';
elseif get(parentax,'ZLabel') == line
    serialized.specialChild = 'ZLabel';
end

if ismethod(line,'postserialize')
  line.postserialize(olddata);
end

%-------------------------------------------------------------------------%
function serialized = copyGroup(group)
serialized = handle2struct(double(group));
serialized.children(1:end) = [];
children = getappdata(group, 'Scribe_CCPChildren');
if isappdata(group, 'Scribe_CCPChildren')
    rmappdata(group, 'Scribe_CCPChildren');
end
for i=1:length(children)
    child = children(i); hchild = handle(child);
    if isa(hchild, 'hggroup') || isa(hchild, 'hgtransform')
        serialized.children(end+1) = copyGroup(child);
    else
        serialized.children(end+1) = copyLine(child);
    end
end

%-------------------------------------------------------------------------%
function serialized = copyContextMenu(obj)
fig = ancestor(obj, 'figure');
hPlotEdit = plotedit(fig,'getmode');
hMode = hPlotEdit.ModeStateData.PlotSelectMode;
set(hMode.ModeStateData.SelectedObjects,'Selected','off');
uic = get(obj, 'UIContextMenu');
serialized = handle2struct(double(uic));
set(hMode.ModeStateData.SelectedObjects,'Selected','on');

%-------------------------------------------------------------------------%
function newObjs = ccpPaste(hMode,serialized,updateProxyList,hParents,doOffset)
fig = hMode.FigureHandle;
pm = getappdata(fig,'PlotManager');

if nargin < 4
    hParents = [];
end
if nargin < 5
    doOffset = true;
end

selAxes = [];
selParent = [];
if ~isempty(hMode.ModeStateData.SelectedObjects)
  selAxes = findobj(double(hMode.ModeStateData.SelectedObjects),'flat','Type','axes');
  selParent = findobj(double(hMode.ModeStateData.SelectedObjects),'flat','Type','uipanel');
end

% deselect all selected objects in the destination figure
deselectall(hMode.FigureHandle);

% Fire an event that a paste is about to happen for tools to prepare (eg Basic Fitting)
if ~isempty(pm) && ishandle(pm)
    evdata = scribe.scribeevent(pm,'PlotEditBeforePaste');
    send(pm,'PlotEditBeforePaste',evdata);
end

setappdata(0, 'BusyDeserializing', 1);
if doOffset
    setappdata(fig, 'BusyPasting', 1);
end
newObjs = [];
toSelect = [];

for i=1:length(serialized)
    if isempty(serialized{i})
        continue;
    end
    select = [];
    % Take special care when undoing a paste of a line or an axes into a
    % uipanel
    if ~isempty(hParents) && isa(hParents(i),'hg.axes')
        selAxes = hParents(i);
    end
    if ~isempty(hParents) && isa(hParents(i),'hg.uipanel')
        selParent = hParents(i);
    end
    
    if isempty(selParent)
        selParent = fig;
    end

    % Clone it because of struct2handle bug!
    serializeCloned = clone(serialized{i});
    
    % The serialized (an array of struct), if it is an array of length > 1,
    % includes colorbar & legend and the actual axes is the last element of
    % the array
    ss = serializeCloned(end);
    if strcmpi('scribe.legend',ss.type) || strcmpi('scribe.colorbar',ss.type)
        obj = pasteAxesDecoration(ss, fig);
    elseif strmatch('scribe',ss.type)
        obj = pasteScribeObject(ss, findScribeLayer(fig));
    elseif strcmp(ss.type, 'axes')
        obj = pasteAxes(serializeCloned, selParent);
        select = [];
        if ~isscalar(obj)
            select = false(1,length(obj)-1);
        end
        select = [select true]; %#ok<AGROW>
        if ~isempty(obj), offsetAxesToUniqueLocation(obj(end)); end
    elseif strcmp(ss.type, 'uicontrol') || strcmp(ss.type,'uitable')
        obj = [];
        for j=1:length(selParent)
            obj = [obj struct2handle(ss, double(selParent(j)))]; %#ok
        end
    elseif strcmp(ss.type,'uipanel')
        obj = [];
        for j=1:length(selParent)           
            obj = [obj struct2handle(ss, double(selParent(j)))]; %#ok
            offsetPanelToUniqueLocation(obj(end));        
        end
    else
        obj = [];
        select = [];
        % Capture that the selected axes is also newly created
        if isempty(selAxes)
            for j=1:length(selParent)
                selAxes(j) = axes('Parent',selParent(j),'Box','on');
                obj = [obj selAxes(j)]; %#ok<AGROW>
                select = [select false]; %#ok<AGROW>
                offsetAxesToUniqueLocation(selAxes(j));         
            end
        end 
        obj = [obj pasteLine(ss, selAxes)]; %#ok<AGROW>
        select = [select true(1,numel(obj)-numel(select))]; %#ok<AGROW>
    end
   if ~isempty(select)
       newObjs = [newObjs handle(obj)]; %#ok<AGROW>
       toSelect = [toSelect select]; %#ok<AGROW>
   else
       newObjs = [newObjs handle(obj)]; %#ok<AGROW>
       toSelect = [toSelect true(size(obj))]; %#ok<AGROW>
   end
end

if ~isempty(newObjs)
    if updateProxyList
        % Convert found items to a row-vector
        newHandles = unique(find(newObjs)).';
        for j = 1:length(newHandles)
            if isappdata(double(newHandles(j)),'ScribeProxyValue')
                rmappdata(double(newHandles(j)),'ScribeProxyValue');
            end
        end
        hMode.ModeStateData.ChangedObjectHandles = [hMode.ModeStateData.ChangedObjectHandles newHandles];
        proxyVals = now+(1:length(newHandles));
        hMode.ModeStateData.ChangedObjectProxy = [hMode.ModeStateData.ChangedObjectProxy proxyVals];
        for j = 1:length(newHandles)
            setappdata(double(newHandles(j)),'ScribeProxyValue',proxyVals(j));
        end
    else
        % Update the proxies appropriately:
        newHandles = unique(find(newObjs)).';
        for j = 1:length(newHandles)
            if isappdata(double(newHandles(j)),'ScribeProxyValue')
                proxyVal = getappdata(double(newHandles(j)),'ScribeProxyValue');
                hMode.ModeStateData.ChangedObjectHandles(hMode.ModeStateData.ChangedObjectProxy == proxyVal) = newHandles(j);
            end
        end
    end
end

selectobject(newObjs(logical(toSelect)),'replace');
if doOffset
    rmappdata(fig, 'BusyPasting');
end
rmappdata(0, 'BusyDeserializing');
%Fire event for plottools to update
if ~isempty(pm) && ishandle(pm)
    evdata = scribe.scribeevent(pm,'PlotEditPaste');
    set(evdata,'ObjectsCreated',handle(newObjs));
    send(pm,'PlotEditPaste',evdata);
end

%-------------------------------------------------------------------------%
function ax = pasteAxes(serialized, parent)

everyAx = [];
for j = 1:length(parent)
    parentHandles = zeros(size(serialized));
    for i = 1:length(serialized)
        if ~strcmpi(serialized(i).type,'axes') && ...
            ~strcmpi(serialized(i).type,'scribe.legend') && ...
            ~strcmpi(serialized(i).type,'scribe.colorbar')
            parentHandles(i) = double(ancestor(parent(j),'Figure'));
        else
            parentHandles(i) = double(parent(j));
        end
    end
    allax = struct2handle(serialized, parentHandles, 'convert');
    % Reverse the order of allax so that any true axes is postdeserialized first
    % before its legend, colorbar, or uicontextmenu.
    allax_axesfirst = flipud(allax(:));
    for i=1:length(allax_axesfirst)
        ax = allax_axesfirst(i);

        if strcmp(get(ax, 'type'), 'uicontextmenu')
            continue;
        end

        %Post deserialize
        fig = ancestor(ax,'Figure');
        hasPasteData = isappdata(fig,'BusyPasting');
        if hasPasteData
            rmappdata(fig,'BusyPasting');
        end
        try
            if isappdata(ax,'PostDeserializeFcn')
                feval(getappdata(ax,'PostDeserializeFcn'),ax,'load')
            elseif ismethod(handle(ax),'postdeserialize')
                postdeserialize(handle(ax));
            end
        catch %#ok<CTCH>
        end
        if hasPasteData
            setappdata(fig,'BusyPasting',true);
        end

        %Call postdeserialize on all children also
        chlist = findobj(ax);
        for k=1:length(chlist)
            ch = handle(chlist(k));
            try
                if ismethod(ch,'postdeserialize')
                    postdeserialize(ch);
                end
            catch %#ok<CTCH>
            end
        end

    end
    everyAx = [everyAx allax]; %#ok
end
ax = everyAx;

%-------------------------------------------------------------------------%
function obj = pasteLine(serialized, hParent)
obj = [];
for i=1:length(hParent)
    if ishandle(serialized.handle) && ...
       get(serialized.handle, 'Parent') == double(hParent(i))
        continue;
    end
    
    %Make sure that the parent's behavior object supports paste
    parent = double(hParent(i));
    
    obj(end+1) = struct2handle(serialized, parent, 'convert'); %#ok<AGROW>
    
    try
        if ismethod(handle(obj(end)),'postdeserialize')
            postdeserialize(handle(obj(end)));
        end
    catch %#ok<CTCH>
    end
end

% The paste may have been a no-op, if the paste was in the same axes as the
% original line. Make sure that obj is not empty and valid
if ~isempty(obj) && all(ishandle(obj))
    if isfield(serialized, 'ContextMenu')
        uic = struct2handle(serialized.ContextMenu, ancestor(obj(1), 'figure'));
        set(obj, 'UIContextMenu', uic);
    end

    if isfield(serialized, 'specialChild')
        ax = ancestor(obj, 'axes');
        set(ax, serialized.specialChild, obj);
    end
end

%-------------------------------------------------------------------------%
function obj = pasteAxesDecoration(serialized, fig)
% This method is only called when undoing a delete. There are aspects of it
% which make the assumption that the parent will never change.

hasPasteAppdata = isappdata(double(fig),'BusyPasting');
if ~hasPasteAppdata
    setappdata(double(fig),'BusyPasting',true);
end

currAx = get(double(fig),'CurrentAxes');
parProxy = serialized.properties.ApplicationData.ScribeCCPParentProxy;
hPar = plotedit({'getHandleFromProxyValue',fig,parProxy});
obj = struct2handle(serialized, double(hPar));
% Before calling the post deserialize function, make sure the peer axes is
% up to date.
peerProxy = getappdata(double(obj),'ScribeCCPPeerProxy');
hPeer = plotedit({'getHandleFromProxyValue',fig,peerProxy});
set(obj,'Axes',hPeer);
if isappdata(obj,'PostDeserializeFcn')
    feval(getappdata(obj,'PostDeserializeFcn'),obj,'load')
end
rmappdata(double(obj),'ScribeCCPParentProxy');
rmappdata(double(obj),'ScribeCCPPeerProxy');
% Reset the current axes
set(double(fig),'CurrentAxes',currAx);

if ~hasPasteAppdata
    rmappdata(double(fig),'BusyPasting');
end

%-------------------------------------------------------------------------%
function obj = pasteScribeObject(serialized, hScribeAx)
obj = struct2handle(serialized, double(hScribeAx));
hObj = handle(obj);
if isappdata(obj,'PostDeserializeFcn')
    feval(getappdata(obj,'PostDeserializeFcn'),obj,'load')
elseif ismethod(hObj,'postdeserialize')
    hObj.postdeserialize();
end

%Intentionally unpin it...
for i=1:length(hObj.PinAff)
    hObj.unpinAtAffordance(hObj.PinAff(i));
end

%-------------------------------------------------------------------------%
function offsetAxesToUniqueLocation(ax)
fig = ancestor(ax, 'figure');
ax = double(ax);
allax = findall(fig, 'type', 'axes');
allax(allax == double(ax)) = [];

posfig = getpixelposition(fig);
pos = getpixelposition(ax, 1);
pos(2) = posfig(2)-pos(2)-pos(4);
ppos = getpixelposition(ax);
units = get(ax, 'units');
len = length(allax);
while (len > 0)
    pospeer = getpixelposition(allax(len), 1); 
    pospeer(2) = posfig(2)-pospeer(2)-pospeer(4);
    if (abs(pospeer(1:2)-pos(1:2)) < [2 2]) %#ok<BDSCA>
        ppos = ppos + [10 -10 0 0];
        pos = pos + [10 10 0 0];
        set(ax, 'Units', 'pixels', 'Position', ppos);
        len = length(allax);
    else
        len = len-1;
    end
end
set(ax, 'units', units);

%-------------------------------------------------------------------------%
function offsetPanelToUniqueLocation(hPanel)
fig = ancestor(hPanel, 'figure');
ax = double(hPanel);
allPanels = findall(fig, 'type', 'uipanel');
allPanels(allPanels == double(hPanel)) = [];

posfig = getpixelposition(fig);
pos = getpixelposition(ax, 1);
pos(2) = posfig(2)-pos(2)-pos(4);
ppos = getpixelposition(hPanel);
units = get(hPanel, 'units');
len = length(allPanels);
while (len > 0)
    pospeer = getpixelposition(allPanels(len), 1); 
    pospeer(2) = posfig(2)-pospeer(2)-pospeer(4);
    if (abs(pospeer(1:2)-pos(1:2)) < [2 2]) %#ok<BDSCA>
        ppos = ppos + [10 -10 0 0];
        pos = pos + [10 10 0 0];
        set(hPanel, 'Units', 'pixels', 'Position', ppos);
        len = length(allPanels);
    else
        len = len-1;
    end
end
set(allPanels, 'units', units);

%-------------------------------------------------------------------------%
function ccpClearBuffer(fig)
if isappdata(0, 'ScribeCopyBuffer')
    rmappdata(0, 'ScribeCopyBuffer');
end
% Since what we can and cannot do has changed, updated the edit menu.
plotedit({'update_edit_menu',fig,false});

%-------------------------------------------------------------------------%
function struct2 = clone(struct)
%After handle2struct the serialized structure and the actual figure seem to
%share references to the data.  So, when handle2struct "converts" these
%data, the original entities also start referring to the converted data.
%Hence, to break the reference, we closne the structure by adding zero(0) 
%to all the numeric values in the structure
fnames = fieldnames(struct)';
for index=1:length(struct)
    struct2(index) = struct(index);  %#ok<AGROW>
    for i=1:length(fnames)
        val = struct(index).(fnames{i});
        if isnumeric(val)
            struct2(index).(fnames{i}) = val+0; %#ok<AGROW>
        elseif isstruct(val) && ~isempty(val)
            struct2(index).(fnames{i}) = clone(val);        %#ok<AGROW>
        end
    end 
end

