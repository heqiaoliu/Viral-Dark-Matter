function removeNode(this, leaf)
% REMOVENODE Removes the LEAF node from THIS node and deletes it.
% Note that this will also delete LEAF's subtree.
%
% removeNode(leaf)

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 1986-2006 The MathWorks, Inc.
% $Revision: 1.1.6.5 $ $Date: 2007/12/14 15:01:22 $

% If leaf is empty, no-op
if ~isempty(leaf)
  cls = 'explorer.node';

  % Is leaf really a child of this?
  children = this.getChildren;
  if any( children == leaf )
    % Disconnect leaf from the tree.
    disconnect( leaf )
    % Delete leaf node
    delete( leaf );
  elseif isa( leaf, cls )
    ctrlMsgUtils.warning( 'SLControllib:explorer:NotALeafNodeOf', ...
                          leaf.Label, this.Label );
  else
    ctrlMsgUtils.error( 'SLControllib:explorer:InvalidArgumentType', 'LEAF', cls );
  end
end
