function iprt = offsetinport(iprt,offset)
%OFFSETINPORT Offset the from.node of an inport 

%   Author(s): S Dhoorjaty
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/12/26 22:13:10 $


iprt.from = offsetnodeport(iprt.from,offset);
