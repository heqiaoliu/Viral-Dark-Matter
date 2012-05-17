function removeChildren(h,varargin)
%REMOVECHILDREN Unrender and remove children from hierarchy.
%  REMOVECHILDREN(H,NAME) unrenders and removes all children
%  of the named child from the hierarchy, where NAME is specified relative
%  to H.  H is not unrendered or removed.
%
%  REMOVECHILDREN(H) unrenders and removes all children of H
%  from the hierarchy.  H is not unrendered or removed.

% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2006/06/27 23:30:45 $

if nargin>1
    % Find child
    h = h.findchild(varargin{:});  % e.g., find {'File','Save'}
    if isempty(h)
        error('uimgr:ChildNotFound', 'Child not found.');
    end
end

% Disconnect all children, but leave the
% parent node (h).  To do this, we must
% visit each child and disconnect each.
%
hChild = h.down('last'); % get last child
while ~isempty(hChild)
    hNext = hChild.left; % cache next child
	% Recurse - depth first:
	if hChild.isGroup
		removeChildren(hChild);
	end
	%fprintf(' - disconnecting child "%s"\n', ...
    %	getFullName(hChild,':'));
	
	% unrender and disconnect THIS child
    hChild.disconnect;   % remove this child first, so that the
    hChild.unrender;     % order causes one-level unrender, only
    hChild = hNext;      % move to next child
end

% [EOF]
