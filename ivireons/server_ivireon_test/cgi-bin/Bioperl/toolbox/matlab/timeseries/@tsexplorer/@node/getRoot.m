function h = getRoot(this)
% GETROOT Returns the NEAREST node up in the tree hierarchy labeled as root

%   Copyright 2004-2005 The MathWorks, Inc.
%   % Revision % % Date %
% If no root is found returns itself.
h = this;

% Search for the root
while ~isa(h, 'tsexplorer.Workspace')
  h = h.up;
  if isempty(h)
      return;
  end
end
