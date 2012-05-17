function child = createChild(h,varargin)
% creates the children nodes.

%   Copyright 2005-2008 The MathWorks, Inc. 
%   $Revision: 1.1.6.4 $ $Date: 2008/07/18 18:44:19 $


newObj = varargin{1};

try
    child = createTstoolNode(newObj,h); %method of the data object "newObj"
    if ~isempty(child)
        child = h.addNode(child);
    end

    %% Expand and select the newly added node
    % The setSelectedNode method will ultimately be executed on the awt thread.
    % Consequently if >1 nodes are being added its callback (getDialogInterface)
    % may fire after the 2nd or higher node has been added. This
    % would result in two or more node panels being visible at one.
    %if nargin<=2 || ~varargin{1}
    h.getRoot.Tsviewer.TreeManager.Tree.expand(h.getTreeNodeInterface);
    h.getRoot.Tsviewer.TreeManager.Tree.setSelectedNode(child.getTreeNodeInterface);
    %end
catch me
    error('tsCollectionNode:createChild:invMethod',...
        'Please supply a valid createTstoolNode method for %s',class(newObj));
end


