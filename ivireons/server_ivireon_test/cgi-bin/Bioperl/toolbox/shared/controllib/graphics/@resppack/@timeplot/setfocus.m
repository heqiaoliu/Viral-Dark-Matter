function setfocus(this,xfocus,xunits,Domain)
%SETFOCUS  Specifies X-focus for time plots.
% 
%   SETFOCUS(PLOT,XFOCUS) specifies the time range 
%   to be displayed when the x-axis is in auto-range 
%   mode.  XFOCUS is specified in the current time
%   units.
%
%   SETFOCUS(PLOT,XFOCUS,XUNITS) specifies the time 
%   range in the time units XUNITS.

%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:25:26 $
ni = nargin;
if ni<3
   xunits = this.AxesGrid.XUnits;
end
if ni<4 || strcmpi(Domain,'time')
   this.TimeFocus = unitconv(xfocus,xunits,'sec');
end
