function enforceItemSeparators(h, descend, ignoreRenderedState, visIdx)
%enforceItemSeparators
% Enforce item-separator strategy on children in group
%   (h)
%   (h,descend)
%   (h,descend,ignoreRenderedState)
%
% descend: true/false
%   Should we recursively update separators on group children?
%
% ignoreRenderedState: true/false
%   Sometimes we want childOrder to include only rendered children
%   Include only rendered children...
%      when updating separators in a non-render() call,
%      such as when an item is newly rendered, newly unrendered,
%      or the visibility is changed.
%   Include all children, including non-rendered, ...
%      when updating separators during a render-call;
%      this update is done pre-render, when NO items
%      have yet been rendered.

% Copyright 2005-2009 The MathWorks, Inc.
% $Revision: 1.1.6.6 $ $Date: 2009/05/23 08:12:43 $

if nargin<2
    descend = false;  % default: do not descend
end
if nargin<3
    ignoreRenderedState = false; % default: don't ignore render state
end

% First treat this as a simple uiitem and set the separator
% state as the property suggests.  Then, update the child list.
setWidgetProp(h,'Separator');

% Assess visible content of child list, to see if it
% contains only non-widget uigroup's, or uiitem's
%
% Get sorted list of child objects, based on placement values
%  - Pass the super-secret visIdx flag, to allow for visibility
%    override of one item/group, due to set-function behavior
%    (new item visibility state not yet set, but is still needed)
%  - If there are no renderable children, exit:
%
if nargin<4, visIdx=0; end
childObjOrder = computeChildOrder(h,ignoreRenderedState,visIdx);
if isempty(childObjOrder)
    return
end

% Set markers to indicate "first-placed" in group
% This flag is used later to help us turn off
%   the "first rendered separator in parent."
set(childObjOrder{1},    'isFirstPlace',true);
for i = 2: length(childObjOrder)
    if isprop(childObjOrder{i}, 'isFirstPlace')
        set(childObjOrder{i},'isFirstPlace',false);
    end
end


% We're traversing in childOrder
hChildVect = cell(0);
% handle([]);  % to fill with "renderable" items
for i = 1: length(childObjOrder)
    theChild = childObjOrder{i};
    % when we merge uiitem with uigroup,
    %   we can have both types of children simultaneously
    %   only for uimenu's could this happen, and in that case,
    %   we render parent as an item, then process children
    %
    % Remember, we could be ignoring rendered state
    % and getting ALL children
    %
    % If it's a group, it could be a "renderable widget" too
    % (such as a uimenuparent).  If it's a widget, we
    % count it as an item - because then it's just a
    % single rendered item ... the children render as
    % a sub-menu or sub-palette or whatever.  It's only
    % a group-without-a-widget that counts as a group
    %
    % Remember to look for a non-empty WidgetFcn, and
    % not for a non-empty hWidget.  The widget might not
    % be rendered, but we still want to know definitively
    % if this is a widget-bearing group.
    %
    isRenderableWidget = ~theChild.isGroup || ...
        ( ~theChild.SkipSeparatorComp && ~isempty(theChild.WidgetFcn) );
    if isRenderableWidget
        % isRenderableWidget is true for non-uigroups,
        %   and uigroups without a WidgetFcn
        %
        % Record rendered widget handles, whether they're in a uiitem
        % or a uigroup, and whether they're rendered now or not.
        hChildVect{end+1} = theChild; %#ok
    end
end
childRenderableNum    = numel(hChildVect);
childNonRenderableNum = numel(childObjOrder) - childRenderableNum;

% There are several cases to consider:
%   1. Strictly items in this group (no child groups)
%      ACTION: We want one item separator visible on "leading item"
%              turnOnFirst = true
%      SEPARATORS: Turned off for each uiitem child
%
%   2. Mixed items and child groups in this group
%      ACTION: Each item is to have its separator visible
%              turnOnFirst = false
%      SEPARATORS: Turned on for each uiitem child
%
%   3. No items in this group (only child groups)
%      ACTION: Just recurse on each child group
%              turnOnFirst = false
%      SEPARATORS: N/A (no uiitem children)

% May have neither groups nor items if list is empty!
if (childRenderableNum  > 0) % # children that have renderable widgets
    % Set the separator, as long as this item is not the
    % first rendered item in the graphical parent
    % (We don't want leading separators to appear)
    
    % Is first item the "leading" item in the graphical parent?
    firstChild = hChildVect{1};
    
    % Note: we don't have uibuttongroup's in hChildVect, so
    % firstChild might *not* be the lowest placement-value child
    
    % sFirst: separator state for first child
    if firstChild.isFirstPlace && isInTopGroup(firstChild)
        sFirst='off';
    else
        sFirst='on';
    end
    
    % sRest: separator state for rest of children (2:end)
    if childNonRenderableNum==0
        sRest='off';
    else
        sRest='on';
    end
    
    % Set item separator property:
    set(firstChild,'Separator',sFirst);
    for childVecIndex = 2:length(hChildVect)
        set(hChildVect{childVecIndex},'Separator',sRest);
    end
    % Manually propagate separator to rendered widgets
    % (i.e., make separators visible in widgets, if they exist)
    %
    % This is done to accommodate interactive changes to visibility
    % or unrendering of uiitem's, without having to use listeners
    for itemIndex = 1:length(hChildVect)
        theItem = hChildVect{itemIndex};
        %theItem
        setWidgetProp(theItem,'Separator')
    end
end

% Recurse on descendents of this child
if descend
    for i = 1: length(childObjOrder)
        theChild = childObjOrder{i};
        if theChild.isGroup
            enforceItemSeparators( theChild, descend, ignoreRenderedState);
        end
    end
end
end

% [EOF]