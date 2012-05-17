function addlisteners(this, L)
%ADDLISTENERS  Adds new listeners to listener set.

% Author(s): James G. Owen
% Revised:
% Copyright 1986-2006 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2006/06/20 20:28:40 $


this.Listeners = [this.Listeners; L];
