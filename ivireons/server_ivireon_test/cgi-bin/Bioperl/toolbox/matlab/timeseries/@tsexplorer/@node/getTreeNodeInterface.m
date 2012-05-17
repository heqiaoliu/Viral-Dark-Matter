function node = getTreeNodeInterface(this)
% GETTREENODEINTERFACE Returns uitreenode associated with this
% object.

% Copyright 2004-2008 The MathWorks, Inc.

if isempty(this.TreeNode )
  this.TreeNode = uitreenode('v0',this,this.Label,this.Icon,~this.AllowsChildren);
  
  % Cache the udd object handle in the user object property
  %this.TreeNode.setUserObject(this);
  
  % Add property listeners
  L = handle.listener(this, findprop(this, 'Label'), ...
      'PropertyPostSet', @LocalUDDPropertyChange );
  set(L, 'CallbackTarget', this);
  this.TreeListeners = [ this.TreeListeners; L ];
end
node = this.TreeNode;

% ----------------------------------------------------------------------------- %
% Update Java objects when a UDD property changes.
function LocalUDDPropertyChange(this, hData) %#ok<INUSD>

Node  = this.TreeNode;

%% Fire event only if Java label has really changed.
if ~strcmp(Node.getName, this.Label)
Node.setName( this.Label );

%% Refresh the tree to accommodate any chnage in label size
awtinvoke(this.getRoot.TsViewer.TreeManager.Tree.getModel,...
    'nodeChanged(Ljavax/swing/tree/TreeNode;)',java(Node))

% Get top node and fire event.
%     newData = { Node };
%     wksp = handle( Node.getRoot.getObject );
%     wksp.firePropertyChange('NODE_CHANGED', [], newData);
end
  
