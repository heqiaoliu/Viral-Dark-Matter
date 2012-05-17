function hChild = findImmediateChild(h,matchFcn)
%findImmediateChild Return first-level child whose match function is true.
%   Visit first-level child nodes and apply match-function to each,
%   returning handle of child for which the match function returns true.
%   If no matching child is found, returns with empty handle.
%   Function must return a logical value.

% Copyright 2004-2006 The MathWorks, Inc.
% $Revision: 1.1.6.1 $ $Date: 2006/10/18 03:21:36 $

hChild = h.down; % first child
while ~isempty(hChild) && ~matchFcn(hChild)
    hChild=hChild.right;
end

% Alt: (includes parent in the match process!)
% hChild = find(h,'-depth',1,'-function',matchFcn);

% When code falls through, either:
%  - no match was found,
%    in which case we return with hChild set to empty
%  - match was found,
%    in which case the desired hChild is returned

% [EOF]
