function remove(this,manager)
% remove this node

%  Copyright 2005 The MathWorks, Inc. 
%  $Revision: 1.1.6.4 $ $Date: 2006/10/10 02:26:57 $

if isempty(this.up)
    return
end


%% Select the root so the deleted node is not selected
manager.reset
manager.Tree.setSelectedNode(this.getRoot.down.getTreeNodeInterface);
drawnow % Force the node to show seelcted
manager.Tree.repaint

% refresh the transactions stack (flush transactions which contain a
% reference to deleted timeseries) because a deletion of this node cannot
% be undone

Tslist = {};
names = this.Tscollection.gettimeseriesnames;
for k = 1:length(names)
    Tslist{k} = this.Tscollection.getInternalProp([],names{k});
end
if isempty(Tslist) 
    utMayBeFlushTransactions(this,Tslist);
end

% now remove this node from the tree
this.up.removeNode(this);
