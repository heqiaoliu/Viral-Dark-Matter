function h = getParentNode(this)
% getParentNode returns the handle to the parent node for a particular
% branch, either tsparentnode or simulinkTsParentNode

%   Copyright 2005 The MathWorks, Inc.
%   % Revision: % % Date: %

% If no root is found returns itself.
h = this;
if strcmp(class(h),'tsexplorer.Workspace')
    h = [];
    return;
end

% Search for the root
while ~isempty(h) && ~h.isRoot 
    h = h.up;
end
