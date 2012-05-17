function prt = offsetport(prt,offset)
%OFFSETPORT Offsets the nodeIndex of port prt

%   Author(s): S Dhoorjaty
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/12/26 22:13:58 $

prt.nodeIndex = prt.nodeIndex + offset;
