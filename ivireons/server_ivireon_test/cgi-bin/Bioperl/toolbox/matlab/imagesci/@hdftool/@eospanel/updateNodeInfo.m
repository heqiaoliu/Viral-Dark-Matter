function updateNodeInfo(this, hdfNode)
%UPDATENODEINFO Set the CurrentNode for this panel.
%   Update any panels which might need to reflect this change.
%
%   Function arguments
%   ------------------
%   THIS: the eospanel object instance.
%   HDFNODE: the currently selected node.

%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2005/11/15 01:08:58 $

    if nargin>1
        this.currentNode = hdfNode;
    end

    % Refresh the relevant panel.
    activeIndex = this.subsetSelectionApi.getSelectedIndex();
    api = this.subsetApi{activeIndex};
    api.reset(this.currentNode.nodeinfostruct);
end
