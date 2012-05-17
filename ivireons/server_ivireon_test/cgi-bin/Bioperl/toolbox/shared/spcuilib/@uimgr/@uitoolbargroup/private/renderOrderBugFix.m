function renderOrderBugFix(h,childIdx)
%renderOrderBugFix Fixes re-ordering problem when
%   turning on visibility of toolbars in multi-toolbar
%   applications.  Basically, when a toolbar is made
%   invisible, then visible again, it is rendered as
%   the LAST toolbar, regardless of where it was rendered
%   when it was first made invisible.
%
% ChildIdx indicates the child index (storage order, not placement order)
% that is about to turn "on" now.

% Copyright 2004-2009 The MathWorks, Inc.
% $Revision: 1.1.6.4 $  $Date: 2009/04/27 19:55:20 $

% A child toolbar has changed visibility
% Make all invisible, flush the queue,
% then make them visible in-order

% Find rendering order of visible children (toolbars)
% Be sure to pass the super-secret "visIdx" flag, which
% causes computeChildOrder to think that this child is
% visible, even though we know it's not quite yet visible
% (because we're in a "Set-function" callback situation,
% which executes us BEFORE the change is actually made)
%
childOrderObj = computeChildOrder(h,false,childIdx);

% Make all children invisible
% (including, perhaps, the one that was just made invis)
% Order doesn't really matter
% (Can turn off in placement order, or creation order)
for i = 1:length(childOrderObj)
    hChild = childOrderObj{i};
    set(hChild.hWidget,'Visible','off');
end

% Make them visible, in placement order
for i = 1:length(childOrderObj)
    hChild = childOrderObj{i};
    % Must force in-order graphical flush to work around bug
    set(hChild.hWidget,'Visible','on');
    drawnow expose;
end

% [EOF]
