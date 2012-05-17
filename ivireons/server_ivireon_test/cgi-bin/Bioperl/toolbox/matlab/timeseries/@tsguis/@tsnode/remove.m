function remove(this,manager)

%   Copyright 2004-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $ $Date: 2005/06/27 23:03:28 $

if isempty(this.up)
    return
end


%% Select the root so the deleted node is not selected
manager.reset
manager.Tree.setSelectedNode(this.getParentNode.getTreeNodeInterface);
drawnow % Force the node to show selected
manager.Tree.repaint

if isa(this.up,'tsguis.tscollectionNode')
    this.up.removeTsCallback({this.Timeseries.Name});
else
    % refresh the transactions stack (flush transactions which contain a
    % reference to deleted timeseries) because a deletion of this node
    % cannot be undone
    utMayBeFlushTransactions(this,{this.Timeseries});
    this.up.removeNode(this);
end