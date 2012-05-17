function [visChildObj,visChildIdx] = computeChildOrder(h,ignoreRenderedState,visIdx)
%computeChildOrder Compute render-order of visible children.
%   Sort child into placement order, returning sorted child objects.
%
%   Placement:
%       lower values mean render first (left-most or top-most)
%       can be fractional
%
%   ChildIdx:
%       Indices, 1=highest (first), >1=lower, integer-valued.
%   ChildObj:
%       List of child handles sorted according to placement
%       sort is in ascending order (lower placement values first)
%
%   ignoreRenderedState:
%     By default, we consider rendered state when constructing
%     list of children to sort into placement-order.  This is
%     useful for non-render() method calls on an item, such as
%     when adding or removing an item in a group, or changing
%     item visibility.  ignoreRenderedState=false is the default.
%
%     A true flag for ignoreRenderedState is passed by the render()
%     method, under the situation where no children are currently
%     rendered. (They are generally all un-rendered at the start
%     of the render() method).
%
%     visIdx
%        (used by uitoolbargroup::renderOrderBugFix, pos case)
%        (used by uigroup::enforceItemSeparators, neg case)
%
%        When Positive:
%        This is used to signify a child whose visibility is just about
%        to change to 'on' ... and we would miss its participation in the
%        child order unless we specially flag it.  This occurs due to the
%        use of a "set-function" callback on visibility, as opposed to the
%        use of a listener (which itself was done for efficiency).
%
%        When Negative:
%        Similar, used to signify a child whose visibility is just about
%        to change to 'off' ...
%
%        When Inf:
%        Matches all indices; that is, assumes ALL children are just about
%        to be visible; thus, it ignores ALL currently visibility settings.

% Copyright 2004-2009 The MathWorks, Inc.
% $Revision: 1.1.6.5 $ $Date: 2009/04/27 19:55:01 $

% Initialize return vectors
visChildIdx   = [];
visChildPlace = [];
visChildObj   = cell(0);

if nargin<2
    % Default: don't ignore rendered state
    ignoreRenderedState = false;
end

% Default: these won't match any child index,
% since indices go from 1 to N
GoingVisIdx   = 0;
GoingInvisIdx = 0;
if nargin>2
    % parse pos and neg
    if visIdx>=0
        GoingVisIdx = visIdx;    % keep pos idx
    else
        GoingInvisIdx = -visIdx; % change to pos idx
    end
end

% Visit children of this group
i = 1;
theChild = h.down;  % get first child
while ~isempty(theChild)
    % Determine if child is rendered
    % If ignore... is set, we pretend this is true.
    % If ignore... is NOT set, we see if there is a non-empty
    %              widget handle in child or a descendent
    % Two conditions to meet:
    %
    %     (is it visible) && (is it rendered)
    %
    % (It's just that we have exception-flags that allow us
    % to override the condition for each of these)
    %
    tmp_GoingInvis = (GoingInvisIdx == i);
    tmp_GoingVis   = isinf(GoingVisIdx) || (GoingVisIdx == i);
    % inf matches all - means "don't consider visibility"
    if ~tmp_GoingInvis && ...
            (tmp_GoingVis || ...
            ( strcmpi(theChild.Visible,'on')...
            && (ignoreRenderedState || theChild.isRendered)))
        
        visChildIdx(end+1) = i; %#ok
        visChildPlace(end+1) = theChild.ActualPlacement; %#ok
        visChildObj{end+1} = theChild; %#ok
    end
    theChild = theChild.right;  % get next child
    i=i+1;
end

% Sort placement values
% Together with the uigroup::getDefaultPlacement() function,
% these set the "direction" of placement interpretation

% Sort in ASCENDING order, so that index 1 is assigned to the
% first-placed child.
%
% NOTE: empty visChildPlace and visChildIdx must be
%       appropriately handled by the following code
[unused_val, placeOrder] = sort(visChildPlace);
visChildObj = visChildObj(placeOrder);
visChildIdx = visChildIdx(placeOrder);

% [EOF]
