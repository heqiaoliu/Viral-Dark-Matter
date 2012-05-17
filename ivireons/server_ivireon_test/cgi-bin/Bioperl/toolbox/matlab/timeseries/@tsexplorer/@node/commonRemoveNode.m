function commonRemoveNode(this, leaf)
% COMMONREMOVENODE Removes the LEAF node from THIS node.  Note that this will not
% destroy the LEAF node unless there is no reference left to it somewhere else.
% REMOVENODE methods of various nodes call this function.


% Copyright 2005-2008 The MathWorks, Inc.
% $Revision: 1.1.6.4 $ $Date: 2008/12/29 02:10:55 $

children = setdiff(this.find('-depth',1),this);

% Is leaf really a child of this?
if any( children == leaf )

    %have the tsstructurechange event fired
    V = [];
    try
        V = this.getRoot;
    catch
        V = [];
    end
    % update cache only for data nodes
    if ~isempty(V) && ~isempty(this.getParentNode)
        myEventData = tsexplorer.tstreeevent(V,'remove',leaf);
        V.fireTsStructureChangeEvent(myEventData,leaf.constructNodePath);
    end

    % Disconnect from the tree
    disconnect( leaf )

    % Remove all listeners
    delete( leaf.TreeListeners( ishandle(leaf.TreeListeners) ) )
    leaf.TreeListeners = [];

    leaf.Listeners.deleteListeners;

    % Delete leaf node
    %delete( leaf );
elseif isa( leaf, 'tsexplorer.node' )
    warning( '%s is not a leaf node of %s', leaf.Label, this.Label )
else
    error( '%s is not of type @explorer/@node', class(leaf) )
end
