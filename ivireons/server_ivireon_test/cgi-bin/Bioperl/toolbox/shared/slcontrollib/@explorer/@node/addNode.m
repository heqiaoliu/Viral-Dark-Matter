function hOut = addNode(this, varargin)
% ADDNODE Adds a leaf node to this node.
%
% addNode()      % Adds a default child node.
% addNode(leaf)

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 1986-2005 The MathWorks, Inc.
% $Revision: 1.1.6.6 $ $Date: 2007/12/14 15:01:20 $

% If no leaf is supplied, add a default child
if isempty( varargin )
  leaf = this.createChild;
else
  leaf = varargin{1};
end

cls = 'explorer.node';
if isa( leaf, cls )
  if isUniqueName(this, leaf)
    connect( leaf, this, 'up' );
  else
    str = sprintf('Would you like to replace the existing node?');
    msg = sprintf('The folder %s already contains a node named %s.\n%s', ...
                  this.Label, leaf.Label, str);
    ButtonName = questdlg( msg, 'Confirm Node Replace', 'Yes', 'No', 'Yes' );

    switch ButtonName
      case 'Yes',
        nodes = this.getChildren;
        node = nodes( strcmp(get(nodes, {'Label'}), leaf.Label) );
        this.removeNode(node)
        connect( leaf, this, 'up' );
      case 'No',
        leaf = [];
    end
  end
elseif isempty(leaf)
  % Do nothing
else
  ctrlMsgUtils.error( 'SLControllib:explorer:InvalidArgumentType', 'LEAF', cls );
end

if nargout > 0
  hOut = leaf;
end

% -----------------------------------------------------------------------------
function flag = isUniqueName(this, leaf)
flag = true;

if isempty(this.getChildren)
  return
end

nodes = this.getChildren;
peers = nodes( leaf ~= nodes );
names = get( peers, {'Label'});

if any( strcmp( leaf.Label, names) )
  flag = false;
end
