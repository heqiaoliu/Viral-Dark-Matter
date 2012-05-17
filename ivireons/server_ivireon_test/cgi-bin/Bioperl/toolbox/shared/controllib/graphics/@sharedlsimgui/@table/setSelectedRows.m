function out1 = setSelectedRows(h,theseRows)

% SETSELECTEDROWS Returns the table size (including any leading column) to java

% Author(s): James G. Owen
% Revised:
% Copyright 1986-2005 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:26:34 $

import java.lang.*;

out1 = java.lang.Boolean(true);
try
   h.selectedrows = double(theseRows)+1;
catch
   out1 = java.lang.Boolean(false);
end

        