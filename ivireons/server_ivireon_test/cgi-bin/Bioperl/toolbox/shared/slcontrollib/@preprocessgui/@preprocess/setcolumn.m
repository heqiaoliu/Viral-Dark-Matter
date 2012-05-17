function setcolumn(h,column)
%SETCOLUMN
%
% Author(s): James G. Owen
% Revised:
% Copyright 1986-2006 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2006/06/20 20:29:10 $

% This method is called from java to update the HG viewer
% display when the table header is selected. Listeners
% do the actual updating
h.Column = column;
if ~isempty(h.Window)
    set(h.Controls(10),'Value',column);
    figure(h.Window)
end