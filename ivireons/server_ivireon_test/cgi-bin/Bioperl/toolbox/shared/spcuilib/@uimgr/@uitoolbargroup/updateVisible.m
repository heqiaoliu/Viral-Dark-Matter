function updateVisible(h,vis)
%updateVisible Update visibility of all children.

% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2006/06/27 23:32:04 $

% Since we're updating the visibility of all toolbars,
% we don't need the bug fix - so we disable it.
%
% Assumes that only uitoolbar's can be children of uitoolbargroup's
% since only uitoolbar's have a RenderOrderBugFixEnabled property

if nargin<2
    vis = h.Visible;
end
hChild = h.down; % get first child
while ~isempty(hChild)
    set(hChild, ...
        'RenderOrderBugFixEnabled',false, ...
        'Visible',vis);
    hChild = hChild.right; % get next child
end

% [EOF]
