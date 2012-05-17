function priv_updateVisible(h,val)
%priv_updateVisible Called from uiitem schema sf_Visible.

% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.6.3 $ $Date: 2008/04/11 16:22:59 $

hParent = h.up;
if isempty(hParent)
    updateVisible(h,val);
else
    canEnforce = CntSem(1); % try to take semaphore
    updateVisible(h,val);
    if canEnforce
        local_enforceItemSeparators(h,val);
    end
    CntSem(0); % try to give it back
end

% ---------------------------------
function local_enforceItemSeparators(h,vis)
% Compute a special override index, needed because we executing
% a set-function and the actual property has not yet changed.
% Because some downstream functions look at this property (".Visible"),
% we must have an flag to tell those functions that they should
% override the actual property for this particular item.
% The index indicates which item we are (index into list of children),
% and whether the override is going to 'on' (pos) or 'off' (neg) state

% Find our index relative to siblings
hParent = h.up;
if ~isempty(hParent)
    hSibling = hParent.down; % get leftmost sibling
    visIdx = 1; % index of matching child in child list
    while ~isempty(hSibling) && ~isequal(hSibling,h)
        visIdx = visIdx+1;
        hSibling = hSibling.right;
    end
    
    % Use special index arg for this child to signify to enforce...
    % (and ultimately, to computeChildOrder) that we're just
    % about to go vis=off (neg) or on (pos)
    if strcmpi(vis,'off')
        visIdx = -visIdx; % signify just about to turn "off", not "on"
    end
    % Update separators on parent
    %   - descend, don't ignore render state, special override
    enforceItemSeparators(hParent,true,false,visIdx); % xxx descend?
end

% ------------------------------
function y = CntSem(op)
%CNTSEM Counting semaphore.
%  Each "take" increments counter.
%  Each "give" decrements counter.
%  On "take", returns TRUE if counter was zero prior to increment.
%
%  This way, only one call in a recursion obtains permission
%  to perform some operation, or access some resource.
%
%  OP: 1=take, 0=give
%  Returns true on "take" if request is granted
%          (i.e., if count is 0)
% It is an error to request a return arg on a "give".

% xxx can we remove persistent variable ... and CntSem function?
persistent theCount
if isempty(theCount)
    theCount = 0;
end

if op
    % take: try to take the semaphore
    y = (theCount==0); % request granted?
    theCount = theCount+1;
else
    % give: give back the semaphore
    theCount = theCount-1;
end

% [EOF]
