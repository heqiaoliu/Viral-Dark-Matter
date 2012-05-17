function hOut = commonAddNode(this, varargin)
% called by addNode so that uitreenodes are connected

% Copyright 2005-2008 The MathWorks, Inc.

% If no leaf is supplied, add a default child
if isempty( varargin )
  leaf = this.createChild;
else
  leaf = varargin{1};
end

if isa( leaf, 'tsexplorer.node' )
  connect( leaf, this, 'up' );
  %drawnow
  %this.TreeNode.add(leaf.TreeNode);
elseif isempty(leaf)
  % removed
  % warning( 'Leaf node is empty.' )
else
  error( '%s is not of type @explorer/@node', class(leaf) )
end

hOut = leaf;
