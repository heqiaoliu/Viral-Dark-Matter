function draw(cv,cd,NormalRefresh)
%DRAW  Draws characteristic.
%
%  DRAW(cVIEW,cDATA) maps the characteristic data in cDATA to the HG
%  objects in cVIEW.

%  Author(s): John Glass
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $  $Date: 2005/06/27 23:02:20 $

if strcmp(cv.AxesGrid.YNormalization,'on')
   % RE: Defer to ADJUSTVIEW:postlim for normalized case (requires finalized X limits)
   set(double(cv.Lines),'XData',[],'YData',[],'ZData',[])
else
   % Position dot and lines given finalized axes limits      
   XData = [cd.StartTime cd.EndTime];
   ZData = repmat(-10,size(XData));
   for ct=1:prod(size(cv.Lines))  
      ax = cv.Lines(ct).Parent;
      Xlim = get(ax,'Xlim');
      XData(1) = max(cd.StartTime,Xlim(1));
      XData(2) = min(cd.EndTime,Xlim(2));
      % Parent axes and limits
      Ymedian = cd.MedianValue(ct);
      set(double(cv.Lines(ct)),'XData',XData,...
         'YData',Ymedian(ones(size(XData))),'ZData',ZData)     
   end
end
