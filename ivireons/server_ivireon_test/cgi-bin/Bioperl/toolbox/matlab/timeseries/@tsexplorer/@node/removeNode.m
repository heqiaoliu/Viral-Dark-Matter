function removeNode(this, leaf)
% REMOVENODE Removes the LEAF node from THIS node.  Note that this will not
% destroy the LEAF node unless there is no reference left to it somewhere else.

% Author(s):  
% Revised: 
%   Copyright 2004-2005 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2005/05/27 14:14:29 $

this.commonRemoveNode(leaf);

