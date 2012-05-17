function updateVisible(h,vis)
%updateVisible Update visibility of toolbar.
%   Overloaded for uitoolbar.

% Copyright 2005-2009 The MathWorks, Inc.
% $Revision: 1.1.6.3 $ $Date: 2009/03/09 19:34:42 $

% Bug fix for toolbar visibility reordering:
%
% Toolbars do NOT render in as-created order when visibility
% is turned back on.  Instead, all bars must be set to
% invisible (and the graphics flushed via drawnow), then
% made visible once again in order of intended appearance.
%
% Note: only uitoolbar supports RenderOrderBugFixEnabled
%       and RenderOrderBugFixFcn
%
% If the toolbar is part of a group operation, or
%   there is no toolbargroup owning this toolbar,
%   then there is no need to work around the bug.
%   (because ALL the toolbars in the group are being handled together
%   in one operation, OR they are ALL being handled independently).
%
% Note: caller will not set up disableVisBugFix if there's
% no uitoolbargroup owning this toolbar.

if nargin<2
    vis = h.Visible;
end

% When should we execute the toolbar-ordering bug fix?
%  - when vis of toolbargroup is changing
%      - equiv: when RenderOrderBugFixEnabled is turned on
%  - when vis=on (not when vis=off)

% If we're turning OFF a toolbar, no bug fix is needed
% Just hurry up and make it invisible:
%
if strcmpi(vis,'off') ...
        || ~h.RenderOrderBugFixEnabled ...
        || isempty(h.RenderOrderBugFixFcn)
    hh = h.hWidget;
    if ~isempty(hh)
        set(hh,'visible',vis);
    end
else
    % Execute the toolbar order bug fix
    h.RenderOrderBugFixFcn();
end

% Always set this to TRUE when done
% Only toolbargroup's updateVis will set it to false
%  so "all-toolbar-wide" vis changes suppress this action
%  (more efficient - bug fix not needed in that one case)
h.RenderOrderBugFixEnabled = true;

% [EOF]
