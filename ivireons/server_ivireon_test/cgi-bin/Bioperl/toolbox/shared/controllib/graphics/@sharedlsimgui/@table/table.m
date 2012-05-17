function h = table(x, colnames)

% TABLE Constructor

% Author(s): James G. Owen
% Revised:
% Copyright 1986-2005 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:26:36 $

h = sharedlsimgui.table;
h.celldata = x;
h.colnames = colnames;

