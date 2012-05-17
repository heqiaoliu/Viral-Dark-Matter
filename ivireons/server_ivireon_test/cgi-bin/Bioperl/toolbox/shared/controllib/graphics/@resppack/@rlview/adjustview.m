function adjustview(View,Data,Event,varargin)
%ADJUSTVIEW  Adjusts view prior to and after picking the axes limits. 
%
%  ADJUSTVIEW(VIEW,DATA,'prelim') clips unbounded branches of the locus
%  using the XFocus and YFocus info in DATA before invoking the limit
%  picker.
%
%  ADJUSTVIEW(VIEW,DATA,'postlimit') restores the full branch extent once  
%  the axes limits have been finalized (invoked in response, e.g., to a 
%  'LimitChanged' event).

%  Author(s): P. Gahinet
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $Date: 2009/10/16 06:23:52 $

switch Event
case 'prelim'
   % Clip portion of branches extending beyond XFocus and YFocus
   for ct=1:length(View.Locus)
      b = View.Locus(ct);
      % RE: Set min extent to focus box to avoid "shrinking focus" effect
      %     when the locus is sparsely sampled near the box edge (see
      %     sys = zpk(z,p,5.3734e+09) in TRLOC)
      set(double(b),'Xdata',Data.XFocus,'YData',Data.YFocus)
   end
   
case 'postlim'
   % Restore branches to their full extent
   draw(View,Data)
end