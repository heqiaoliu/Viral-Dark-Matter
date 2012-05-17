function selectnode(h, name)
%SELECTNODE selects the specified system in the tree

%   Copyright 2007-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2009/04/21 03:18:52 $

nodes = getchildnodes(h, h.getRoot);
idx = getsystembyname(nodes, name);
if ~isempty(idx)
    node = nodes(idx);
    ch = h.getRoot.gethchildren;
    child = ch.find('-Depth',0,'Path',node.daobject.Path,'-and','Name',node.daobject.Name);
    % If the system of interest is not visible in the tree hierarchy, expand the top level subsystem and then highlight the
    % system node. Otherwise, just highlight the system node.
    if isempty(child)
        % Check if the system node is visible within a depth of 2. For systems embedded deeper than 3 layers, we know that 
        % expanding the top level subsystem is not enough and will result in an empty dialog view.
        child_node =  ch.find('-Depth',2,'Path',node.daobject.Path,'-and','Name',node.daobject.Name);
        if isempty(child_node)
            selectTreeViewNode(h.imme, h.getRoot); 
        else
            % Find the top level subsystem and expand that node.
            idx = findstr(node.CachedFullName,'/');
            par_name = node.CachedFullName(1:idx(2)-1);
            nIdx = getsystembyname(nodes, par_name);
            if ~isempty(nIdx)
                h.imme.expandTreeNode(nodes(nIdx));
            end
            selectTreeViewNode(h.imme, node);
        end
    else
        selectTreeViewNode(h.imme, node); 
    end
else
    % If the system of interest is not present in the model hierarchy, highlight the root node.  
    selectTreeViewNode(h.imme, h.getRoot); 
end
  
%--------------------------------------------------------------------------
function [si, ss] = getsystembyname(hc, name)
si = [];
ss = [];
name = fxptds.getpath(name);
for i=1:length(hc)
    if (~isempty(hc(i).cachedFullName))
        thisname = fxptds.getpath(hc(i).cachedFullName);
        if (strcmpi(thisname, name))
            si = i;
            ss = hc(i);
            break;
        end
    end
end

%--------------------------------------------------------------------------
function children = getchildnodes(me, parent)

children = parent.getHierarchicalChildren';
if (isempty(children))
	return;
end
n = numel(children);
for chIdx = 1:n
  child = children(chIdx);
	newchildren = getchildnodes(me, child);
  children = [children newchildren];
end

%-----------------------------------------------------------------------------
function locExpandParentTreeNode(me,nodes, node)


%-------------------------------------------------------------------------
% [EOF]
