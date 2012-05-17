function draw(cv,cd,NormalRefresh)
%DRAW  Draws characteristic.
%
%  DRAW(cVIEW,cDATA) maps the characteristic data in cDATA to the HG
%  objects in cVIEW.

%  Author(s):  
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $  $Date: 2005/06/27 22:57:06 $

if ~NormalRefresh
    return
end

Axes = cv.AxesGrid.getaxes;
[s1,s2] = size(Axes); 

if strcmp(cv.AxesGrid.YNormalization,'on')
   % RE: Defer to ADJUSTVIEW:postlim for normalized case (requires finalized X limits)
   set(double(cv.VLines),'XData',[],'YData',[],'ZData',[])
else  
   % For each axes, only draw one view since all view of this event on the
   % same axes have the same position
    if ~isempty(cd.Event)
        evtime = cd.Time;
    else
        evtime = NaN;
    end
   for k=1:s1*s2
       theseVlines = findobj(cv.VLines,'Parent',Axes(k));    
       if ~isempty(theseVlines)>0
           % Draw vertical event lines
           Ylim = get(Axes(k),'Ylim');
           set(double(theseVlines(1)),'XData',[evtime,evtime],...
                 'YData',[Ylim(1) Ylim(2)],'ZData',[-10 -10],'Visible','on')
           % Hide duplicate lines
           set(theseVlines(2:end),'Visible','off')
       end
   end
   
   % Draw the point markers
   for k=1:prod(size(cv.Points))
       Color = get(cv.Parent.Curves(k),'Color');
       set(double(cv.Points(k)),'XData',evtime,'YData',cd.Amplitude(k),...
           'MarkerFaceColor',Color)
   end    
end



