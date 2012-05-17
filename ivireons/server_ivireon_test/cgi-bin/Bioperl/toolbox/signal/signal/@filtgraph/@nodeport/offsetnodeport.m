function np = offsetnodeport(np,offset)
%OFFSETNODEPORT Offset the node property of nodeport np 

%   Author(s): S Dhoorjaty
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/12/26 22:13:46 $


np.node = np.node + offset;
