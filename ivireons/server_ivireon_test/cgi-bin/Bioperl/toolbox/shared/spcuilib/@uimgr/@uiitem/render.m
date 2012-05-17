function render(h,hInitialParent)
%RENDER Render an item.
%   This adds the equivalent of an HG child to the item.
%   Keep in mind, this is a SINGLE ITEM, not a group.

% Copyright 2004-2006 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2006/06/27 23:31:11 $

% .Parent is an optional manual override that is user-specified
%
% It is the handle that is to be used as the parent for the
% group widget itself.  It is used for the group children ONLY
% if the group has no widget itself; otherwise, the group widget
% becomes the parent handle for the children.
if ~isempty(h.Parent)
    % .Parent takes top priority for changing .GraphicalParent
    h.GraphicalParent = h.Parent;
elseif nargin>1
    % 2nd input arg has lower priority than .Parent
    %
    % Parent handle is generally passed in by a recursive
    % call from group:render() itself
    h.GraphicalParent = hInitialParent;
end

render_widget(h);

% [EOF]
