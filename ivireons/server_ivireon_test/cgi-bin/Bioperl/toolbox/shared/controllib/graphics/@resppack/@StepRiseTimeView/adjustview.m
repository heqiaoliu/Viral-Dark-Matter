function adjustview(cv,cd,Event,NormalRefresh)
%ADJUSTVIEW  Adjusts view prior to and after picking the axes limits. 
%
%  ADJUSTVIEW(cVIEW,cDATA,'postlim') adjusts the HG object extent once  
%  the axes limits have been finalized (invoked in response, e.g., to a 
%  'LimitChanged' event).

%  Author(s): P. Gahinet
%  Copyright 1986-2007 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $  $Date: 2009/10/16 06:19:34 $

% RE: Assumes parent waveform contains valid data
if strcmp(Event,'postlim') 
   rData = cd.Parent;
   [s1,s2] = size(cv.Points);
   YNorm = strcmp(cv.AxesGrid.YNormalization,'on');
   Xauto = strcmp(cv.AxesGrid.XlimMode,'auto');
   % Position dot and lines given finalized axes limits
   for ct=1:s1*s2
      % Parent axes and limits
      ax = cv.Points(ct).Parent;
      Xlim = get(ax,'Xlim');
      % Dot position
      TLow = cd.TLow(ct);
      THigh = cd.THigh(ct);
      if isfinite(THigh)
         % Response has fully risen: display complete info
         XDot = THigh;
         YDot = cd.Amplitude(ct);
         Color = get(cv.Points(ct),'Color');
      else
         if Xauto(ceil(ct/s1))
            % Response has not fully risen or is unstable:
            % position dot on response line near upper X limit
            XDot = 0.999*Xlim(2);
            YDot = utInterp1(rData.Time,rData.Amplitude(:,ct),XDot);
         else
            XDot = NaN;
            YDot = NaN;
         end
         Color = get(ax,'Color');
      end

      % Take normalization into account
      if YNorm && isfinite(YDot)
         YDot = normalize(rData,YDot,Xlim,ct);
      end
      
      % Position objects
      set(double(cv.Points(ct)),'XData',XDot,'YData',YDot,'MarkerFaceColor',Color)
      if isfinite(THigh)
         Ylim = get(ax,'Ylim');
         set(double(cv.LowerVLines(ct)),...
            'XData',[TLow TLow],'YData',[Ylim(1) YDot],'Zdata',[-10 -10]) 
         set(double(cv.UpperVLines(ct)),...
            'XData',[THigh THigh],'YData',[Ylim(1) YDot],'Zdata',[-10 -10])  
         set(double(cv.HLines(ct)),'XData',...
            [Xlim(1) XDot],'YData',[YDot YDot],'Zdata',[-10 -10])
      else
         set(double([cv.LowerVLines(ct); cv.UpperVLines(ct); cv.HLines(ct)]),...
            'XData',[],'YData',[],'ZData',[])
      end
   end
end