function v = getChildNames(h)
%getChildNames Return names of children in uigroup.

% Copyright 2004-2006 The MathWorks, Inc.
% $Revision: 1.1.6.3 $ $Date: 2008/02/02 13:12:14 $

v={};
h=h.down; % go to children
while ~isempty(h)
    v{end+1} = h.Name; %#ok
    h=h.right; % next child
end

% [EOF]
