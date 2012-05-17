function draw(cv,cd,NormalRefresh)
%DRAW  Draws characteristic.
%
%  DRAW(cVIEW,cDATA) maps the characteristic data in cDATA to the HG
%  objects in cVIEW.

%  Author(s):  
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $  $Date: 2005/06/27 23:01:55 $

if strcmp(cv.AxesGrid.YNormalization,'on')
   % RE: Defer to ADJUSTVIEW:postlim for normalized case (requires finalized X limits)
   set(double(cv.VLines),'XData',[],'YData',[],'ZData',[])
   set(double(cv.Lines),'XData',[],'YData',[],'ZData',[])
else
   % Position dot and lines given finalized axes limits      
   XData = [cd.StartFreq cd.EndFreq];
   ZData = repmat(-10,size(XData));
   for ct=1:prod(size(cv.Lines))  
      ax = cv.Lines(ct).Parent;
      Xlim = get(ax,'Xlim');
      Ylim = get(ax,'Ylim');
      XData(1) = max(cd.StartFreq,Xlim(1));
      XData(2) = min(cd.EndFreq,Xlim(2));

      % Parent axes and limits
      set(double(cv.Lines(ct)),'XData',XData,...
         'YData',cd.Value(ct)*ones(size(XData)),'ZData',repmat(-10,size(XData)))
      if strcmp(cd.Parent.Accumulated,'off')
          set(double(cv.VLines(ct)),'XData',[XData(1) XData(1) NaN XData(2) XData(2)],...
             'YData',[cd.Value(ct) 0 NaN 0 cd.Value(ct)],'ZData',repmat(-10,[1 5])) 
      else
          set(double(cv.VLines(ct)),'XData',[XData(1) XData(1) NaN XData(2) XData(2)],...
             'YData',[cd.Value(ct) cd.LVariance(ct) NaN cd.RVariance(ct) cd.Value(ct)],...
             'ZData',repmat(-10,[1 5])) 
      end  
   end
end
