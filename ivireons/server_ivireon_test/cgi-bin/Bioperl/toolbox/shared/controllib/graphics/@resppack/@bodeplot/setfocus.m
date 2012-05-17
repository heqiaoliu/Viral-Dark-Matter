function setfocus(this,xfocus,xunits,Domain)
%SETFOCUS  Specifies X-focus for Bode plots.
% 
%   SETFOCUS(PLOT,XFOCUS) specifies the frequency range 
%   to be displayed when the x-axis is in auto-range 
%   mode.  XFOCUS is specified in the current frequency
%   units. 
%
%   SETFOCUS(PLOT,XFOCUS,XUNITS) specifies the frequency 
%   range in the frequency units XUNITS.

%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:20:19 $
ni = nargin;
if ni<3
   xunits = this.AxesGrid.XUnits;
end
if ni<4 || strcmpi(Domain,'frequency')
   this.FreqFocus = unitconv(xfocus,xunits,'rad/sec');
end
