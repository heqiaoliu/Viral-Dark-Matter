function updateSelectionConstraint(h,theSelectionConstraint)
%updateSelectionConstraint Update selection constraint setting for group.
%   Setting can be:
%       'None' - no constraint on items in group
%       'SelectOne' - exactly one item must be selected at all times
%       'SelectZeroOrOne' - at most one item may be selected at any time
%
%   Note that theSelectionConstraint can be passed in as an argument,
%   since this function is called from a property "setfunction",
%   and thus, the property value is set to the new value at the point
%   that this function gets called.  Hence the override.
%
%   If a SelectionConstraint other than 'None' is selected,
%   the underlying widget (child of uiitem) must support
%   a "StateName" property (usually 'State' or 'Checked',
%   and is configurable by changing this string property).
%   A warning is issued if the underlying widget does not support
%   the property, and SelectionConstraint is changed to 'None'.
%
%   This function sets up the listeners and callbacks to process
%   selection changes.
%
%   We check that the group is "simple", i.e., there are no
%   uigroup children, only uiitems.  Also, the items in the group
%   cannot have a custom state property name; if it does, we don't
%   know that we can support it.  In either case, we give a
%   warning and turn off the group constraint.

% Copyright 2005-2009 The MathWorks, Inc.
% $Revision: 1.1.6.8 $ $Date: 2009/10/07 14:24:33 $

if nargin<2
    theSelectionConstraint = h.SelectionConstraint;
end

switch lower(theSelectionConstraint)
    case 'selectone'
        % One selection is required
        %
        % Setup fcn-handle to add listeners to child items,
        % when the group is rendered:
        CheckConstraintRules(h);
        h.SelConInstall = @(h, ev) installSelectOne(h);
        
    case 'selectzeroorone'
        % Zero or one selection is required
        %
        % Attach a listener to the buttons in the group
        CheckConstraintRules(h);
        h.SelConInstall = @(h, ev) installSelectZeroOrOne(h);
        
    case 'none'
        % Remove existing InstallFcn and listeners, if present:
        uninstallSelectionConstraints(h);
        
    otherwise
        error('uimgr:UnsupportedConstraint', ...
            'Unsupported SelectionConstraint option "%s".', ...
            theSelectionConstraint);
end

end % main


% ---------------------------------------------
function ConstrainedItemChanged(hItem,ev,cType)
% Zero or One item may be on at one time
% If 2 or more are on,
%   reset all 'on' items except the current one
%
% If cType is 0, this is a "zero or one item" constraint
% If cType is 1, this is a "one item only" constraint

% First, find index of all 'on' items
%
% Note: does NOT include the button just turned on, if
% one was turned on, because we use a PropertyPreSet listener.
%
hGroup = hItem.up; % get group node from item
allOnIdx = findOnItems(hGroup);

% Next, determine if we're about to turn on the item
% NOTE: this is a PreSetProperty listener, not a PostSet ...
%       so the current item has not yet changed state!
%
num_on = numel(allOnIdx);  % # items turned on PRIOR to this change

if isa(ev, 'event.PropertyEvent')
    srcValue = ev.AffectedObject.(ev.Source.Name);
    about_to_turn_on = strcmp(srcValue,'off');
else
    srcValue = ev.NewValue;
    about_to_turn_on = strcmp(srcValue,'on');
end

% about_to_turn_on = strcmp(srcValue,'off');

if about_to_turn_on && (num_on>0)
    % Two or more are about to be on
    % This implements the "must be no more than one item" constraint
    %
    % We're ABOUT TO turn on multiple items, so we turn off
    % all items currently on.  (It's a PropertyPreSet listener)
    %
    % That way, when the new item is turned on,
    % it becomes the ONLY item turned on.
    
    % Loop through all children, up to the max index we must visit
    % Only "visit" those children whose index is in allOnIdx
    % Ex: onIdx = [2 3 5]
    %     thus we visit only the 2nd, 3rd, and 5th children
    %
    theChild = hGroup.down; % get first child
    for onIdx = 1:max(allOnIdx)
        if any(onIdx == allOnIdx)
            % It can be assumed that theWidget is valid,
            % since the only way to get here is for the widget state
            % to have changed ... meaning the widget is valid.
            % It's more efficient to skip the isempty/ishandle tests.
            
            % Get SelCon listener from appdata on widget and disable/enable
            % it while we turn it off.
            theWidget = theChild.hWidget;
            hListener = getappdata(theWidget, 'uimgr_SelConListener');
            
            % Turn off item -- but disable listener first, since we know 
            % we're changing this and don't want to re-enter the selection 
            % constraint code
            if isa(hListener, 'event.listener') || isa(hListener, 'event.proplistener')
                hListener.Enabled = false;
                set(theChild.hWidget, theChild.StateName, 'off');
                hListener.Enabled = true;                
            else
                hListener.enabled = 'off';
                set(theChild.hWidget, theChild.StateName, 'off');
                hListener.enabled = 'on';                
            end                                    
        end
        theChild = theChild.right; % get next child
    end
    
elseif ~about_to_turn_on && (num_on==1) && (cType==1)
    % This implements the "must always be one item on" constraint
    %
    % We're about to turn off the last remaining item
    % ("~about_to_turn_on" implies we're about to turn an item off,
    %  since we got here due to some change in the item state)
    %
    % The constraint is "don't allow zero items", so
    % we must turn this item back on.
    % (Remember, this is a PreSetProperty listener, not a PostSet
    %  ... so the current item is not yet turned off!)
    %
    % (If cType==0, then we allow zero items to
    %  be turned on and we do NOT enter in this case.)
    %
    selectionConstraintRestore(hItem);
end

end % ConstrainedItemChanged


% ---------------------------------------------
% Avoiding the use of anonymous functions by making
% these simple pass-thru functions.  Saves a little
% memory and execution time, but not much.

function installSelectOne(hGroup)
addChildStateListeners(hGroup,1);
end

function installSelectZeroOrOne(hGroup)
addChildStateListeners(hGroup,0);
end

% ---------------------------------------------
function addChildStateListeners(hGroup,cType)
% Listen for changes to the constraint property
% of each child of the uiitem's within the uigroup.
%
% (Note: group children are guaranteed to be uiitem's here)
%
% If cType is 0, this is a "zero or one item" constraint
% If cType is 1, this is a "one item only" constraint

% Remove any existing listeners
% NOTE: be sure to only uninstall listeners, not the InstallFcn
%
uninstallSelectionConstraintListeners(hGroup);

% Initialize item states based on selection constraint
%
% We could do this before or after engaging the listeners
% Better performance if we do it first (i.e., no redundant
% firing of listeners when init settings are changed)
%
initConstraints(hGroup);

% Add constraint property listeners to uiitem's
%
widgetSelConProp = 'uimgr_SelConListener';  % for retaining listener
theChild = hGroup.down;  % get first child in group
while ~isempty(theChild)
    % It is assumed that the children here are uiitem's
    % It is assumed that we are called during renderPost,
    % so the uiitem children are rendered widgets,
    % each supporting the property defined in "StateName"
    theWidget = theChild.hWidget;
    
    % Check that the "StateName" property is available in the widget being
    % used.  
    if ~isprop(theWidget, theChild.StateName) 
        % Remove listener and InstallFcn:
        uninstallSelectionConstraints(hGroup);
    end
    
    % Set up index into children and handle to group
    % for listener callback.
    % cType is 0 (meaning zero or one items may be on)
    %       or 1 (meaning one item must be on)
    %
    cbFcn = @(hh,ev)ConstrainedItemChanged(theChild,ev,cType);
    
    % Create and add listener to the "constraint property"
    % of the appdata in the group.  Retain listeners on individual
    % widgets so they get cleared if widget is deleted.
    %
    hListen = uiservices.addlistener(theWidget,theChild.StateName,'PreSet',cbFcn);
    setappdata(theWidget, widgetSelConProp, hListen);
    
    theChild = theChild.right; % next child
end

end % addChildStateListeners


% ---------------------------------------------
function initConstraints(hGroup)
% If the constraint could be applied (i.e., all items had the
% required property), initialize the uiitem widget properties to
% uphold the selected constraint.
%
% E.g., if "SelectOne" is the constraint, we enforce that
%       exactly one item is selected.

switch lower(hGroup.SelectionConstraint)
    case 'selectone'
        % Examine uiitem's in uigroup
        % Must be exactly one uiitem 'on'
        % If one, leave it alone and exit
        % If none, turn on first (lowest placement-value) uiitem
        % If more than one, turn off all uiitem's after the first
        %    (lowest placement-value) uiitem
        [isOn,numOn] = getConstraintPropVal(hGroup);
        if numOn==0
            turnOnFirstChild(hGroup);
        elseif numOn>1
            turnOffAllButFirstChild(hGroup,isOn);
        end
        
    case 'selectzeroorone'
        % Examine uiitem's in uigroup
        % Must be exactly zero or one uiitem 'on'
        % If zero or one, leave it alone and exit
        % If more than one, turn off all uiitem's after the first
        %    (lowest placement-value) uiitem
        [isOn,numOn] = getConstraintPropVal(hGroup);
        if numOn>1
            turnOffAllButFirstChild(hGroup,isOn);
        end
        
    otherwise % 'none'
        % Nothing to do
end

end % initConstraints


% ---------------------------------------------
function turnOffAllButFirstChild(hGroup,isOn)
% Assumes default (non-custom) state with 'on' and 'off'
% Assumes all children of uigroup are uiitem's
% Assumes 2 or more are currently turned on
% Forces only one to be on; turns off all except
% the lowest placement-value uiitem that is currently
% turned on
%
% isOn is in child-order, not render-placement order

[childPlaceObj, childPlaceIdx] = computeChildOrder(hGroup);
isOn = isOn(childPlaceIdx); % reorder based on placement
firstIdx = find(isOn,1);  % find first one on

% Build list of indices to turn off
toTurnOff = isOn;
toTurnOff(firstIdx) = false;

if ~isempty(toTurnOff)
    % Remove first however-many child objects that are NOT turned on.
    % Also remove the very first child object one that IS turned on.
    % Leaving a list of child objects that must be turned off
    
    % Turn off undesired uiitem's
    childPlaceObj = childPlaceObj(toTurnOff); % logical indexing
    for childItem = childPlaceObj
        % It can be assumed that .hWidget is valid here,
        % since we are called in response to a change in its state
        set(childItem{1}.hWidget,childItem{1}.StateName,'off');
    end
end

end % turnOffAllButFirstChild


% ---------------------------------------------
function turnOnFirstChild(hGroup)
% Turn on the first (lowest placement value) child of uigroup
% Here, child is guaranteed to be a uiitem

childOrderObj = computeChildOrder(hGroup);
childItem = childOrderObj{1};
set(childItem.hWidget,childItem.StateName,'on');

end % turnOnFirstChild


% ---------------------------------------------
function CheckConstraintRules(h)

% Check that each child may participate in selection constraint
% Here we can trust that all children are uiitems, not uigroups
hChild = h.down; % get first child
while ~isempty(hChild)
    if ~hChild.AllowSelectionConstraint
        error('uimgr:ConstraintNotAllowed', ...
            'Child "%s" in group "%s" disallows SelectionConstraints.', ...
            hChild.Name, h.Name);
    end
    hChild = hChild.right; % get next child
end

end % CheckConstraintRules

% ---------------------------------------------
function uninstallSelectionConstraintListeners(hGroup)
% Uninstall SelectionConstraint hooks

% Remove any listeners for existing constraints
% Visit each child widget and delete listener in the appdata.
% Note:
%  - there might not be a widget, or it could be invalid
%
widgetSelConProp = 'uimgr_SelConListener';  % for retaining listener
hChild = hGroup.down;
while ~isempty(hChild)
    theWidget = hChild.hWidget;
    if isappdata(theWidget, widgetSelConProp)
        % Delete listener, remove appdata from where it was stored.
        delete(getappdata(theWidget, widgetSelConProp));
        rmappdata(theWidget, widgetSelConProp);
    end
    
    hChild=hChild.right; % next child
end

end % uninstallSelectionConstraintListeners

% ---------------------------------------------
function uninstallSelectionConstraints(h)
% Uninstall SelectionConstraint hooks

uninstallSelectionConstraintListeners(h);

% Remove installation fcn
h.SelConInstall = [];

end % uninstallSelectionConstraints

% [EOF]
