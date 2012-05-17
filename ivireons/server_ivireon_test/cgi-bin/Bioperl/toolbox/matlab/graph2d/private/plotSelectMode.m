function hMode = plotSelectMode(hFig)
% Create and set up a mode object to perform object selection and resizing.

%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.14 $ $Date: 2010/05/20 02:25:42 $

if ishghandle(hFig,'figure')
    hFig = plotedit(hFig,'getmode');
end

hMode = getuimode(hFig,'Standard.PlotSelect');
if ~isempty(hMode)
    return;
end

hMode = uimode(hFig,'Standard.PlotSelect');
set(hMode,'WindowButtonMotionFcn',{@localNonDragWindowButtonMotionFcn,hMode});
set(hMode,'WindowButtonDownFcn',{@localWindowButtonDownFcn,hMode});
set(hMode,'WindowButtonUpFcn',{@localWindowButtonUpFcn,hMode});
set(hMode,'WindowKeyPressFcn',{@localKeyPressFcn,hMode});
set(hMode,'ModeStartFcn',{@localStartFcn,hMode});
set(hMode,'ModeStopFcn',{@localStopFcn,hMode});
% If the context-menu hasn't been created yet, create it:
hMode.UIContextMenu = uicontextmenu('Parent',hMode.FigureHandle,'HandleVisibility','off',...
    'Serializable','off');
% Tell the mode not to suspend the context-menu as we need to do something
% a bit more complicated.
hMode.UseContextMenu = 'off';
% Tell the mode to suspend callbacks from UIControl objects:
hMode.UIControlInterrupt = true;
% Initialize selected objects:
if ~feature('HGUsingMATLABClasses')
    hMode.ModeStateData.SelectedObjects = handle([]);
else
    hMode.ModeStateData.SelectedObjects = getEmptyHandleVector;
end
% Initialize current point (used by move):
hMode.ModeStateData.CurrPoint = [];
% Initialize two parallel vectors which represent handle identifiers and
% the actual handles. This is used by undo/redo
if ~feature('HGUsingMATLABClasses')
    hMode.ModeStateData.ChangedObjectHandles = handle([]);
else
    hMode.ModeStateData.ChangedObjectHandles = getEmptyHandleVector;
end
hMode.ModeStateData.ChangedObjectProxy = [];
% Keep track of the current operation name:
hMode.ModeStateData.OperationName = '';
hMode.ModeStateData.OperationData = [];
% Keep track of which operations are currently possible:
hMode.ModeStateData.MovePossible = false;
hMode.ModeStateData.MoveVector = [];
hMode.ModeStateData.CutCopyPossible = false;
hMode.ModeStateData.CutCopyVector = [];
hMode.ModeStateData.PastePossible = false;
hMode.ModeStateData.PasteVector = [];
hMode.ModeStateData.DeleteVector = [];
hMode.ModeStateData.DeletePossible = false;
hMode.ModeStateData.IsHomogeneous = true;
hMode.ModeStateData.CurrentClasses = {};
% Keep track of state information for non-scribe object:
hMode.ModeStateData.NonScribeMoveMode = 'none';
% For text objects, keep track of its units as we need to be in non-data
% units for moving to work properly
if ~feature('HGUsingMATLABClasses')
    hMode.ModeStateData.MovingTextHandles = handle([]);
else
    hMode.ModeStateData.MovingTextHandles = getEmptyHandleVector;
end
% Keep track of the UIContextMenu manipulations
hMode.ModeStateData.CurrentUIContextMenuObject = [];
hMode.ModeStateData.AddedUIContextMenuHandles = [];
hMode.ModeStateData.CachedUIContextMenu = [];
% Keep track of whether we are moving (for the keyboard-driven moving)
hMode.ModeStateData.isMoving = false;
% Create a listener for the "Selected" property of the figure:
hProps = {'Selected';...
    'SelectionHighlight';...
    'Position'};
hList = addlistener(handle(hMode.FigureHandle),hProps,'PostSet',@localNoop);
localSetListenerStateOff(hList);
hList.Callback = @(obj,evd)(localFigureSelect(obj,evd,hMode));
hMode.ModeStateData.FigureSelectionListener = hList;
hMode.ModeStateData.FigureSelectionHandles = [];

%-----------------------------------------------------------------------%
function localFigureSelect(obj,evd,hMode) %#ok<INUSL>
% Toggle the selection handles for the figure.
% Selection handles are defined as 8 primitive line objects surrounding the
% figure which are parented to the scribe axes.

hFig = evd.AffectedObject;
selHandles = hMode.ModeStateData.FigureSelectionHandles;

% Default affordance size is currently "6".
afSize = 6;
if isempty(selHandles) || any(~ishghandle(selHandles))
    badHandles = selHandles(ishghandle(selHandles));
    if ~isempty(badHandles)
        delete(badHandles);
    end
    % Construct the affordances.
    hScribeAx = graph2dhelper('findScribeLayer',hFig);
    % Preallocate a handle vector:
    tags = {'bottomleft','topright','bottomright','topleft','left','bottom','right','top'};
    for i=length(tags):-1:1
        selHandles(i) = line('LineWidth', 0.01, 'Color', [0 0 0], 'Marker', 'square', ...
            'MarkerSize', afSize, 'MarkerFaceColor', [0 0 0], ...
            'MarkerEdgeColor', [1 1 1], 'Parent',double(hScribeAx),...
            'Visible', 'off', 'Interruptible', 'off','HitTest','off',...
            'HandleVisibility','off','Tag',tags{i},...
            'XLimInclude','off','YLimInclude','off',...
            'ZLimInclude','off');
        if ~feature('HGUsingMATLABClasses')
            set(selHandles(i),'IncludeRenderer','off');
        end
        hMode.ModeStateData.FigureSelectionHandles = selHandles;
    end
end

% We need to offset the selection handles to hug the edge, rather than
% cross it:
offset = hgconvertunits(hFig,[afSize afSize 0 0],'Pixels',...
    'Normalized',hFig);
offset = offset(1:2);
lx = offset(1);
rx = 1-offset(1);
cx = 0.5;
px = [lx rx rx lx lx cx rx cx];
uy = offset(2);
ly = 1-offset(2);
cy = 0.5;
py = [uy ly uy ly cy uy cy ly];

for i=1:length(selHandles)
    set(selHandles(i),'XData', px(i), 'YData', py(i));
end

% Toggle the visibility of the selection handles based on the combination
% of the "Selected" and "SelectionHighlight" properties:
if strcmpi(get(hFig,'Selected'),'on')
    for i=1:numel(selHandles)
        set(selHandles(i),'Visible',get(hFig,'SelectionHighlight'));
    end
else
    for i=1:numel(selHandles)
        set(selHandles(i),'Visible','off');
    end
end

%-----------------------------------------------------------------------%
function localStartFcn(hMode)

% Remove any stale handles from the list of selected objects.
localFixSelectedObjs(hMode);

% Turn on the figure selection listener
localSetListenerStateOn(hMode.ModeStateData.FigureSelectionListener);
evd.AffectedObject = hMode.FigureHandle;
localFigureSelect([],evd,hMode);

% When we start the mode, select all the objects in the "SelectedObjects"
% state data:
% If there are no objects selected, select the figure by default.
if isempty(hMode.ModeStateData.SelectedObjects)
    selectobject(hMode.FigureHandle,'replace');
end
set(hMode.ModeStateData.SelectedObjects,'Selected','on');

%-----------------------------------------------------------------------%
function localStopFcn(hMode)

% Remove any stale handles from the list of selected objects.
localFixSelectedObjs(hMode);
% When we exit the mode, deselect all the objects in the "SelectedObjects"
% state data:
set(hMode.ModeStateData.SelectedObjects,'Selected','off');
% Turn off the figure selection listener
localSetListenerStateOff(hMode.ModeStateData.FigureSelectionListener);
% If there are any text objects still being edited, turn off the "Editing"
% property.
hObjs = findall(hMode.FigureHandle,'Type','Text','Editing','on');
set(hObjs,'Editing','off');

% Restore the context menu:
localRestoreUIContextMenu(hMode);

%-----------------------------------------------------------------------%
function localKeyPressFcn(fig,evd,hMode)
% Key press function: Enable Cut/Copy/Paste from the keyboard and also
% undo/redo.

key = evd.Character;
if ~ismac
    accelModifier = 'control';
    % Capture the key codes for various actions
    undoKey = 26; % ^Z
    redoKey = 25; % ^Y
    cutKey = 24; % ^X
    copyKey = 3; % ^C
    pasteKey = 22; % ^V
    selectAllKey = 1; % ^A
else
    accelModifier = 'command';
    % On mac, the key codes sent are the letters themselves
    undoKey = 'z';
    redoKey = 'y';
    cutKey = 'x';
    copyKey = 'c';
    pasteKey = 'v';
    selectAllKey = 'a';
end

if isempty(key)
    return
end

currKey = evd.Key;
% Use the arrow keys to move currently selected items
if localIsArrowKey(currKey)
    % Only move if we have objects selected that are movable.
    if ~hMode.ModeStateData.MovePossible
        return;
    end
    curmod = evd.Modifier;
    if isempty(curmod)
        if ~hMode.ModeStateData.isMoving
            hMode.ModeStateData.OperationName = 'Move';
            hMode.ModeStateData.OperationData.Handles = handle(hMode.ModeStateData.SelectedObjects);
            hMode.ModeStateData.OperationData.Positions = get(hMode.ModeStateData.SelectedObjects,'Position');
            hMode.ModeStateData.isMoving = true;
        end
        if strcmpi(currKey,'uparrow')
            delta = [0 1];
        elseif strcmpi(currKey,'downarrow')
            delta = [0 -1];
        elseif strcmpi(currKey,'leftarrow')
            delta = [-1 0];
        else
            delta = [1 0];
        end
        % Check for snap behavior rather than moving by a pixel.
        if strcmpi('on',getappdata(fig,'scribegui_snaptogrid')) && ...
                isappdata(fig,'scribegui_snapgridstruct')
            gridstruct = getappdata(fig,'scribegui_snapgridstruct');
            if delta(1) == 0
                delta(2) = delta(2) * gridstruct.yspace;
            else
                delta(1) = delta(1) * gridstruct.xspace;
            end
            selObjs = hMode.ModeStateData.SelectedObjects;
            delta = repmat(delta,length(selObjs),1);
            localDoSnapMove(hMode,delta,false);
        else
            localDoMove(hMode,delta,false);
        end
        % Set the key release and focus lost functions to register with
        % undo/redo
        set(hMode,'WindowKeyReleaseFcn',{@localDragComplete,hMode});
        set(hMode,'WindowFocusLostFcn',{@localDragComplete,hMode});
        return;
    end
end

switch key
    case {8 127} % Backspace and Delete
        if hMode.ModeStateData.DeletePossible
            scribeccp(fig,'Delete');
        end
    otherwise
        curmod = evd.Modifier;
        if isempty(curmod) || any(strcmp(curmod,'shift'))
            graph2dhelper('forwardToCommandWindow',fig,evd);
        elseif strcmpi(curmod,accelModifier)
            if key == undoKey
                % Undo command
                hUndoMenu = findall(fig,'Type','UIMenu','Tag','figMenuEditUndo');
                if isempty(hUndoMenu)
                    uiundo(hMode.FigureHandle,'execUndo');
                end
            elseif key == redoKey
                % Redo command
                hRedoMenu = findall(fig,'Type','UIMenu','Tag','figMenuEditRedo');
                if isempty(hRedoMenu)
                    uiundo(hMode.FigureHandle,'execRedo');
                end
            % The menu item accelerators may not be linked up. In this case, call
            % the ^C, ^V, ^X callbacks from this method
            elseif (key == copyKey ) || (key == cutKey)
                % If the menu items are empty:
                if isempty(findall(fig,'Type','UIMenu','Tag','figMenuEditCopy')) || ...
                        isempty(findall(fig,'Type','UIMenu','Tag','figMenuEditCut'))

                    % cut copy disable/enable
                    if hMode.ModeStateData.CutCopyPossible;
                        if key == 3 %^C
                            scribeccp(fig,'Copy');
                        else
                            if hMode.ModeStateData.DeletePossible;
                                scribeccp(fig,'Cut');
                            end
                        end
                    end
                end
            elseif key == pasteKey
                % If the menu item is empty do the paste here
                if isempty(findall(fig,'Type','UIMenu','Tag','figMenuEditPaste'))
                    % Check if we can currently paste
                    % paste enable/disable
                    penable = false;
                    % cut copy disable/enable
                    if ~isempty(getappdata(0,'ScribeCopyBuffer'))
                        penable = hMode.ModeStateData.PastePossible;
                    end
                    if penable
                        scribeccp(fig,'Paste');
                    end
                end
            elseif key == selectAllKey
                if isempty(findall(fig,'Type','UIMenu','Tag','figMenuEditSelectAll'))
                    localSelectAll(hMode)
                end
            end
        end
end

%-----------------------------------------------------------------------%
function res = localIsArrowKey(key)
% Returns true if the key is an arrow key:

res = false;
if strcmpi(key,'uparrow') || strcmpi(key,'downarrow') || ...
        strcmpi(key,'leftarrow') || strcmpi(key,'rightarrow')
    res = true;
end

%-----------------------------------------------------------------------%
function localSelectAll(hMode)

fig = double(hMode.FigureHandle);
scribeax = handle(graph2dhelper('findScribeLayer',fig));
if any(ishghandle(scribeax)) && ~strcmpi(get(scribeax,'BeingDeleted'),'on')
    shapes = get(scribeax,'children');
    ax = findobj(get(fig,'children'),'flat','type','axes');
    if ~isempty(ax)
        axNonData = true(1,length(ax));
        for k=length(ax):-1:1
            axNonData(k) = isappdata(ax(k),'NonDataObject');
        end
        ax(axNonData) = [];
    end
    selectobject([shapes;ax],'replace');
end

%-----------------------------------------------------------------------%
function localWindowButtonDownFcn(obj,evd,hMode)
% Select the object that has been clicked on. In the case of holding <ctrl>
% or <shift> while clicking, this causes multi-selection.

% Restore the context menu:
localRestoreUIContextMenu(hMode);

currObj = localHittest(obj,evd);
% To make sure UIContextMenus appear in the right place, store a handle to
% the actual object.
uiContextObj = currObj;

% The object, however is the hggroup or hgtransform that was clicked on.
extraArgs = {};
if ~feature('HGUsingMATLABClasses')
    extraArgs = {'toplevel'};
end
clickedObject = handle(ancestor(currObj,{'hggroup','hgtransform'},extraArgs{:}));
if ~isempty(clickedObject)
    currObj = clickedObject;
end

figMod = get(obj,'CurrentModifier');

% Remove any stale handles in the mode selection:
localFixSelectedObjs(hMode);

selType = get(obj,'SelectionType');

% Here for reverse compatibility, but really should go away:
scribeax = graph2dhelper('findScribeLayer',obj);
if ~feature('HGUsingMATLABClasses')
    scribeax.ClickPoint = localGetPixelPoint(obj);
    scribeax.NClickPoint = localGetNormalizedPoint(obj);
end

% Return early if we don't have an object to click on.
if isempty(currObj)
    return;
end

% Check to see if the object handles the event:
% allow custom button down to handle the event
buttonDownHandled = false;
if isempty(hMode.ModeStateData.SelectedObjects)
    shape = [];
else
    shape = hMode.ModeStateData.SelectedObjects(currObj==hMode.ModeStateData.SelectedObjects);
end
if ~isempty(hMode.ModeStateData.SelectedObjects) && isscalar(hMode.ModeStateData.SelectedObjects) && ~isempty(shape)
    b = hggetbehavior(shape,'Plotedit','-peek');
    if ~isempty(b)
        bd = b.ButtonDownFcn;
        point = localGetNormalizedPoint(obj);
        if iscell(bd)
            buttonDownHandled = feval(bd{:},point);
        elseif ~isempty(bd)
            buttonDownHandled = feval(bd,shape,point);
        end
    end
end

if buttonDownHandled
    return;
end

% If there is no modifier, single-click replaces the currently selected
% object.
if strcmpi(selType,'normal') || strcmpi(selType,'Extend')
    % If the figure is the only object selected, treat the shift-click as
    % a single click.
    if isscalar(hMode.ModeStateData.SelectedObjects) && ...
            ishghandle(hMode.ModeStateData.SelectedObjects,'figure')
        figMod = [];
    end
    % If the modifier is "shift" or "command", deal with multi-selection
    if isscalar(figMod) && (strcmpi(figMod,'shift') || strcmpi(figMod,'command'))
        % If the object is currently selected, deselect it:
        % The figure is a special case to be ignored:
        if ishghandle(currObj,'figure')
            return;
        end
        if strcmpi(get(currObj,'Selected'),'on')
            selectobject(currObj,'off');
            % Default to the figure being selected if nothing else is
            % selected.
            if isempty(hMode.ModeStateData.SelectedObjects)
                selectobject(obj,'replace');
            end
        else
            if isa(currObj,'scribe.scribeobject')
                % The newly selected object should be placed at the top of the child order:
                hPar = get(currObj,'Parent');
                hChil = findall(hPar,'-depth',1);
                hChil(hChil == double(currObj)) = [];
                hChil = [double(currObj);hChil(2:end)];
                set(hPar,'Children',hChil);
            end
            selectobject(currObj,'on');
            % If we clicked on an object that is movable or has a behavior
            % defined, we should immediately start this behavior and not
            % wait for the user to click again.
            % Throw the mode into drag mode
            if hMode.ModeStateData.MovePossible
                if ismethod(currObj,'findMoveMode')
                    if ~feature('HGUsingMATLABClasses')
                        moveType = currObj.findMoveMode(localGetPixelPoint(obj));
                    else
                        moveType = currObj.findMoveMode(evd);
                    end
                else
                    moveType = localFindMoveModeNonScribeObject(currObj,localGetPixelPoint(obj));
                end
                if strcmpi(moveType,'mouseover')
                    localBeginMove(hMode,scribeax);
                    setptr(obj,localConvertMoveType('mouseover'));
                end
            end
        end
    else
        % Two possibilities here, we click on a new object:
        if strcmpi(currObj.Selected,'off') || ~any(hMode.ModeStateData.SelectedObjects == currObj)
            selectobject(currObj,'replace');
            if isa(currObj,'scribe.scribeobject')
                % The newly selected object should be placed at the top of the child order:
                currObj.moveToFront;
            end
            % If we clicked on an object that is movable or has a behavior
            % defined, we should immediately start this behavior and not
            % wait for the user to click again.
            % Throw the mode into drag mode, if the cursor should be there.
            if hMode.ModeStateData.MovePossible
                if ismethod(currObj,'findMoveMode')
                    if ~feature('HGUsingMATLABClasses')
                        moveType = currObj.findMoveMode(localGetPixelPoint(obj));
                    else
                        moveType = currObj.findMoveMode(evd);
                    end
                else
                    b = hggetbehavior(currObj,'Plotedit','-peek');
                    buttonDownHandled = false;
                    if ~isempty(b)
                        cb = b.MouseOverFcn;
                        if ~isempty(cb)
                            point = localGetNormalizedPoint(obj);
                            if iscell(cb)
                                cursor = feval(cb{:},point);
                            elseif ~isempty(cb)
                                cursor = feval(cb,hMode.ModeStateData.SelectedObjects,point);
                            end
                            scribecursors(obj,cursor)
                        end
                        bd = b.ButtonDownFcn;
                        if iscell(bd)
                            buttonDownHandled = feval(bd{:},point);
                        elseif ~isempty(bd)
                            buttonDownHandled = feval(bd,currObj,point);
                        end
                    end
                    if ~buttonDownHandled
                        moveType = localFindMoveModeNonScribeObject(currObj,localGetPixelPoint(obj));
                    else
                        moveType = 'none';
                    end
                end
                if strcmpi(moveType,'mouseover')
                    localBeginMove(hMode,scribeax);
                    setptr(obj,localConvertMoveType('mouseover'));
                end
            end
            % Or we are manipulating an already selected object or objects
        else
            moveProp = 'MoveMode';
            if feature('HGUsingMATLABClasses')
                moveProp = 'MoveStyle';
            end
            if ismethod(currObj,'findMoveMode')
                if ~isscalar(hMode.ModeStateData.SelectedObjects) && ...
                        ~strcmpi(currObj.(moveProp),'none')
                    moveType = 'mouseover';
                else
                    moveType = currObj.(moveProp);
                end
            else
                moveType = hMode.ModeStateData.NonScribeMoveMode;
            end
            % Check for the move type. "none" will cause no action, "mouseover" will
            % move the object and anything else will reshape the object
            if strcmpi(moveType,'none') || ~hMode.ModeStateData.MovePossible
            elseif strcmpi(moveType,'mouseover')
                localBeginMove(hMode,scribeax);
            else
                % For purposes of undo/redo, store the handles and position of
                % the object about to be resized:
                hMode.ModeStateData.OperationName = 'Resize';
                hMode.ModeStateData.OperationData.Handles = hMode.ModeStateData.SelectedObjects;
                hMode.ModeStateData.OperationData.Positions = get(hMode.ModeStateData.SelectedObjects,'Position');
                if strcmpi('on',getappdata(ancestor(scribeax,'figure'),'scribegui_snaptogrid')) && ...
                        isappdata(ancestor(scribeax,'figure'),'scribegui_snapgridstruct')
                    set(hMode,'WindowButtonMotionFcn',{@localSnapResizeWindowButtonMotionFcn,hMode});
                else
                    set(hMode,'WindowButtonMotionFcn',{@localResizeWindowButtonMotionFcn,hMode});
                end
                set(hMode,'WindowFocusLostFcn',{@localDragComplete,hMode});
                set(hMode,'WindowButtonUpFcn',{@localDragComplete,hMode});
            end
        end
    end

elseif strcmpi(selType,'alt')
    % Post the context-menu. For now, deal with the last object selected.
    % Clear out the context menu and rebuild it:
    if ~strcmpi(get(currObj,'Selected'),'on')
        selectobject(currObj,'replace');
    end

    % If we do not have anything selected, bail out.
    if isempty(hMode.ModeStateData.SelectedObjects)
        return;
    end

    % If there is a custom context-menu, don't jump through any hoops.
    if isscalar(hMode.ModeStateData.SelectedObjects)
        hB = hggetbehavior(currObj,'Plotedit','-peek');
        if ~isempty(hB) && hB.KeepContextMenu
            return;
        end
    end

    hChil = findall(hMode.UIContextMenu);
    hChil = hChil(2:end);
    set(hChil,'Visible','off','Enable','off');
    mergeMenus = false;
    allMenus = [];

    % Until we add a menu, the separator is "on"
    % If there is no preexisting context menu that we are merging with, the
    % separator should be "off". Note that we are only merging
    % context-menus if the object has a preexisting context menu and we are
    % only right-clicking on one object.
    if isscalar(hMode.ModeStateData.SelectedObjects) && ...
            ~isempty(get(uiContextObj,'UIContextMenu'))
        sep = 'on';
        mergeMenus = true;
    else
        sep = 'off';
    end

    % Special case: If we right-click on an axes, the "Add Data:" dialog
    % comes first, but only if we select *just* a single axes:
    if isscalar(hMode.ModeStateData.SelectedObjects) && ...
            ishghandle(hMode.ModeStateData.SelectedObjects,'axes')
        if usejava('awt') 
            hAddDataItem = localGetMenu(hMode,'AddData');
            set(hAddDataItem,'Separator',sep);
            set(hAddDataItem,'Visible','on','Enable','on');
            sep = 'on';
            allMenus(end+1) = hAddDataItem;
        end
    end

    % Find the cut/copy/paste and delete context menus
    cutMenu = localGetMenu(hMode,'Cut');
    if hMode.ModeStateData.CutCopyPossible
        set(cutMenu,'Separator',sep,'Visible','on','Enable','on');
        allMenus(end+1) = cutMenu;
        sep = 'off';
    else
        set(cutMenu,'Visible','off');
    end
    copyMenu = localGetMenu(hMode,'Copy');
    if hMode.ModeStateData.CutCopyPossible
        set(copyMenu,'Separator',sep,'Visible','on','Enable','on');
        allMenus(end+1) = copyMenu;
        sep = 'off';
    else
        set(copyMenu,'Visible','off');
    end
    pasteMenu = localGetMenu(hMode,'Paste');
    if hMode.ModeStateData.PastePossible
        set(pasteMenu,'Separator',sep,'Visible','on','Enable','on');
        allMenus(end+1) = pasteMenu;
        % If there is nothing to paste, disable the paste menu
        if ~isappdata(0,'ScribeCopyBuffer') || isempty(getappdata(0, 'ScribeCopyBuffer'))
            set(pasteMenu,'Enable','off');
        else
            set(pasteMenu,'Enable','on');
        end
        sep = 'off';
    else
        set(pasteMenu,'Visible','off');
    end
    clearAxesMenu = localGetMenu(hMode,'ClearAxes');
    if isscalar(hMode.ModeStateData.SelectedObjects) && ...
            ishghandle(hMode.ModeStateData.SelectedObjects,'axes')
        set(clearAxesMenu,'Separator',sep,'Visible','on','Enable','on');
        sep = 'off';
        allMenus(end+1) = clearAxesMenu;
    else
        set(clearAxesMenu,'Visible','off');
    end
    deleteMenu = localGetMenu(hMode,'Delete');
    if hMode.ModeStateData.DeletePossible
        set(deleteMenu,'Separator',sep,'Visible','on','Enable','on');
        allMenus(end+1) = deleteMenu;
    else
        set(deleteMenu,'Visible','off');
    end

    % In the case of scalar scribe objects being selected, we add a pin and
    % unpin menu item
    hChil = [];
    if isscalar(hMode.ModeStateData.SelectedObjects) && ...
            isprop(currObj,'PinContextMenu')
        hChil = double(currObj.PinContextMenu);
        if ~isempty(hChil)
            set(hChil(1),'Separator','on');
            set(findall(hChil),'Visible','on','Enable','on');
        end
    end
    allMenus = [allMenus(:);hChil(:)];

    % Use the scribe context-menu iff all objects share a common class.
    % Otherwise, stay heterogeneous.
    hChil = [];
    if isscalar(hMode.ModeStateData.SelectedObjects) || ...
            hMode.ModeStateData.IsHomogeneous
        if isprop(currObj,'ScribeContextMenu')
            hChil = double(currObj.ScribeContextMenu);
        else
            hChil = localGetNonScribeScribeContextMenu(hMode,currObj);
            localUpdateNonScribeContextMenu(currObj,hChil);
        end
        if ~isempty(hChil)
            set(hChil(1),'Separator','on');
            set(findall(hChil),'Visible','on','Enable','on');
        end
    end
    allMenus = [allMenus(:);hChil(:)];

    % Add an entry to bring up the property editor:
    hPropMenu = localGetPropEditMenu(hMode);
    if ~isempty(hPropMenu)
        allMenus(end+1) = hPropMenu;
        set(hPropMenu,'Separator','on');
        set(hPropMenu,'Visible','on','Enable','on');
    end

    % Add an entry for M-Code generation:
    hMCodeMenu = localGetMCodeMenu(hMode);
    set(hMCodeMenu,'Separator','on');
    if isscalar(hMode.ModeStateData.SelectedObjects)
        allMenus(end+1) = hMCodeMenu;
        set(hMCodeMenu,'Visible','on','Enable','on');
    else
        set(hMCodeMenu,'Visible','off');
    end

    % Make sure the context-menus appear in the proper order:
    allMenus = allMenus(:);
    allChil = findall(hMode.UIContextMenu,'-depth',1);
    nonChil = setdiff(allChil(2:end),allMenus);
    set(hMode.UIContextMenu,'Children',[allMenus(end:-1:1);nonChil(end:-1:1)]);

    % Update the UIContextMenu of the current object:
    localUpdateUIContextMenu(hMode,uiContextObj,mergeMenus);
end

%-----------------------------------------------------------------------%
function localBeginMove(hMode,scribeax)
% Start a move operation

obj = hMode.FigureHandle;

% For purposes of undo/redo, store the handles and position of
% the objects about to be moved:
hMode.ModeStateData.OperationName = 'Move';
hMode.ModeStateData.OperationData.Handles = handle(hMode.ModeStateData.SelectedObjects);
hMode.ModeStateData.OperationData.Positions = get(hMode.ModeStateData.SelectedObjects,'Position');
if strcmpi('on',getappdata(ancestor(scribeax,'figure'),'scribegui_snaptogrid')) && ...
        isappdata(ancestor(scribeax,'figure'),'scribegui_snapgridstruct')
    set(hMode,'WindowButtonMotionFcn',{@localSnapMoveWindowButtonMotionFcn,hMode});
    % Prime the base move points for all the selected
    % objects
    hMode.ModeStateData.BasePoints = repmat(localGetPixelPoint(obj),length(hMode.ModeStateData.SelectedObjects),1);
else
    set(hMode,'WindowButtonMotionFcn',{@localMoveWindowButtonMotionFcn,hMode});
    % Cache the current point
    hMode.ModeStateData.CurrPoint = localGetPixelPoint(obj);
end
set(hMode,'WindowButtonUpFcn',{@localDragComplete,hMode});


%-----------------------------------------------------------------------%
function localUpdateUIContextMenu(hMode,objHandle,mergeMenus)
% Given an object, either merge its context-menu with the context-menu of
% the mode or replace its context-menu with the context-menu of the mode.

% Cache the handle:
hMode.ModeStateData.CurrentUIContextMenuObject = objHandle;
% Two options, either we replace the context-menu, or we merge it with the
% existing menu.
currentMenu = get(objHandle,'UIContextMenu');
if ~mergeMenus || isempty(currentMenu);
    hMode.ModeStateData.AddedUIContextMenuHandles = [];
    hMode.ModeStateData.CachedUIContextMenu = currentMenu;
    set(objHandle,'UIContextMenu',hMode.UIContextMenu);
else
    % Reparent the children of the mode's context-menu to the context-menu
    % of the object if this has not already been done:
    if isempty(hMode.ModeStateData.AddedUIContextMenuHandles)
        hMenuEntries = findall(hMode.UIContextMenu,'-depth',1);
        % Findall reverses the order of objects, so reverse it again.
        hMenuEntries = hMenuEntries(end:-1:2);
        set(hMenuEntries,'Parent',currentMenu);
        hMode.ModeStateData.AddedUIContextMenuHandles = hMenuEntries;
    end
end

%-----------------------------------------------------------------------%
function localRestoreUIContextMenu(hMode)
% Restore the UIContextMenu on an object

if isempty(hMode.ModeStateData.CurrentUIContextMenuObject) || ...
        ~ishandle(hMode.ModeStateData.CurrentUIContextMenuObject)
    return;
end

% Two possibilities - Either we reparent some UIMenu entries (we merged),
% or we restore a context menu (we replaced).
if isempty(hMode.ModeStateData.AddedUIContextMenuHandles)
    set(hMode.ModeStateData.CurrentUIContextMenuObject, 'UIContextMenu', ...
        hMode.ModeStateData.CachedUIContextMenu);
    hMode.ModeStateData.CachedUIContextMenu = [];
else
    hMenuEntries = hMode.ModeStateData.AddedUIContextMenuHandles;
    hMenuEntries(~ishandle(hMenuEntries)) = [];
    set(hMenuEntries,'Parent',hMode.UIContextMenu);
    hMode.ModeStateData.AddedUIContextMenuHandles = [];
end

% Be sure to reset the current object state here. We may enter this
% function multiple times without a button down.
hMode.ModeStateData.CurrentUIContextMenuObject = [];

%-----------------------------------------------------------------------%
function hMenu = localGetMCodeMenu(hMode)
% Sets up the M-code menu and returns the menu.

if isdeployed
    hMenu = [];
    return;
end

hMenu = findall(hMode.UIContextMenu,'Tag','ScribeMCodeGeneration');
if ~isempty(hMenu)
    return;
end
% If the menu hasn't already been created, create the new menu.
hMenu = uimenu(hMode.UIContextMenu,'HandleVisibility','off',...
    'Label','Show Code','Callback',{@localGenerateMCode,hMode},...
    'Tag','ScribeMCodeGeneration','Visible','off');

%-----------------------------------------------------------------------%
function localGenerateMCode(obj,evd,hMode) %#ok<INUSL>
% Generate code for the selected object.

makemcode(hMode.ModeStateData.SelectedObjects,'Output','-editor')

%-----------------------------------------------------------------------%
function hMenu = localGetPropEditMenu(hMode)
% Sets up the property editor menu and returns the menu.

if isdeployed || ~usejava('awt')
    hMenu = [];
    return;
end

hMenu = findall(hMode.UIContextMenu,'Tag','ScribePropertyEditor');
if ~isempty(hMenu)
    return;
end
% If the menu hasn't already been created, create the new menu.
hMenu = uimenu(hMode.UIContextMenu,'HandleVisibility','off',...
    'Label','Show Property Editor','Callback',{@localOpenPropertyEditor,hMode},...
    'Tag','ScribePropertyEditor','Visible','off');

%-----------------------------------------------------------------------%
function localOpenPropertyEditor(obj,evd,hMode) %#ok<INUSL>
% Opens the property editor for the currently selected objects:

propedit(hMode.ModeStateData.SelectedObjects,'-noselect');

%-----------------------------------------------------------------------%
function hMenu = localGetMenu(hMode,action)
% Sets up the generic cut/copy/paste menus and return the menu specified by
% action.

hMenu = findall(hMode.UIContextMenu,'Tag',sprintf('ScribeGenericAction%s',action));
if ~isempty(hMenu)
    return;
end
% If the menu hasn't already been created, create the new menus. Cut comes
% first:
hCutMenu = uimenu(hMode.UIContextMenu,'HandleVisibility','off',...
    'Label','Cut','Callback',{@localCallFunction,hMode,@scribeccp,hMode.FigureHandle,'Cut'},...
    'Tag','ScribeGenericActionCut','Visible','off');
if strcmpi(action,'Cut')
    hMenu = hCutMenu;
end
% Next, Copy
hCopyMenu = uimenu(hMode.UIContextMenu,'HandleVisibility','off',...
    'Label','Copy','Callback',{@localCallFunction,hMode,@scribeccp,hMode.FigureHandle,'Copy'},...
    'Tag','ScribeGenericActionCopy','Visible','off');
if strcmpi(action,'Copy')
    hMenu = hCopyMenu;
end
% Next Paste
hPasteMenu = uimenu(hMode.UIContextMenu,'HandleVisibility','off',...
    'Label','Paste','Callback',{@localCallFunction,hMode,@scribeccp,hMode.FigureHandle,'Paste'},...
    'Tag','ScribeGenericActionPaste','Visible','off');
if strcmpi(action,'Paste')
    hMenu = hPasteMenu;
end
% Next, Clear Axes
hClearMenu = uimenu(hMode.UIContextMenu,'HandleVisibility','off',...
    'Label','Clear Axes','Callback',{@localClearAxes,hMode},...
    'Tag','ScribeGenericActionClearAxes','Visible','off');
if strcmpi(action,'ClearAxes')
    hMenu = hClearMenu;
end
% Next, Delete
hDeleteMenu = uimenu(hMode.UIContextMenu,'HandleVisibility','off',...
    'Label','Delete','Callback',{@localCallFunction,hMode,@scribeccp,hMode.FigureHandle,'Delete'},...
    'Tag','ScribeGenericActionDelete');
if strcmpi(action,'Delete')
    hMenu = hDeleteMenu;
end
% Next, Add Data
hAddDataMenu = graph2dhelper('createScribeUIMenuEntry',hMode.FigureHandle,'AddData','Add Data...','','');
set(hAddDataMenu,'Parent',hMode.UIContextMenu,'Tag','ScribeGenericActionAddData');
if strcmpi(action,'AddData')
    hMenu = hAddDataMenu;
end

%-----------------------------------------------------------------------%
function localClearAxes(obj,evd,hMode) %#ok<INUSL>
% Clears the current axes and clears the undo stack
hFig = hMode.FigureHandle;
cla(hMode.ModeStateData.SelectedObjects);
% Clear the undo stack
uiundo(hFig,'clear');

%-----------------------------------------------------------------------%
function localCallFunction(obj,evd,hMode,varargin) %#ok<INUSL>
% First, restore the context-menu:
localRestoreUIContextMenu(hMode);
% Forwards a callback to the scribeccp function
feval(varargin{1},varargin{2:end});

%-----------------------------------------------------------------------%
function localSnapResizeWindowButtonMotionFcn(obj,evd,hMode)
% Since you can't resize multi-selected objects, just resize the first
% selected object. The resize will only take place if the snap to grid
% behavior will allow it.

if isempty(hMode.ModeStateData.SelectedObjects) || ...
        ~ishghandle(hMode.ModeStateData.SelectedObjects(1))
    return;
end

% Only execute the resize if the pointer is within the figure window.
currObj = hMode.ModeStateData.SelectedObjects(1);
currPoint = evd.CurrentPoint;
hAncestor = handle(get(currObj,'Parent'));
if ~ishghandle(hAncestor,'figure') && ~ishghandle(hAncestor,'uipanel')
    hAncestor = handle(obj);
end
ancPos = localGetAncestorPosition(hAncestor);
currPoint = currPoint - ancPos(1:2);

currPoint = hgconvertunits(obj,[currPoint 0 0],'pixels','normalized',hAncestor);
currPoint = currPoint(1:2);
if currPoint(1) < 0.0 || currPoint(1) > 1.0 || ...
        currPoint(2) < 0.0 || currPoint(2) > 1.0
    return
end

% Get grid structure values
gridstruct = getappdata(obj,'scribegui_snapgridstruct');
xspace = gridstruct.xspace;
yspace = gridstruct.yspace;
influ = gridstruct.influence;

if isprop(currObj,'MoveMode')
    MoveType = lower(get(currObj,'MoveMode'));
else
    MoveType = lower(hMode.ModeStateData.NonScribeMoveMode);
end

% Given the point and the move type, we want to snap to either the nearest
% corner (for the corner move types) or the nearest horizontal or vertical
% line
currPoint = evd.CurrentPoint;

switch MoveType
    case {'topleft','topright','bottomleft','bottomright'}
        % e.g. moving the upper left affordance
        % changes the left x and upper y
        xPoint = false;
        yPoint = false;
        xoff = mod(currPoint(1),xspace);
        yoff = mod(currPoint(2),yspace);
        if xoff>(xspace/2)
            xoff = xoff - xspace;
        end
        if xoff<influ
            currPoint(1) = (round(currPoint(1)/xspace) * xspace);
            xPoint = true;
        end
        if yoff>(yspace/2)
            yoff = yoff - yspace;
        end
        if yoff<influ
            currPoint(2) = (round(currPoint(2)/yspace) * yspace);
            yPoint = true;
        end
        % If we are not snapping to a corner, return
        if ~(xPoint && yPoint)
            return;
        end
    case {'left','right'}
        xPoint = false;
        xoff = mod(currPoint(1),xspace);
        if xoff>(xspace/2)
            xoff = xoff - xspace;
        end
        if xoff<influ
            currPoint(1) = (round(currPoint(1)/xspace) * xspace);
            xPoint = true;
        end
        % If we are not snapping to a line, return
        if ~xPoint
            return;
        end
    case {'top','bottom'}
        yPoint = false;
        yoff = mod(currPoint(2),yspace);
        if yoff>(yspace/2)
            yoff = yoff - yspace;
        end
        if yoff<influ
            currPoint(2) = (round(currPoint(2)/yspace) * yspace);
            yPoint = true;
        end
        % If we are not snapping to a line, return
        if ~yPoint
            return;
        end
    otherwise
        return;
end

if ismethod(currObj,'resize')
    currObj.resize(currPoint);
else
    localResizeNonScribeObject(currObj,currPoint,hMode.ModeStateData.NonScribeMoveMode);
end

%-----------------------------------------------------------------------%
function localResizeWindowButtonMotionFcn(obj,evd,hMode)
% Since you can't resize multi-selected objects, just resize the first
% selected object.

% Make sure we have valid handles, otherwise explosions may occur:
localFixSelectedObjs(hMode);

if isempty(hMode.ModeStateData.SelectedObjects) || ...
        ~ishghandle(hMode.ModeStateData.SelectedObjects(1))
    return;
end

% Only execute the resize if the pointer is within the figure window.
currObj = hMode.ModeStateData.SelectedObjects(1);
currPoint = evd.CurrentPoint;
hAncestor = handle(get(currObj,'Parent'));
if ~ishghandle(hAncestor,'figure') && ~ishghandle(hAncestor,'uipanel')
    hAncestor = handle(obj);
end
ancPos = localGetAncestorPosition(hAncestor);
currPoint = currPoint - ancPos(1:2);
currPoint = hgconvertunits(obj,[currPoint 0 0],'pixels','normalized',hAncestor);
currPoint = currPoint(1:2);
if currPoint(1) < 0.0 || currPoint(1) > 1.0 || ...
        currPoint(2) < 0.0 || currPoint(2) > 1.0
    return
end
if ismethod(currObj,'resize')
    currObj.resize(evd.CurrentPoint);
else
    localResizeNonScribeObject(currObj,evd.CurrentPoint,hMode.ModeStateData.NonScribeMoveMode);
end

%-----------------------------------------------------------------------%
function ancPos = localGetAncestorPosition(hPar)
% Returns the position (in pixels) of the bottom-left corner of the
% ancestor with respect to the figure.

ancPos = [0 0 0 0];
hFig = ancestor(hPar,'Figure');
while ~ishghandle(hPar,'figure')
    ancPos = ancPos + hgconvertunits(hFig,get(hPar,'Position'),get(hPar,'Units'),'Pixels',get(hPar,'Parent'));
    hPar = handle(get(hPar,'Parent'));
end


%-----------------------------------------------------------------------%
function localDragComplete(obj,evd,hMode)
% Reset the Window Motion and Button Callbacks after a move or a resize:

if ~ishghandle(obj,'figure')
    obj = hMode.FigureHandle;
end

set(hMode,'WindowButtonUpFcn',{@localWindowButtonUpFcn,hMode});
set(hMode,'WindowButtonMotionFcn',{@localNonDragWindowButtonMotionFcn,hMode});
set(hMode,'WindowFocusLostFcn','');
set(hMode,'WindowKeyReleaseFcn','');

hMode.ModeStateData.isMoving = false;

% Restore the units of any text objects that we had to change:
hTextHandles = hMode.ModeStateData.MovingTextHandles;
hTextHandles = hTextHandles(ishghandle(hTextHandles));
set(hTextHandles,'Units','Data');
if ~feature('HGUsingMATLABClasses')
    hMode.ModeStateData.MovingTextHandles = handle([]);
else
    hMode.ModeStateData.MovingTextHandles = getEmptyHandleVector;
end

% Allow custom button up
buttonUpHandled = false;

% Make sure we have valid handles, otherwise explosions may occur:
localFixSelectedObjs(hMode);

if isscalar(hMode.ModeStateData.SelectedObjects)
    shape = hMode.ModeStateData.SelectedObjects;
    if ~isempty(shape) && all(ishghandle(shape))
        b = hggetbehavior(shape,'Plotedit','-peek');
        if ~isempty(b)
            point = localGetNormalizedPoint(obj);
            cb = b.ButtonUpFcn;
            if iscell(cb)
                buttonUpHandled = feval(cb{:},point);
            elseif ~isempty(cb)
                buttonUpHandled = feval(cb,shape,point);
            end
        else
            buttonUpHandled = localHandleButtonUp(hMode);
        end
    end
end

if buttonUpHandled
    return;
end

% If the positions have changed (i.e., we didn't double-click), register
% with undo/redo
hObjs = hMode.ModeStateData.OperationData.Handles;
positions = hMode.ModeStateData.OperationData.Positions;
positions(~ishghandle(hObjs)) = [];
hObjs = hObjs(ishghandle(hObjs));
hMode.ModeStateData.OperationData.Handles = hObjs;
hMode.ModeStateData.OperationData.Positions = positions;
if isempty(hObjs)
    return;
end
newPos = get(hObjs,'Position');
if ~isequal(newPos,positions)
    localConstructPositionalUndo(hMode,newPos);
end

% If we double-click, forward the event to the regular button-up function
% for appropriate handling.
if strcmpi(get(obj,'SelectionType'),'Open')
    localWindowButtonUpFcn(obj,evd,hMode);
end

%-----------------------------------------------------------------------%
function localWindowButtonUpFcn(obj,evd,hMode) %#ok<INUSL>
% If we double-click on an object or the object has a button-up function,
% this needs to be handled:

% Make sure we have valid handles, otherwise explosions may occur:
localFixSelectedObjs(hMode);

% Allow custom button up
buttonUpHandled = false;
if isscalar(hMode.ModeStateData.SelectedObjects)
    shape = hMode.ModeStateData.SelectedObjects;
    if ~isempty(shape)
        if ismethod(shape,'scribeButtonUpFcn')
            point = localGetNormalizedPoint(obj);
            buttonUpHandled = shape.scribeButtonUpFcn(point);
        else
            b = hggetbehavior(shape,'Plotedit','-peek');
            if ~isempty(b)
                point = localGetNormalizedPoint(obj);
                cb = b.ButtonUpFcn;
                if iscell(cb)
                    buttonUpHandled = feval(cb{:},point);
                elseif ~isempty(cb)
                    buttonUpHandled = feval(cb,shape,point);
                end
            else
                buttonUpHandled = localHandleButtonUp(hMode);
            end
        end
    end
end

if buttonUpHandled
    return;
end

selType = get(obj,'SelectionType');

if strcmpi(selType,'Open')
    % If we double-click on an object, open the property editor
    if usejava('awt')
        propedit(hMode.ModeStateData.SelectedObjects,'-noselect');
    end
end

%--------------------------------------------------------------------%
function handled = localHandleButtonUp(hMode)
% If we clicked on a text object and the selection type is "open", inform
% the mode that we will handle this and not use the default action.

handled = false;
shape = hMode.ModeStateData.SelectedObjects;
if ishghandle(shape,'text') && ...
        strcmpi(get(hMode.FigureHandle,'SelectionType'),'open')
    handled = true;
    set(shape,'Editing','on');
end

%--------------------------------------------------------------------%
function point = localGetNormalizedPoint(hFig)
% Convert the current point to normalized units

y = hgconvertunits(hFig,[get(hFig,'CurrentPoint') 1 1],get(hFig,'Units'),...
    'normalized',hFig);
point = y(1:2);

%--------------------------------------------------------------------%
function point = localGetPixelPoint(hFig)
% Convert the current point to normalized units

y = hgconvertunits(hFig,[get(hFig,'CurrentPoint') 1 1],get(hFig,'Units'),...
    'Pixels',hFig);
point = y(1:2);

%-----------------------------------------------------------------------%
function localConstructPositionalUndo(hMode,newPos)
% Given a new position, construct an undo/redo operation and add it to the
% stack.

% First, convert the handles into their proxy representation.
handleList = hMode.ModeStateData.OperationData.Handles;
proxyList = zeros(size(handleList));
% Store the handle proxies rather than the handles
for i = 1:length(handleList)
    proxyList(i) = hMode.ModeStateData.ChangedObjectProxy(hMode.ModeStateData.ChangedObjectHandles == handle(handleList(i)));
end

% Create command structure
cmd.Name = hMode.ModeStateData.OperationName;
cmd.Function = @localUpdatePosition;
cmd.Varargin = {hMode,proxyList,newPos};
cmd.InverseFunction = @localUpdatePosition;
cmd.InverseVarargin = {hMode,proxyList,hMode.ModeStateData.OperationData.Positions};

% Register with undo/redo
uiundo(hMode.FigureHandle,'function',cmd);
% Clear the Operation Data:
hMode.ModeStateData.OperationData = [];

%-----------------------------------------------------------------------%
function localUpdatePosition(hMode,proxyList,positionList)
% Given a proxy list, set the position property of the associated handles

if ~iscell(positionList)
    positionList = {positionList};
end

for i = 1:length(proxyList)
    currObj = hMode.ModeStateData.ChangedObjectHandles(hMode.ModeStateData.ChangedObjectProxy == proxyList(i));
    if ishghandle(currObj)
        set(currObj,'Position',positionList{i});
    end
end

%-----------------------------------------------------------------------%
function localNonDragWindowButtonMotionFcn(obj,evd,hMode)
% The Mouse motion function for when we are not in a drag-mode

% Only call the plot edit behavior if the current object is selected.
currObj = hMode.ModeStateData.SelectedObjects(evd.CurrentObject==hMode.ModeStateData.SelectedObjects);

% If we are in an object's drag mode, short-circuit and call its
% MouseMotionFcn.
% Allow custom button up
motionHandled = false;
if isscalar(hMode.ModeStateData.SelectedObjects)
    shape = currObj;
    if ~isempty(shape)
        b = hggetbehavior(shape,'Plotedit','-peek');
        if ~isempty(b)
            point = hgconvertunits(obj,[1 1 evd.CurrentPoint],'Pixels','Normalized',obj);
            point = point(3:4);
            cb = b.MouseMotionFcn;
            if iscell(cb)
                motionHandled = feval(cb{:},point);
            elseif ~isempty(cb)
                motionHandled = feval(cb,shape,point);
            end
        end
    end
end

if motionHandled
    return;
end

% If we are over a selected object, determine which pointer to use:
cursor = 0;
% If we can't move, don't show the affordance. We also can't resize.
if ~isempty(currObj) && ~ishghandle(currObj,'figure') && hMode.ModeStateData.MovePossible
    % Scribe objects have a method called "findMoveMode", which queries and
    % sets the "MoveMode" property of the object
    if ismethod(currObj,'findMoveMode')
        if ~feature('HGUsingMATLABClasses')
            moveType = currObj.findMoveMode(evd.CurrentPoint);
        else
            moveType = currObj.findMoveMode(evd);
        end
    else
        % Objects may have a "MouseOverFcn" defined. The catch is that we
        % can only call this during single-selection mode. Otherwise
        % undefined things may happen.
        if isscalar(hMode.ModeStateData.SelectedObjects)
            b = hggetbehavior(hMode.ModeStateData.SelectedObjects,'Plotedit','-peek');
            if ~isempty(b)
                cb = b.MouseOverFcn;
                point = hgconvertunits(obj,[1 1 evd.CurrentPoint],'Pixels','Normalized',obj);
                point = point(3:4);
                if iscell(cb)
                    cursor = feval(cb{:},point);
                elseif ~isempty(cb)
                    cursor = feval(cb,hMode.ModeStateData.SelectedObjects,point);
                end
            end
        end
        if isequal(cursor,0)
            moveType = localFindMoveModeNonScribeObject(currObj,evd.CurrentPoint,hMode);
        end
    end
    % If multiple objects are selected, we can not resize, so the mouse
    % pointer should reflect this.
    if ~isscalar(hMode.ModeStateData.SelectedObjects) && ...
            ~strcmpi(moveType,'none')
        moveType = 'mouseover';
    end
    if isequal(cursor,0)
        setptr(obj,localConvertMoveType(moveType));
    else
        scribecursors(obj,cursor);
    end
else
    setptr(obj,'arrow');
end

%-----------------------------------------------------------------------%
function localSnapMoveWindowButtonMotionFcn(obj,evd,hMode) %#ok<INUSL>
% Move the selected objects with respect to the layout grid. This is a
% 2-pass approach. First, see if the objects may be moved. If they can be
% moved, move them.

% Make sure we have valid handles, otherwise explosions may occur:
localFixSelectedObjs(hMode);

selObjs = hMode.ModeStateData.SelectedObjects;
currPoints = repmat(evd.CurrentPoint,length(selObjs),1);
delta = currPoints - hMode.ModeStateData.BasePoints;
localDoSnapMove(hMode,delta,true,currPoints);

%-----------------------------------------------------------------------%
function localDoSnapMove(hMode,delta,updatePoint,currPoints)

% For each selected object, see if we can move.
mayMove = true;
selObjs = hMode.ModeStateData.SelectedObjects;

updateBasePoint = false(length(selObjs),1);
hFig = hMode.FigureHandle;

for i = 1:length(selObjs)
    [willSnap delta(i,:)] = localWillSnap(hFig,selObjs(i),delta(i,:));
    if willSnap
        updateBasePoint(i) = true;
    else
        continue;
    end
    if ismethod(selObjs(i),'mayMove')
        if ~selObjs(i).mayMove(delta(i,:))
            mayMove = false;
            break;
        end
    else
        % Text objects with their units set to "data" must be converted to
        % something other than "data". We will use pixels.
        if ishghandle(selObjs(i),'text') && strcmpi(get(selObjs(i),'Units'),'Data')
            hMode.ModeStateData.MovingTextHandles(end+1) = handle(selObjs(i));
            set(selObjs(i),'Units','pixels');
        end
        if ~localMayMoveNonScribeObject(selObjs(i),delta(i,:));
            mayMove = false;
            break;
        end
    end
end

if ~mayMove
    return;
end

for i = 1:length(selObjs)
    if ~updateBasePoint(i)
        continue;
    end
    % Update the base point:
    if updatePoint
        hMode.ModeStateData.BasePoints(i,:) = currPoints(i,:);
    end
    if ismethod(selObjs(i),'move')
        move(selObjs(i),delta(i,:));
    else
        localMoveNonScribeObject(selObjs(i),delta(i,:));
    end
end

%-----------------------------------------------------------------------%
function [update, delta] = localWillSnap(hFig,h,delta)
% Helper function to determine whether moving an object the specified
% distance will cause it to snap to a grid point

% Get grid structure values
gridstruct = getappdata(hFig,'scribegui_snapgridstruct');
snaptype = gridstruct.snapType;
xspace = gridstruct.xspace;
yspace = gridstruct.yspace;
influ = gridstruct.influence;

% Initialize pixel center position (same as h.PX for scriberect)
hAncestor = handle(get(h,'Parent'));
hFig = ancestor(h,'Figure');
if ~ishghandle(hAncestor,'figure') && ~ishghandle(hAncestor,'uipanel')
    hAncestor = hFig;
end

if ishghandle(h,'text')
    tUnits = get(h,'Units');
    set(h,'Units','Pixels');
    tPos = get(h,'Position');
    set(h,'Units',tUnits);
    hppos(1:2) = tPos(1:2);
    ext = get(h,'extent');
    % for calculations, set hppos(3) and (4) from extent
    hppos(3) = ext(3); hppos(4) = ext(4);
else
    hppos = hgconvertunits(hFig,get(h,'Position'),get(h,'Units'),'Pixels',hAncestor);
end

% Compute the center of the object
HPX=hppos(1) + hppos(3)/2; HPY=hppos(2) + hppos(4)/2;
PX = HPX; PY = HPY;

% Initial pixel position - of center
IPX = PX + delta(1);
IPY = PY + delta(2);

% Calculate the Snap-to positions.
switch snaptype
    case 'top'
        SX = IPX;
        SY = IPY + hppos(4)/2;
    case 'bottom'
        SX = IPX;
        SY = IPY - hppos(4)/2;
    case 'left'
        SX = IPX - hppos(3)/2;
        SY = IPY;
    case 'right'
        SX = IPX + hppos(3)/2;
        SY = IPY;
    case 'center'
        SX = IPX;
        SY = IPY;
    case 'topleft'
        SX = IPX - hppos(3)/2;
        SY = IPY + hppos(4)/2;
    case 'topright'
        SX = IPX + hppos(3)/2;
        SY = IPY + hppos(4)/2;
    case 'bottomleft'
        SX = IPX - hppos(3)/2;
        SY = IPY - hppos(4)/2;
    case 'bottomright'
        SX = IPX + hppos(3)/2;
        SY = IPY - hppos(4)/2;
end

xoff = mod(SX,xspace);
yoff = mod(SY,yspace);
if xoff>(xspace/2)
    xoff = xoff - xspace;
end
if yoff>(yspace/2)
    yoff = yoff - yspace;
end
update=false;
% Calculate new center X
if xoff < influ % within influence do a snap move
    % get snapped center x
    switch snaptype
        case {'top','bottom','center'}
            PX = (round(SX/xspace) * xspace);
        case {'left','topleft','bottomleft'}
            PX = (round(SX/xspace) * xspace) + hppos(3)/2;
        case {'right','topright','bottomright'}
            PX = (round(SX/xspace) * xspace) - hppos(3)/2;
    end
    if abs(HPX - PX) > 1 % We require at least a 1-pixel change
        update=true;
    end
elseif abs(IPX - HPX) > 1 % otherwise a normal move
    PX = IPX;
    update=true;
end
% Calculate new center Y
if yoff < influ
    % switch again here for snaptype
    switch snaptype
        case {'top','topleft','topright'}
            PY = (round(SY/yspace) * yspace) - hppos(4)/2;
        case {'bottom','bottomleft','bottomright'}
            PY = (round(SY/yspace) * yspace) + hppos(4)/2;
        case {'left','right','center'}
            PY = (round(SY/yspace) * yspace);
    end
    if abs(HPY - PY) > 1 % We require at least a 1-pixel change
        update=true;
    end
elseif abs(IPY - PY) > 1 % otherwise a normal move
    PY = IPY;
    update=true;
end

% If we update, return the snap delta as well
if update
    newX = PX - hppos(3)/2;
    newY = PY - hppos(4)/2;
    delta = [newX - hppos(1), newY - hppos(2)];
end

%-----------------------------------------------------------------------%
function localMoveWindowButtonMotionFcn(obj,evd,hMode) %#ok<INUSL>
% Move the selected objects. This is a 2-pass approach. First, see if the
% objects may be moved. If they can be moved, move them.

currPoint = evd.CurrentPoint;
delta = currPoint - hMode.ModeStateData.CurrPoint;
localDoMove(hMode,delta,true,currPoint);

%-----------------------------------------------------------------------%
function localDoMove(hMode,delta,updatePoint,currPoint)

% Make sure we have valid handles, otherwise explosions may occur:
localFixSelectedObjs(hMode);

% For each selected object, see if we can move.
mayMove = true;
selObjs = hMode.ModeStateData.SelectedObjects;
for i = 1:length(selObjs)
    if ismethod(selObjs(i),'mayMove')
        if ~selObjs(i).mayMove(delta)
            mayMove = false;
            break;
        end
    else
        % Text objects with their units set to "data" must be converted to
        % something other than "data". We will use pixels.
        if ishghandle(selObjs(i),'text') && strcmpi(get(selObjs(i),'Units'),'Data')
            hMode.ModeStateData.MovingTextHandles(end+1) = handle(selObjs(i));
            set(selObjs(i),'Units','pixels');
        end
        if ~localMayMoveNonScribeObject(selObjs(i),delta);
            mayMove = false;
            break;
        end
    end
end

if ~mayMove
    return;
end

if updatePoint
    % Update the current point:
    hMode.ModeStateData.CurrPoint = currPoint;
end

for i = 1:length(selObjs)
    if ismethod(selObjs(i),'move')
        move(selObjs(i),delta);
    else
        localMoveNonScribeObject(selObjs(i),delta);
    end
end

%-----------------------------------------------------------------------%
function moveType = localFindMoveModeNonScribeObject(obj,point,hMode)
% Given a non-scribe object, figure out which affordance (if any) we are
% over or what the move type should be.

% Unless we are over an affordance, move-type will be "mouseover" with few
% exceptions:
moveType = 'none';

% Do some short-circuiting: If the object is a text object, it cannot be
% resized, so "moveType" will always be 'mouseover':
if ishghandle(obj,'text')
    moveType = 'mouseover';
    hMode.ModeStateData.NonScribeMoveMode = moveType;
    return;
end

% Get the position of the object in pixels
hAncestor = handle(get(obj,'Parent'));
hFig = ancestor(obj,'Figure');
if ~ishghandle(hAncestor,'figure') && ~ishghandle(hAncestor,'uipanel')
    hAncestor = hFig;
end
objPos = hgconvertunits(hFig,get(obj,'Position'),get(obj,'Units'),'Pixels',hAncestor);
if ~ishghandle(hAncestor,'figure')
    ancPos = hgconvertunits(hFig,get(hAncestor,'Position'),get(hAncestor,'Units'),'Pixels',hFig);
else
    ancPos = [0 0 0 0];
end
objPos(1:2) = objPos(1:2)+ancPos(1:2);
if ~ishghandle(obj,'axes') && isprop(obj,'PixelBounds')
    % don't use pixel bounds for axes. The extra space for the ticks
    % offsets the pixelbounds from the affordances
    % for all else use pixel bounds
    % get pixel bounds of object
    pixBounds = get(obj,'PixelBounds');
    % calculate pixel position of object in figure
    % pixel bounds = [left, top(from fig top), right, bottom (from fig top)]
    figPos = hgconvertunits(hFig,get(hFig,'Position'),get(hFig,'Units'),'Pixels',hAncestor);
    objPos = [pixBounds(1),figPos(4)-pixBounds(4),pixBounds(3)-pixBounds(1),pixBounds(4)-pixBounds(2)];
end

% rectangle center in pixel coords
XC = objPos(1) + objPos(3)/2;
YC = objPos(2) + objPos(4)/2;

% calc x and y limits of rectangle in pixel coords
XL = objPos(1);
XR = objPos(1) + objPos(3);
YU = objPos(2) + objPos(4);
YL = objPos(2);

% Store point in pixels:
px = point(1);
py = point(2);

a2 = 4; % half pixel afsiz;

% test if mouse over main rect area
if XL <= px && px <= XR && ...
        YL <= py && py <= YU
    moveType = 'mouseover';
    % Axes are special:
    if ishghandle(obj,'axes')
        hB = hggetbehavior(obj,'Plotedit','-peek');
        % If the behavior does not allow interiror move, the moveType is set
        % back to 'none' pending the edge check
        if isempty(hB) || ~hB.AllowInteriorMove
            moveType = 'none';
        end
    end
end

% test if mouse over the boundary of the position rect
if (any(abs([XL XR]-px) <= a2) && YL <= py && py <= YU) || ...
        (any(abs([YL YU]-py) <= a2) && XL <= px && px <= XR)
    moveType = 'mouseover';
end

% test if mouse over affordances
% return when first one is found
% upper left
if XL - a2 <= px && px <= XL + a2 && ...
        YU - a2 <= py && py <= YU + a2
    moveType = 'topleft';
    % upper right
elseif XR - a2 <= px && px <= XR + a2 && ...
        YU - a2 <= py && py <= YU + a2
    moveType = 'topright';
    % lower right
elseif XR - a2 <= px && px <= XR + a2 && ...
        YL - a2 <= py && py <= YL + a2
    moveType = 'bottomright';
    % lower left
elseif XL - a2 <= px && px <= XL + a2 && ...
        YL - a2 <= py && py <= YL + a2
    moveType = 'bottomleft';
    % left
elseif XL - a2 <= px && px <= XL + a2 && ...
        YC - a2 <= py && py <= YC + a2
    moveType = 'left';
    % top
elseif XC - a2 <= px && px <= XC + a2 && ...
        YU - a2 <= py && py <= YU + a2
    moveType = 'top';
    % right
elseif XR - a2 <= px && px <= XR + a2 && ...
        YC - a2 <= py && py <= YC + a2
    moveType = 'right';
    % bottom
elseif XC - a2 <= px && px <= XC + a2 && ...
        YL - a2 <= py && py <= YL + a2
    moveType = 'bottom';
end

hMode.ModeStateData.NonScribeMoveMode = moveType;

%-----------------------------------------------------------------------%
function res = localMayMoveNonScribeObject(obj,delta)
% Given an object and a delta (in pixel coordinates), determine whether
% moving the object by the specified delta will cause it to leave the
% screen. For non-scribe objects, this is defined as the position rectangle
% leaving the bounds of the figure.

% Add a 4-pixel buffer to delta:
delta(1) = delta(1)+4*sign(delta(1));
delta(2) = delta(2)+4*sign(delta(2));

% Convert delta from pixels to normalized units:
hFig = ancestor(obj,'figure');
delta = hgconvertunits(hFig,[0 0 delta],'pixels','normalized',hFig);
delta = delta(3:4);

hAx = ancestor(obj,'Axes');
% If the object does not have an axes ancestor (like a uicontrol, or
% uipanel), get its parent.
if isempty(hAx)
    hAncestor = handle(get(obj,'Parent'));
else
    hAncestor = handle(get(hAx,'Parent'));
end
if ~ishghandle(hAncestor,'figure') && ~ishghandle(hAncestor,'uipanel')
    hAncestor = hFig;
end

% Get the XData and YData from the position rectangle. This represents the
% corners and midpoints of the object. If the object is a text object,
% additional computations need to be executed to take the axes positioning
% into account.
if ishghandle(obj,'text')
    axPos = hgconvertunits(hFig,get(hAx,'Position'),get(hAx,'Units'),'Pixels',hAncestor);
    % Can't deal with data units, so convert preemptively to something
    % else:
    oldUnits = get(obj,'Units');
    set(obj,'Units','Pixels');
    objPos = get(obj,'Extent');
    objPos(1:2) = objPos(1:2)+axPos(1:2);
    objPos = hgconvertunits(hFig,objPos,'Pixels','Normalized',hAncestor);
    set(obj,'Units',oldUnits);
else
    objPos = hgconvertunits(hFig,get(obj,'Position'),get(obj,'Units'),'normalized',hAncestor);
end

selData = [objPos(1) objPos(2);...
    objPos(1) objPos(2)+objPos(4)/2;...
    objPos(1) objPos(2)+objPos(4);...
    objPos(1)+objPos(3)/2 objPos(2);...
    objPos(1)+objPos(3)/2 objPos(2)+objPos(4)/2;...
    objPos(1)+objPos(3)/2 objPos(2)+objPos(4);...
    objPos(1)+objPos(3) objPos(2);...
    objPos(1)+objPos(3) objPos(2)+objPos(4)/2;...
    objPos(1)+objPos(3) objPos(2)+objPos(4)];

% Add the delta to the data of each selection handle:
delta = repmat(delta,size(selData,1),1);
selData = selData+delta;

% If all of the X or Y data is less than 0 or more than 1, this places it the
% object outside the bounds of the figure
clippedData = [~(selData(:,1) < 0), ~(selData(:,1) > 1), ...
    ~(selData(:,2) < 0), ~(selData(:,2) > 1)];
% If a selection rectange is within the figure, all entries should be "1".
% Otherwise, they will contain a "0" entry. If all rows have a "0" entry,
% none of the selection handles are visible.
res = any(min(clippedData,[],2));

%-----------------------------------------------------------------------%
function localMoveNonScribeObject(obj,delta)
% Moves a non-scribe object by the specified delta.

% First, convert the units of the delta:
hFig = ancestor(obj,'figure');
hAncestor = handle(get(obj,'Parent'));
if ~ishghandle(hAncestor,'figure') && ~ishghandle(hAncestor,'uipanel')
    hAncestor = hFig;
end

% Text objects must be treated specially since hgconvertunits can't handle
% them.
if ishghandle(obj,'text')
    % Change the Units:
    oldUnits = get(obj,'Units');
    set(obj,'Units','Pixels');
    % Obtain object units with respect to the figure
    objPos = get(obj,'Position');
    objPos(1:2) = objPos(1:2) + delta;
    % Update the position
    set(obj,'Position',objPos);
    % Restore the units
    set(obj,'Units',oldUnits);
else
    pixPos = hgconvertunits(hFig,get(obj,'Position'),get(obj,'Units'),'pixels',hAncestor);
    pixPos(1:2) = pixPos(1:2) + delta;
    % Update the position rectangle of the object:
    set(obj,'Position',hgconvertunits(hFig,pixPos,'pixels',get(obj,'Units'),hAncestor));
end

%-----------------------------------------------------------------------%
function localResizeNonScribeObject(obj,point,moveType)
% Given an object and a point (in pixels), resize the object. Since text
% objects can't be resized, the "Position" property always returns a valid
% position rectangle.

hFig = ancestor(obj,'Figure');
hAncestor = handle(get(obj,'Parent'));
if ~ishghandle(hAncestor,'figure') && ~ishghandle(hAncestor,'uipanel')
    hAncestor = hFig;
end

objPos = hgconvertunits(hFig,get(obj,'Position'),get(obj,'Units'),'Pixels',hAncestor);
ancPos = localGetAncestorPosition(hAncestor);
point = point - ancPos(1:2);

% old positions (in pixels):
XL = objPos(1);
XR = objPos(1) + objPos(3);
YU = objPos(2) + objPos(4);
YL = objPos(2);

% move the appropriate x/y values
switch moveType
    case 'topleft'
        % e.g. moving the upper left affordance
        % changes the left x and upper y
        XL = point(1);
        YU = point(2);
    case 'topright'
        XR = point(1);
        YU = point(2);
    case 'bottomright'
        XR = point(1);
        YL = point(2);
    case 'bottomleft'
        XL = point(1);
        YL = point(2);
    case 'left'
        XL = point(1);
    case 'top'
        YU = point(2);
    case 'right'
        XR = point(1);
    case 'bottom'
        YL = point(2);
    otherwise
        return;
end
% calculate and set width height and x,y of resized rectangle
objPos(1) = XL;
objPos(2) = YL;
objPos(3) = XR - XL;
objPos(4) = YU - YL;
% The width and height must be at least 2 pixels
objPos(3) = max(objPos(3), 2);
objPos(4) = max(objPos(4), 2);

% Convert into the units of the object:
objPos = hgconvertunits(hFig,objPos,'Pixels',get(obj,'Units'),hAncestor);
set(obj,'position',objPos);

%--------------------------------------------------------------------%
function localFixSelectedObjs(hMode)

% remove invalid handles from slectobjs list
hMode.ModeStateData.SelectedObjects(~ishghandle(hMode.ModeStateData.SelectedObjects)) = [];

%--------------------------------------------------------------------%
function localUpdateNonScribeContextMenu(hObj,hMenuItems)

className = class(handle(hObj));

switch className
    case 'axes'
        % find show/hide legend item and set label
        legendmenu = findall(hMenuItems,'Label','Show Legend');
        if isempty(legendmenu)
            legendmenu = findall(hMenuItems,'Label','Hide Legend');
        end
        if ~isempty(legendmenu)
            legh = legend(double(hObj));
            if isempty(legh) || strcmpi(get(legh,'Visible'),'off')
                set(legendmenu,'Label','Show Legend');
            else
                set(legendmenu,'Label','Hide Legend');
            end
        end
        % grids
        gridMenu = findall(hMenuItems,'Label','Grid');
        if strcmpi(get(hObj,'XGrid'),'on') && strcmpi(get(hObj,'YGrid'),'on') ...
                && strcmpi(get(hObj,'ZGrid'),'on')
            set(gridMenu,'Checked','on');
        else
            set(gridMenu,'Checked','off');
        end
    case 'specgraph.contourgroup'
        % fill
        fillMenu = findall(hMenuItems,'Label','Fill');
        if strcmpi(get(hObj,'Fill'),'on')
            set(fillMenu,'Checked','on');
        else
            set(fillMenu,'Checked','off');
        end
end

%---------------------------------------------------------------------%
function hMenuItems = localGetNonScribeScribeContextMenu(hMode,hObj)
% Returns context-menu entries for non-scribe objects.

hObj = handle(hObj);

fig = ancestor(hObj,'figure');
objClass = class(hObj);

hMenuItems = findall(hMode.UIContextMenu,'Tag',sprintf('scribe.%s.uicontextmenu',objClass));
if ~isempty(hMenuItems)
    hMenuItems = hMenuItems(end:-1:1);
    return;
end

% add scribe context menu items if they don't exist
switch objClass
    case 'axes'
        hMenuItems(end+1) = graph2dhelper('createScribeUIMenuEntry',fig,'LegendToggle','Show Legend','','');
        % color
        hMenuItems(end+1) = graph2dhelper('createScribeUIMenuEntry',fig,'Color','Color...','Color','Color');
        set(hMenuItems(end),'Separator','on');
        % font properties
        hMenuItems(end+1) = graph2dhelper('createScribeUIMenuEntry',fig,'Font','Font...','','Font');
        % grids
        hMenuItems(end+1) = graph2dhelper('createScribeUIMenuEntry',fig,'Toggle','Grid',{'XGrid','YGrid','ZGrid'},'Grid');
        set(hMenuItems(end),'Separator','on');
    case {'graph2d.lineseries','line'}
        % color
        hMenuItems(end+1) = graph2dhelper('createScribeUIMenuEntry',fig,'Color','Color...','Color','Color');
        % Line style:
        hMenuItems(end+1) = graph2dhelper('createScribeUIMenuEntry',fig,'LineStyle','Line Style','LineStyle','Line Style');
        % Line width:
        hMenuItems(end+1) = graph2dhelper('createScribeUIMenuEntry',fig,'LineWidth','Line Width','LineWidth','Line Width');
        % Marker:
        hMenuItems(end+1) = graph2dhelper('createScribeUIMenuEntry',fig,'Marker','Marker','Marker','Marker');
        % Marker Size:
        hMenuItems(end+1) = graph2dhelper('createScribeUIMenuEntry',fig,'MarkerSize','Marker Size','MarkerSize','Marker Size');
    case {'patch','surface','graph3d.surfaceplot'}
        % facecolor
        hMenuItems(end+1) = graph2dhelper('createScribeUIMenuEntry',fig,'Color','Face Color...','FaceColor','Face Color');
        % edge color
        hMenuItems(end+1) = graph2dhelper('createScribeUIMenuEntry',fig,'Color','Edge Color...','EdgeColor','Edge Color');
        % edge properties
        % Line style:
        hMenuItems(end+1) = graph2dhelper('createScribeUIMenuEntry',fig,'LineStyle','Line Style','LineStyle','Line Style');
        % Line width:
        hMenuItems(end+1) = graph2dhelper('createScribeUIMenuEntry',fig,'LineWidth','Line Width','LineWidth','Line Width');
        % Marker:
        hMenuItems(end+1) = graph2dhelper('createScribeUIMenuEntry',fig,'Marker','Marker','Marker','Marker');
        % Marker Size:
        hMenuItems(end+1) = graph2dhelper('createScribeUIMenuEntry',fig,'MarkerSize','Marker Size','MarkerSize','Marker Size');
    case 'rectangle'
        % facecolor
        hMenuItems(end+1) = graph2dhelper('createScribeUIMenuEntry',fig,'Color','Face Color...','FaceColor','Face Color');
        % edge color
        hMenuItems(end+1) = graph2dhelper('createScribeUIMenuEntry',fig,'Color','Edge Color...','EdgeColor','Edge Color');
        % edge properties
        % Line style:
        hMenuItems(end+1) = graph2dhelper('createScribeUIMenuEntry',fig,'LineStyle','Line Style','LineStyle','Line Style');
        % Line width:
        hMenuItems(end+1) = graph2dhelper('createScribeUIMenuEntry',fig,'LineWidth','Line Width','LineWidth','Line Width');
    case 'text'
        % edit
        hMenuItems(end+1) = graph2dhelper('createScribeUIMenuEntry',fig,'EditText','Edit','','');
        % text color
        hMenuItems(end+1) = graph2dhelper('createScribeUIMenuEntry',fig,'Color','Text Color...','Color','Text Color');
        set(hMenuItems,'Separator','on');
        % backgroundcolor
        hMenuItems(end+1) = graph2dhelper('createScribeUIMenuEntry',fig,'Color','Background Color...','BackgroundColor','Background Color');
        % edgecolor
        hMenuItems(end+1) = graph2dhelper('createScribeUIMenuEntry',fig,'Color','Edge Color...','EdgeColor','Edge Color');
        % font properties
        hMenuItems(end+1) = graph2dhelper('createScribeUIMenuEntry',fig,'Font','Font...','','Font');
        % interpreter
        hMenuItems(end+1) = graph2dhelper('createScribeUIMenuEntry',fig,'TextInterpreter','Interpreter','Interpreter','Interpreter');
        % edge properties
        % Line style:
        hMenuItems(end+1) = graph2dhelper('createScribeUIMenuEntry',fig,'LineStyle','Line Style','LineStyle','Line Style');
        % Line width:
        hMenuItems(end+1) = graph2dhelper('createScribeUIMenuEntry',fig,'LineWidth','Line Width','LineWidth','Line Width');
    case 'figure'
        % color
        hMenuItems(end+1) = graph2dhelper('createScribeUIMenuEntry',fig,'Color','Color...','Color','Color');
        % close
        hMenuItems(end+1) = graph2dhelper('createScribeUIMenuEntry',fig,'CloseFigure','Close Figure','','');
    case 'specgraph.areaseries'
        % facecolor
        hMenuItems(end+1) = graph2dhelper('createScribeUIMenuEntry',fig,'Color','Face Color...','FaceColor','Face Color');
        % edge color
        hMenuItems(end+1) = graph2dhelper('createScribeUIMenuEntry',fig,'Color','Edge Color...','EdgeColor','Edge Color');
        % edge properties
        % Line style:
        hMenuItems(end+1) = graph2dhelper('createScribeUIMenuEntry',fig,'LineStyle','Line Style','LineStyle','Line Style');
        % Line width:
        hMenuItems(end+1) = graph2dhelper('createScribeUIMenuEntry',fig,'LineWidth','Line Width','LineWidth','Line Width');
    case 'specgraph.barseries'
        % facecolor
        hMenuItems(end+1) = graph2dhelper('createScribeUIMenuEntry',fig,'Color','Face Color...','FaceColor','Face Color');
        % edge color
        hMenuItems(end+1) = graph2dhelper('createScribeUIMenuEntry',fig,'Color','Edge Color...','EdgeColor','Edge Color');
        % bar width
        hMenuItems(end+1) = graph2dhelper('createScribeUIMenuEntry',fig,'BarWidth','Bar Width','BarWidth','Bar Width');
        % layout
        hMenuItems(end+1) = graph2dhelper('createScribeUIMenuEntry',fig,'BarLayout','Bar Layout','BarLayout','Bar Layout');
    case 'specgraph.contourgroup'
        % line color
        hMenuItems(end+1) = graph2dhelper('createScribeUIMenuEntry',fig,'Color','Line Color...','LineColor','Line Color');
        % line properties
        % Line style:
        hMenuItems(end+1) = graph2dhelper('createScribeUIMenuEntry',fig,'LineStyle','Line Style','LineStyle','Line Style');
        % Line width:
        hMenuItems(end+1) = graph2dhelper('createScribeUIMenuEntry',fig,'LineWidth','Line Width','LineWidth','Line Width');
        % fill
        hMenuItems(end+1) = graph2dhelper('createScribeUIMenuEntry',fig,'Toggle','Fill','Fill','Fill');
    case 'specgraph.quivergroup'
        % color
        hMenuItems(end+1) = graph2dhelper('createScribeUIMenuEntry',fig,'Color','Color...','Color','Color');
        % line properties
        % Line style:
        hMenuItems(end+1) = graph2dhelper('createScribeUIMenuEntry',fig,'LineStyle','Line Style','LineStyle','Line Style');
        % Line width:
        hMenuItems(end+1) = graph2dhelper('createScribeUIMenuEntry',fig,'LineWidth','Line Width','LineWidth','Line Width');
        % marker properties
        % Marker:
        hMenuItems(end+1) = graph2dhelper('createScribeUIMenuEntry',fig,'Marker','Marker','Marker','Marker');
        % Marker Size:
        hMenuItems(end+1) = graph2dhelper('createScribeUIMenuEntry',fig,'MarkerSize','Marker Size','MarkerSize','Marker Size');
        % auto scale factor
        hMenuItems(end+1) = graph2dhelper('createScribeUIMenuEntry',fig,'AutoScaleFactor','Scale Factor','AutoScaleFactor','Scale Factor');
    case 'specgraph.scattergroup'
        % marker face color
        hMenuItems(end+1) = graph2dhelper('createScribeUIMenuEntry',fig,'Color','Marker Face Color...','MarkerFaceColor','Marker Face Color');
        % marker edge color
        hMenuItems(end+1) = graph2dhelper('createScribeUIMenuEntry',fig,'Color','Marker Edge Color...','MarkerEdgeColor','Marker Edge Color');
        % marker
        hMenuItems(end+1) = graph2dhelper('createScribeUIMenuEntry',fig,'Marker','Marker','Marker','Marker');
    case {'specgraph.stairseries','specgraph.stemseries','specgraph.errorbarseries'}
        % color
        hMenuItems(end+1) = graph2dhelper('createScribeUIMenuEntry',fig,'Color','Color...','Color','Color');
        % Line style:
        hMenuItems(end+1) = graph2dhelper('createScribeUIMenuEntry',fig,'LineStyle','Line Style','LineStyle','Line Style');
        % Line width:
        hMenuItems(end+1) = graph2dhelper('createScribeUIMenuEntry',fig,'LineWidth','Line Width','LineWidth','Line Width');
        % Marker:
        hMenuItems(end+1) = graph2dhelper('createScribeUIMenuEntry',fig,'Marker','Marker','Marker','Marker');
        % Marker Size:
        hMenuItems(end+1) = graph2dhelper('createScribeUIMenuEntry',fig,'MarkerSize','Marker Size','MarkerSize','Marker Size');
end

% Set the tag of the menu items and reparent
for i=1:numel(hMenuItems)
    set(hMenuItems(i),'Tag',sprintf('scribe.%s.uicontextmenu',objClass),'Parent',hMode.UIContextMenu);
end

%---------------------------------------------------------------------%
function pointerType = localConvertMoveType(moveType)
% Given a move type value return the appropriate pointer to be shown to the
% user

switch(moveType)
    case 'mouseover'
        pointerType = 'fleur';
    case 'topleft'
        pointerType = 'topl';
    case 'topright'
        pointerType = 'topr';
    case 'bottomright'
        pointerType = 'botr';
    case 'bottomleft'
        pointerType = 'botl';
    case 'left'
        pointerType = 'left';
    case 'top'
        pointerType = 'top';
    case 'right'
        pointerType = 'right';
    case 'bottom'
        pointerType = 'bottom';
    case 'none';
        pointerType = 'arrow';
end

%-------------------------------------------------------------------------%
function localNoop(varargin)
% This space intentionally left blank

%------------------------------------------------------------------------%
function localSetListenerStateOn(hList)
if feature('HGUsingMATLABClasses')
    onVal = repmat({true},size(hList));
    [hList.Enabled] = deal(onVal{:});
else
    set(hList,'Enabled','on');
end

%------------------------------------------------------------------------%
function localSetListenerStateOff(hList)
if feature('HGUsingMATLABClasses')
    offVal = repmat({false},size(hList));
    [hList.Enabled] = deal(offVal{:});
else
    set(hList,'Enabled','off');
end

%------------------------------------------------------------------------%
function obj = localHittest(hFig,evd,varargin)
if feature('HGUsingMATLABClasses')
    obj = plotedit([{'hittestHGUsingMATLABClasses',hFig,evd},varargin(:)]);
else
    obj = handle(hittest(hFig,varargin{:}));
end