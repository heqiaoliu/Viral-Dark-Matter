function h = initialtable(x, colnames)

% INITIALTABLE Constructor

% Author(s): James G. Owen
% Revised:
% Copyright 1986-2003 The MathWorks, Inc.
% $Revision: 1.1.6.4 $ $Date: 2005/12/22 17:38:45 $

h = lsimgui.initialtable;
h.celldata = x;
h.colnames = colnames;

