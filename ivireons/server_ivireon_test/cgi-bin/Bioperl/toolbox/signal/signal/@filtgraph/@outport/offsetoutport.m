function oprt = offsetoutport(oprt,n,offset)
%OFFSETOUTPORT Offset the to(n).node of outport oprt

%   Author(s): S Dhoorjaty
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/12/26 22:13:51 $


oprt.to(n) = offsetnodeport(oprt.to(n),offset);
