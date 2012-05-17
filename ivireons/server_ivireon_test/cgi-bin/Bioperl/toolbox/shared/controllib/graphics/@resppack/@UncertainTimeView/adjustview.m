function adjustview(cv,cd,Event,NormalRefresh)
%ADJUSTVIEW  Adjusts view prior to and after picking the axes limits. 
%
%  ADJUSTVIEW(cVIEW,cDATA,'postlim') adjusts the HG object extent once  
%  the axes limits have been finalized (invoked in response, e.g., to a 
%  'LimitChanged' event).

%  Author(s): P. Gahinet
%  Copyright 1986-2010 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $  $Date: 2010/03/26 17:49:37 $

return
% RE: Assumes parent waveform contains valid data
if strcmp(Event,'postlim') 
   [s1,s2] = size(cv.UncertainPatch);
   % Position dot and lines given finalized axes limits
   for ct=1:s1*s2
      
      % Position objects
      set(double(cv.UncertainPatch(ct)),'XData',XData,'YData',YData,-10*ones(size(YData)))
      XData = [cd.Time;cd.Time(end:-1:1)];
      ZData = -10 * ones(size(XData));
      set(cv.UncertainPatch,'YData', [cd.UpperAmplitudeBound;cd.LowerAmplitudeBound(end:-1:1)],...
          'XData', XData,'ZData',ZData);
   end
end