function nd = offsetnode(nd,offst)
%OFFSETNODE Offset the index of node and its contents

%   Author(s): S Dhoorjaty
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/12/26 22:13:17 $


nd.index = nd.index + offst;
nd.block = offsetblock(nd.block,offst);