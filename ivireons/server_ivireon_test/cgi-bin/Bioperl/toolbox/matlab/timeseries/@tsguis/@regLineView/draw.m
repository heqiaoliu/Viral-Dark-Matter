function draw(cv,cd,NormalRefresh)
%DRAW  Draws characteristic.
%
%  DRAW(cVIEW,cDATA) maps the characteristic data in cDATA to the HG
%  objects in cVIEW.

%  Author(s): John Glass
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $  $Date: 2005/06/27 22:59:13 $

if strcmp(cv.AxesGrid.YNormalization,'on')
   % RE: Defer to ADJUSTVIEW:postlim for normalized case (requires finalized X limits)
   set(double(cv.Lines),'XData',[],'YData',[],'ZData',[])
else
   % Position dot and lines given finalized axes limits      
   for ct=1:prod(size(cv.Lines))  
      ax = cv.Lines(ct).Parent;
      Xlim = get(ax,'Xlim');
      Xdata = [Xlim(1); Xlim(2)];
      Ydata = cd.Slopes(ct)*Xdata+cd.Biases(ct)*[1;1];
      % Parent axes and limits
      set(double(cv.Lines(ct)),'XData',Xdata,...
         'YData',Ydata,'ZData',[-10 10])     
   end
end
