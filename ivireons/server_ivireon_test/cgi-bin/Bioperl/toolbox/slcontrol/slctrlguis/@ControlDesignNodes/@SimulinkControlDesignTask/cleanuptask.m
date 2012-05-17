function cleanuptask(this)
% CLEANUPTASK
%  Clean up task
%

%  Author(s): John Glass
%  Revised:
% Copyright 2004-2006 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2007/02/06 20:02:27 $

% % Clean up the block tree
% BlockTree = this.BlockTree;
% LocalRemoveBlockChildren(BlockTree,BlockTree.getChildren)
% parent = BlockTree.up;
% if ~isempty(parent)
%     delete(BlockTree.TableListener)
%     removeNode(parent,BlockTree);
% else
%     delete(BlockTree)
% end
% 
% % Clean up the signal tree
% SignalTree = this.SignalTree;
% LocalRemoveSignalChildren(SignalTree,SignalTree.getChildren)
% parent = SignalTree.up;
% if ~isempty(parent)
%     removeNode(parent,SignalTree);
% else
%     delete(SignalTree)
% end
% 
% % Delete the design tasks
% Children = this.getChildren;
% for ct = numel(Children):-1:1
%     cleanup(Children(ct));
%     removeNode(this,Children(ct))
% end
% 
% removeNode(this.up,this)

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LocalRemoveBlockChildren
function LocalRemoveBlockChildren(node,children)
for ct = numel(children):-1:1
    childchildren = children(ct).getChildren;
    if ~isempty(childchildren)
        LocalRemoveBlockChildren(children(ct),childchildren)
    end
    delete(children(ct).TableListener)
    removeNode(node,children(ct))
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LocalRemoveChildren
function LocalRemoveSignalChildren(node,children)
for ct = numel(children):-1:1
    childchildren = children(ct).getChildren;
    if ~isempty(childchildren)
        LocalRemoveSignalChildren(children(ct),childchildren)
    end
    removeNode(node,children(ct))
end