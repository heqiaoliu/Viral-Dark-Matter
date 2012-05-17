function install(hInstall,hTarget)
%INSTALL Install plug-in tree into target application tree.
%   Does not render widgets during the install process;
%   caller must render hTarget when ready.  This is done
%   so that multiple plug-in's can be installed before
%   rendering.

% Copyright 2004-2006 The MathWorks, Inc.
% $Revision: 1.1.6.1 $  $Date: 2006/05/09 23:41:00 $

if ~isempty(hInstall)
    % Check that the install data (plug-in) is self-consistent,
    % and that it is compatible with the target application GUI
    validate(hInstall,hTarget);
    copyToTarget(hInstall,hTarget);
end

%%
function copyToTarget(hInstall,hTarget)
%copyToTarget Copy install tree (the plug-in) into target tree.
%
numNodes = size(hInstall.Plan,1); % # rows = # nodes to install
for i = 1:numNodes
    srcNode = hInstall.Plan{i,1};
    tgtAddr = hInstall.Plan{i,2};
    
    % Copy node from source group to dest group
    % There are as many addresses in addrs{i} as there are child nodes
    %
    % We must make a deep-copy of source nodes, otherwise the
    % tree contained in .SourceGroup will be corrupted - it
    % will have its children removed as nodes are added to target
    %
    thisParent = findchild(hTarget,tgtAddr);
    node_copy = copy(srcNode,'children');
    add(thisParent, node_copy);
end

% After all nodes have been plugged-in to hTarget app, we must
% now visit EVERY node in orig plug-in tree to fixup any
% properties (especially sync arg handles in the corresponding target
% application node) and things that need deep copies.
%
% Note that we must visit EVERY node in the INSTALL tree.
%
for i = 1:numNodes
    srcNode = hInstall.Plan{i,1};
    fixup_descend(srcNode, hInstall,hTarget);
end

%%
function fixup_descend(installNode,hInstall,hTarget)
% node: original plug-in node, NOT target node
% hTarget: target application tree

while ~isempty(installNode)
    fixup_descend(installNode.down,hInstall,hTarget); % depth-first search
    
    % Fixup target nodes, based on install tree
    if ~isempty(installNode.synclist)
        fixup_node(installNode,hInstall,hTarget);
    end

    % Note: skipping .SelConInstall
    % Selection constraints are automatically fixed
    % during render of the plug-in.  That's because renderPost
    % invokes updateSelectionConstraint(), which updates the
    % listeners and everything just works.  Neat!
    
    installNode = installNode.right; % next node
end

%%
function fixup_node(installNode,hInstall,hTarget)

% installNode from the install tree is passed in.
% We need to find the node in the target tree,
% then grab its sync list.
%
% We need to deep-copy the .synclist, as it's 
% currently a shallow copy of what's in hInstall
%
% Synclist items have sync functions that retain handles
% to nodes, and these nodes are no longer correct after a
% deep copy of the plug-in tree has been made.  The retained
% handles point to nodes in the original tree.  These handles
% need to point to the corresponding and newly copied nodes.

% Find the TARGET node corresponding to this INSTALL node
% Apply sync fixup to that node
% (installNode is NOT the right node to fix - it's fine already)
%
targetNode = findTargetNode(installNode, hInstall, hTarget);

% Reset certain properties that get shallow-copied
targetNode.Explorer = [];
targetNode.hWidget = [];

% Make a deep copy of the synclist for the target node
% This object did NOT get copies during the copy() function
% during copyToTarget.  That copy() only deep-copies the
% tree objects, but not properties within each object.
%
targetNode.synclist = copy(targetNode.synclist);
synclist = targetNode.synclist;

% We handle multiple sync targets for this one node.
% The number of sync targets can be obtained from the
% number of any of the properties, such as .Default:
N = numel(synclist.Default);
for i=1:N
    % Two types of callback functions,
    % with different arg lists for each
    %
    % Translate .ArgsRaw entries
    syncArgs = synclist.ArgsRaw{i};
    
    % The node handles in syncArgs are references to the OLD tree,
    % that is, the tree that is not installed into the target.
    % We want syncArgs to contain references to the TARGET tree,
    % however, so we translate these references accordingly.
    
    if synclist.Default(i)
        % Default sync fcn
        %   default: @(h,ev)SimpleWidgetSync(dstChild,ev);
        % Need to fixup "dstChild" handle, which is .syncArgs{1}
        syncArgs{1} = findTargetNode(syncArgs{1}, hInstall, hTarget);
    else
        % Non-default (user-defined mapping) sync fcn
        %   mapping: @(h,ev)mapFcn(hTarget,i,src,srcPerm(i),ev);
        % Need to fixup "hTarget" and "src" args
        syncArgs{1} = findTargetNode(syncArgs{1}, hInstall, hTarget);
        syncArgs{3} = findTargetNode(syncArgs{3}, hInstall, hTarget);
    end
    % Update .DstName, used for debug/explore info
    dstName = getPath(syncArgs{1});
    
    synclist.ArgsRaw{i} = syncArgs;
    synclist.DstName{i} = dstName;
end

%%
function targetNode = findTargetNode(origNode, hInstall, hTarget)
% Find target node corresponding to install (plug-in) node

% To do this, we get the plug-in path to this node
% and only keep the "first-level" child name.
%
% This is because all source (plug-in) nodes were copied to
% the target app, relative to DestAddrs{i} at the top level.
% The installer used DestAddrs to identify target reference nodes.
%
% Hence, any node of arbitrary depth in the plug-in tree
% will be located in the target app under one of the N
% target reference nodes.  We need to identify which of the
% N target reference nodes this node is under.  That'll
% tell us how to modify the plug-in path to be the target path.

% First, translate path from plug-in to target tree
% Need to know which of the N target path in hInstall
% this dstChild node lives under.
%
targetPath = findTargetPath(origNode, hInstall);
targetNode = findchild(hTarget,targetPath);
if isempty(targetNode)
    error('uimgr:uiinstaller:TargetNodeNotFound', ...
        'Failed to find plug-in node in target');
end

%%
function targetPath = findTargetPath(origNode, hInstall)
% Find target node path corresponding to install (plug-in) node path
%
% origNode is a node from the synclist args of a target application node.
% Prior to fix-up, this node is actually a reference to a SOURCE node.
% We must translate this to a reference to a TARGET node.
% That's why we're here!
%
% To do this, we get the installer target path corresponding to this node.
% All original source nodes were copied to the target app,
% relative to the target path.
% Hence, any node of arbitrary depth in the source tree
% will be located in the target app under one of the N
% target reference paths.  We need to identify which of the
% N target reference paths this node is under.  That'll
% tell us how to modify the source path to be the target path.

% Get root node of source tree
% Find matching row index in .Plan cell matrix
% Pull out corresponding target path
%
% Reminder: .Plan is 2-D cell matrix,
%    col 1 has source nodes, col 2 has target paths
%
root = getRoot(origNode);
plan = hInstall.Plan;
N    = size(plan,1); % # rows=# targets
idx  = [];
for i = 1:N
    if root == plan{i,1}
        idx = i;
        break
    end
end
if isempty(idx)
    error('uimgr:uiinstaller:SyncNodeNotFound', ...
        'Failed to find sync node in installer plan');
end
targetRefpath = plan{idx,2};
targetPath = [targetRefpath '/' getPath(origNode) ];

% [EOF]
