function setgraphvisibility(h,stat)
%SETGRAPHVISIBILITY
%
% Author(s): James G. Owen
% Revised:
% Copyright 1986-2006 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2006/06/20 20:29:11 $

if ~isempty(h.Window) && ishandle(h.Window)
   set(h.Window,'Visible',stat);
end