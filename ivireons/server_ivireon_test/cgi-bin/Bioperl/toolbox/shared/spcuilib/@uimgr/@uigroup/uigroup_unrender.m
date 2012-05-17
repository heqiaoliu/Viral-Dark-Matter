function uigroup_unrender(h,arg)
%UNRENDER Unrender group.

% This is a shared method so that subclasses of uimgr.uigroup (e.g.,
% uimgr.uifigure) can call same method

% Copyright 2007-2009 The MathWorks, Inc.
% $Revision: 1.1.6.3 $ $Date: 2009/03/09 19:34:11 $

% If group is not rendered, skip out quickly
%
% A quick (necessary but not sufficient) check:
%   is the graphical parent empty?
% If so, clearly none of our own children can be rendered
% Failing that, see if this group or any child has a
% valid widget (descent on children)
if isempty(h.GraphicalParent) || ~isRendered(h)
    return
end

% Confusion can exist here regarding when to have the parent
% update separator state (i.e., when do we send ChildUnrenderedEvent?)
% It's an important efficiency issue.
%
% We potentially have both a (local) widget, and children.
%
% Scenario 1: unrender ourselves, completely
%   Here we unrender all children
%    a) We have no (rendered) widget
%       Group is "inlined" with parent.
%       Unrendering all children still leaves the parent with
%       a decision: was the parent holding a mixed item/group,
%       and with this gone, is there an update required?
%       So the parent must update itself, but the parent does
%       NOT need to DESCEND on its other children.  We've updated
%       ourselves (no children!), and no other sibling groups
%       in the parent are affected.
%       ACTION: non-descending update of parent,
%               UNLESS parent suppresses update by indicating that
%               it is removing all of its own children as well
%
%    b) We have a (rendered) widget
%       Our children form an "hierarchical child" of parent.
%       Removing these children is isolated from the parent,
%       since they live on a submenu or other separate panel.
%       Our children should NOT send a cleanup event, since updating
%       their separators is a waste of time as we're just going
%       to unrender ALL of them anyway, in isolation of the parent.
%       There are no "intermixing of item/group" issues; the
%       children of this group were isolated to begin with.
%       So ... no update of parent due to unrendering of our children
%
%       But ... in this case, we also unrender the group widget,
%       if it is rendered.  It is here that we have incomplete
%       information: is this widget being unrendered in isolation?
%       or as part of a full group of children in the parent?
%       The parent must let us know.
%       ACTION: non-descending update of parent,
%               UNLESS parent suppresses update by indicating that
%               it is removing all of its own children as well
%
% Scenario 2: unrender one named child
%   Here we ask just one child to unrender.
%    a) We have no (rendered) widget
%       Group is "inlined" with parent.
%
%      1) If there are still other rendered children, this change
%      is "localized"; we should update separator state for our children
%      (non-descending), but no message needs to go to the parent.
%      ACTION: no event to the parent
%      ACTION: local non-descending update to our children
%
%      2) If there are no other rendered children, this group
%      "disappears" and the parent has to consider if any
%      "item/group" changes are required.
%      ACTION: non-descending update of parent
%
%    b) We have a (rendered) widget
%       Single localized change to a submenu or panel.
%      ACTION: no event to the parent
%      ACTION: local non-descending update to our children

% Parse args:
%
% If no child name specified, we're going to
% unrender all children in this group
% (including the widget itself, if present)
theName = '';
nameSpecified = false;
parentRemovingAllChildren = false;
if nargin>1
    if ischar(arg)
        nameSpecified = true;
        theName = arg;
    else
        parentRemovingAllChildren = arg;
    end
end
unrenderAllChildren = ~nameSpecified;

% A few concepts to keep straight here:
%
% 1 - have we unrendered all items from graphical parent?
%     e.g., all buttons gone from toolbar?
% 2 - have we unrendered all children from group?

% Unrender children first ... go "bottom up"
% Otherwise, if hWidget and children both exist and we start by
% unrendering the hWidget, an error can occur because
% .GraphicalParent is deleted and no longer valid at
% the end of the function.
%
% At least one rendered child in parent
% We don't know if there are rendered children in this group, however
%
if unrenderAllChildren
    hChild = h.down; % get first child
    while ~isempty(hChild)
        unrender(hChild, true); % we are a parentRemovingAllChildren
        hChild = hChild.right;    % get next child
    end
    
    % Now, unrender the group widget, if it was present and rendered.
    % Only unrender it if ALL children are being unrendered
    % We leave the widget if ONLY A NAMED CHILD is being unrendered
    %
    % Note that this group's widget exists in the context of a parent,
    % which may itself be a group.  We're unrendering ONE widget from
    % that group, and we must be told if this unrendering is part of a
    % "mass unrendering" of all items in the parent.  If it is, we can
    % suppress unnecessary side-work, and not send the UnrenderedEvent.
    %
    % Note:
    %   Unrendering a parent menu will automatically cause
    %   the children widgets to be deleted, so we should
    %   unrender those first.  Order is not a big deal, really,
    %   but we need to know that they were unrenderd "automatically"
    %   or we would accidentally try to unrender them again.
    unrender_widget(h,true);
    
    % Separator update
    %
    % If parent is removing ALL children, there's no need to do this
    % (since no children of parent will be left, hence no separators!)
    if ~parentRemovingAllChildren
        hParent = h.up;
        if ~isempty(hParent)
            enforceItemSeparators(hParent,true,false); % execute on parent
        end
    end
else
    % Unrender a named child
    %  - child handle could be empty if not found
    %    and that is an error by the caller
    hChild = h.findchild(theName);
    if isempty(hChild)
        error('uimgr:ChildNotFound', 'Child "%s" not found.', theName);
    end
    % treat hChild as a parent that is removing all its children
    unrender(hChild, true);
end

% [EOF]
