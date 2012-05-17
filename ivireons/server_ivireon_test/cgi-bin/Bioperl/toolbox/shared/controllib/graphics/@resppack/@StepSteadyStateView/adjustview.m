function adjustview(cv,cd,Event,NormalRefresh)
%ADJUSTVIEW  Adjusts view prior to and after picking the axes limits. 
%
%  ADJUSTVIEW(cVIEW,cDATA,'prelim') hides HG objects that might interfer  
%  with limit picking.
%
%  ADJUSTVIEW(cVIEW,cDATA,'postlimit') adjusts the HG object extent once  
%  the axes limits have been finalized (invoked in response, e.g., to a 
%  'LimitChanged' event).

%  Author(s): P. Gahinet
%  Copyright 1986-2007 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $  $Date: 2009/10/16 06:19:42 $

% RE: Assumes parent waveform contains valid data
if strcmp(Event,'postlim') 
   % Position dot and lines given finalized axes limits
   rData = cd.Parent;
   YNorm = strcmp(cv.AxesGrid.YNormalization,'on');
   % Position dot and lines given finalized axes limits
   for ct=1:numel(cv.Points)
      % Parent axes and limits
      ax = cv.Points(ct).Parent;
      Xlim = get(ax,'Xlim');
      % Adjust dot position based on the X limits
      XDot = Xlim(2);
      if ~isempty(rData.Time) && ~isempty(rData.Amplitude)
          YDot = utInterp1(rData.Time,rData.Amplitude(:,ct),XDot);
      else
          YDot = NaN;
      end
      if isfinite(cd.FinalValue(ct))
         % Finite steady state
         if YNorm && ~isempty(rData.Time) && ~isempty(rData.Amplitude)
            YDot = normalize(rData,YDot,Xlim,ct); % take normalization into account
         end
         Color = get(cv.Points(ct),'Color');
      else
         % Use white fill when steady state is not finite
         Color = get(ax,'Color');
      end      
      % Position objects
      set(double(cv.Points(ct)),'XData',XDot,'YData',YDot,'MarkerFaceColor',Color)
   end
end