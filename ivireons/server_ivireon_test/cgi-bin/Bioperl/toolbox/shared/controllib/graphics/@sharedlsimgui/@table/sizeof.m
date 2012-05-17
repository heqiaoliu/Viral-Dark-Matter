function out1 = sizeof(h)

% SIZEOF Returns the table size (including any leading column) to java

% Author(s): James G. Owen
% Revised:
% Copyright 1986-2005 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:26:35 $

out1 = javaArray('java.lang.Double',2);
out1(2) = java.lang.Double(size(h.celldata,2));
out1(1) = java.lang.Double(size(h.celldata,1));
        