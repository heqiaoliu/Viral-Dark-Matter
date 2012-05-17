function deleteAllChildren(h)
%DELETEALLCHILDREN <short description>
%   OUT = DELETEALLCHILDREN(ARGS) <long description>

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/09/09 21:29:47 $


% Delete all children  To do this, we must
% visit each child and delete each.
%
hChild = h.down('last'); % get last child
while ~isempty(hChild)
    hNext = hChild.left; % cache next child
    % Recurse - depth first:
    if hChild.isGroup
        deleteAllChildren(hChild);
    end
    
    % delete THIS child
    hChild.delete;
    hChild = hNext;      % move to next child
end
% [EOF]