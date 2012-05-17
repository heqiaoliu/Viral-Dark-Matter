function nlist = removenode(nlist,indx)
%REMOVENODE removes node at index indx in nodelist nlist

%   Author(s): S Dhoorjaty
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/12/26 22:13:40 $

nlist.nodes(indx) = [];
nlist.nodeCount = nlist.nodeCount - 1;
