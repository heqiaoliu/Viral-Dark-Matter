function updateNodeInfo(this, hdfNode)
%UPDATENODEINFO Set the currentNode for this panel.
%   This is necessary when the selected node changes, for example.

%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2005/11/15 01:09:35 $
  
    if nargin>1
        this.currentNode = hdfNode;
    end

end
