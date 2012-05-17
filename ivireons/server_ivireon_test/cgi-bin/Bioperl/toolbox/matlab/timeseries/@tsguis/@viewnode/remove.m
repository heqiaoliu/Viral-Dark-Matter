function remove(this,manager)

% Copyright 2004-2005 The MathWorks, Inc.

%% Select the root so the deleted node is not selected
manager.reset
manager.Tree.setSelectedNode(this.getRoot.down.getTreeNodeInterface);
drawnow % Force the node to show seelcted
manager.Tree.repaint
this.up.removeNode(this)