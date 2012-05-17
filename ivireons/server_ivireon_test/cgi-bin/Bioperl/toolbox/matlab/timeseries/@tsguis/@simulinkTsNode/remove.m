function remove(this,manager)
% remove this node

%   Copyright 2005 The MathWorks, Inc. 
%   $Revision: 1.1.6.2 $ $Date: 2005/06/27 22:59:57 $

if isempty(this.up)
    return
end


%% Select the root so the deleted node is not selected
manager.reset
manager.Tree.setSelectedNode(this.up.getTreeNodeInterface);
drawnow % Force the node to show seelcted
manager.Tree.repaint

% refresh the transactions stack (flush transactions which contain a
% reference to deleted timeseries) because a deletion of this node cannot
% be undone
utMayBeFlushTransactions(this,{this.Timeseries});

%remove the node now
this.up.removeNode(this);
