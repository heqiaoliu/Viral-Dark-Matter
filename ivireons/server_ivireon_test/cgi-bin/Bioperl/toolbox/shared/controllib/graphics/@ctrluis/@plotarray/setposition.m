function setposition(h,Position)
%SETPOSITION   Sets plot array position and refreshes plot.

%   Author(s): P. Gahinet
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:17:00 $

h.Position = Position;  % RE: no listener!
% Refresh plot
if h.Visible
   refresh(h)
end
