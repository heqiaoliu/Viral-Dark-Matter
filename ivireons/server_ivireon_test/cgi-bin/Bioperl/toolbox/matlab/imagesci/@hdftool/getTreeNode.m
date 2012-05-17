function obj = getTreeNode(uitreenodehandle)
%GETTREENODE Return the data associated with a UITREENODE.
%
%   Function arguments
%   ------------------
%   UITREENODEHANDLE: the treenode for which to return data.

%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2005/11/15 01:10:49 $

    % Obtain the node structure, given a handle to a node object.
    fn = get(uitreenodehandle,'UserData');
    obj = fn();
end
