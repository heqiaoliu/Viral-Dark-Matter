function draw(cv,cd,NormalRefresh)
%DRAW  Draws characteristic.
%
%  DRAW(cVIEW,cDATA) maps the characteristic data in cDATA to the HG
%  objects in cVIEW.

%  Author(s):  
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $  $Date: 2005/06/27 22:57:38 $

if ~NormalRefresh
    return
end

Axes = cv.AxesGrid.getaxes;
[s1,s2] = size(Axes); 

if strcmp(cv.AxesGrid.YNormalization,'on')
   % RE: Defer to ADJUSTVIEW:postlim for normalized case (requires finalized X limits)
   set(double(cv.Lines),'XData',[],'YData',[],'ZData',[])
else  
   % Position dot and lines given finalized axes limits      
   for ct=1:prod(size(cv.Lines))  
      ax = cv.Lines(ct).Parent;
      Ylim = get(ax,'Ylim');
      % Parent axes and limits
      Xmean = cd.MeanValue(ct);
      set(double(cv.Lines(ct)),'XData',[Xmean Xmean],...
         'YData',Ylim,'ZData',[-10 -10])     
   end

end



