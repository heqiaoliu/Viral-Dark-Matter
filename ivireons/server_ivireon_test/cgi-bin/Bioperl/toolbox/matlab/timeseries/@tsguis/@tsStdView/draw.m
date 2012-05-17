function draw(cv,cd,NormalRefresh)
%DRAW  Draws characteristic.
%
%  DRAW(cVIEW,cDATA) maps the characteristic data in cDATA to the HG
%  objects in cVIEW.

%  Author(s): John Glass
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $  $Date: 2005/06/27 23:02:23 $

if strcmp(cv.AxesGrid.YNormalization,'on')
   % RE: Defer to ADJUSTVIEW:postlim for normalized case (requires finalized X limits)
   set(double(cv.Lines),'XData',[],'YData',[],'ZData',[])
else
   % Position dot and lines given finalized axes limits      
   XData = [cd.StartTime cd.EndTime];
   ZData = -10*ones(5,1);
   for ct=1:prod(size(cv.Lines))  
      ax = cv.Lines(ct).Parent;
      Xlim = get(ax,'Xlim');
      XData = [max(cd.StartTime,Xlim(1));min(cd.EndTime,Xlim(2));...
          max(cd.StartTime,Xlim(1));max(cd.StartTime,Xlim(1));min(cd.EndTime,Xlim(2))];
      YData = [cd.MeanValue(ct)-cd.StdValue(ct);cd.MeanValue(ct)-cd.StdValue(ct);...
          NaN;cd.MeanValue(ct)+cd.StdValue(ct);cd.MeanValue(ct)+cd.StdValue(ct)];
      % Parent axes and limits
      set(double(cv.Lines(ct)),'XData',XData,...
         'YData',YData,'ZData',ZData)     
   end
end
