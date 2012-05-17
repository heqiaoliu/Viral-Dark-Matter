function removeNode(this, leaf)
% REMOVENODE Removes the LEAF node from THIS node.  Note that this will not
% destroy the LEAF node unless there is no reference left to it somewhere else.

% Copyright 2005 The MathWorks, Inc.
% $Revision: 1.1.6.3 $ $Date: 2005/11/27 22:43:15 $

if ~strcmp(class(this),'tsguis.simulinkTsParentNode')
    % do not remove the node
    return;
end

this.commonRemoveNode(leaf); %tsexplorer/node method
%delete(leaf);