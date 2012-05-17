function addPost(h, theChild, childIdx)
%ADDPOST Called just after child added to a parent.
%  Overload for uitoolbargroup.

% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2006/06/27 23:32:00 $

% Install bug-fix fcn into children
% (can safely assume children to be uitoolbar's)
%
% Must do this here in order to set childIdx properly
theChild.RenderOrderBugFixFcn = @()renderOrderBugFix(h,childIdx);

% [EOF]

