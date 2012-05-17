function rmappdata(h,name)
%RMAPPDATA Remove application-defined data.
%  RMAPPDATA(H, NAME) removes the application-defined data NAME,
%  from the UIMgr object specified by handle H.

% Copyright 2004-2006 The MathWorks, Inc.
% $Revision: 1.1.6.1 $  $Date: 2006/06/11 17:30:13 $

h.AppData = rmfield(h.AppData,name);

% [EOF]
