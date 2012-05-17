function adjustview(cv,cd,Event,NormalRefresh)
%ADJUSTVIEW  Adjusts view prior to and after picking the axes limits. 
%
%  ADJUSTVIEW(cVIEW,cDATA,'postlim') adjusts the HG object extent once  
%  the axes limits have been finalized (invoked in response, e.g., to a 
%  'LimitChanged' event).

%  Author(s):  
%  Copyright 1986-2005 The MathWorks, Inc.
%  $Revision: 1.1.6.5 $ $Date: 2005/12/15 20:56:01 $

if strcmp(Event,'postlim')
   if strcmp(cv.AxesGrid.YNormalization,'on')

       % Adjust final value line in normalized mode
       for ct=1:prod(size(cv.VLines))
          % Parent axes and limits
          ax = ancestor(cv.VLines(ct).Parent,'Axes');
          Ylim = get(ax,'Ylim');
          Xlim = get(ax,'Xlim');
          % Time Interval is restricted to specified start/end  
          Xlim(1) = max(cd.Time,Xlim(1));
          Xlim(2) = min(cd.Time,Xlim(2));    
          
          Ypos = cd.Amplitude(ct);
          if isfinite(Ypos)
             Ypos = normalize(cd.Parent,Ypos,get(ax,'Xlim'),ct);
          end
          % Position objects
          set(double(cv.VLines(ct)),'XData',Xlim,'YData',[Ylim(1),Ylim(2)], ...
              'ZData',[-10,-10]) 
          
          % Draw the point markers
          Color = get(cv.Parent.Curves(ct),'Color');
          set(double(cv.Points(ct)),'XData',Xlim(1),'YData',Ypos,...
               'MarkerFaceColor',Color)
 
   
       end
   else
       draw(cv,cd,NormalRefresh)
   end
end
