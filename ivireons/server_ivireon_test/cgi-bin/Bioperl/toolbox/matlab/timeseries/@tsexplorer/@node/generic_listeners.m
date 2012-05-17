function generic_listeners(this)
% GENERIC_LISTENERS Installs generic listeners for @node objects.

% Copyright 2004-2009 The MathWorks, Inc.
% $Revision: 1.1.6.8 $ $Date: 2009/10/29 15:23:13 $

% Add property listeners
L = [ handle.listener(this, 'ObjectChildAdded',     @LocalChildAdded); ...
      handle.listener(this, 'ObjectChildRemoved',   @LocalChildRemoved)];

set(L, 'CallbackTarget', this);
this.TreeListeners = [ this.TreeListeners; L(:) ];

% ---------------------------------------------------------------------------- %
% Child added to the UDD tree
function LocalChildAdded(this, hData)

child    = hData.Child;

Folder =  this.getTreeNodeInterface;
Leaf   = child.getTreeNodeInterface;

%% Find location in UDD tree and insert into same location in the Java
%% tree.
idx = Folder.getChildCount+1;
Folder.insert(Leaf, idx-1);
if ~isempty(this.getRoot) && ishandle(this.getRoot) &&...
        ~isempty(this.getRoot.tsviewer.TreeManager) &&...
        ishandle(this.getRoot.tsviewer.TreeManager)
    this.getRoot.tsviewer.TreeManager.Tree.nodesWereAdded(Folder,idx-1);
end
%% Install
child.generic_listeners;
LocalAddListeners(child);

% ---------------------------------------------------------------------------- %
% Child removed from the UDD tree
function LocalChildRemoved(this, hData)

child    = hData.Child;
Folder =  this.getTreeNodeInterface;
Leaf   = child.getTreeNodeInterface;

% Remove leaf from  the Java tree and find location in UDD tree.
idx = Folder.getIndex(Leaf);

% Get top node and fire event.
wksp = this.getRoot;

% Remove the node on the EDT so that there should be no time between when
% the node is absent from the table model and when the tree model and tree 
% have been updated by the call to nodesWereRemoved below (which is queued 
% to the EDT). This is necessary to avoid sporadic java exceptions when
% removing multiple nodes at once (reported in g578352).
awtinvoke(java(Folder),'remove(Ljavax.swing.tree.MutableTreeNode;)',...
    java(Leaf));

if isempty(wksp)
    return
end

if ~isempty(wksp.TsViewer) &&  ishandle(wksp.TsViewer) &&  ~isempty(wksp.TsViewer.TreeManager) && ...
        ishandle(wksp.TsViewer.TreeManager) && ~isempty(wksp.TsViewer.TreeManager.Tree) && ...
        ishandle(wksp.TsViewer.TreeManager.Tree)
    % Note that the uitreepeer queues the call to 
    % DefaultTreeModel.nodesWereRemoved to the EDT. 
    wksp.TsViewer.TreeManager.Tree.nodesWereRemoved(Folder,idx,{Leaf});
    
    childPanel = child.Dialog;
    if ~isempty(childPanel) && ishghandle(childPanel)
         delete(childPanel);
    end    
end

% Clean up
%child.cleanup;


% -------------------------------------------------------------------------%
% Add listeners to all children of this node
function LocalAddListeners(node)

children = node.find('-depth',1,'-isa','tsexplorer.node');
children(children==node) = [];

for ct = 1:length(children)
  hData.Child = children(ct);
  LocalChildAdded( node, hData )
end
