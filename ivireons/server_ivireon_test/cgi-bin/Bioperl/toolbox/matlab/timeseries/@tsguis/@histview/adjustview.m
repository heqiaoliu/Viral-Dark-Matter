function adjustview(View,Data,Event,NormalRefresh)
%ADJUSTVIEW  Adjusts view prior to and after picking the axes limits. 
%
%  ADJUSTVIEW(VIEW,DATA,'postlim') adjusts the HG object extent once the 
%  axes limits have been finalized (invoked in response, e.g., to a 
%  'LimitChanged' event).

%  Author(s):  
%  Copyright 1986-2005 The MathWorks, Inc.
%  $Revision: 1.1.6.3 $ $Date: 2005/12/15 20:56:18 $



%% Input and output sizes
AxGrid = View.AxesGrid;
[Ny, Nu] = size(View.Curves);

if strcmp(Event,'postlim') & strcmp(View.AxesGrid.YNormalization,'on')
   % Draw normalized data once X limits are finalized
      for ct=1:prod(size(View.Curves))
         [MSG,X,Y,XX,YY] = makebars(Data.XData,Data.YData(:,ct)); 
         Xlims = get(ancestor(View.Curves(ct),'Axes'),'Xlim'); 
         [ymin,ymax,FlatY] = ydataspan(XX,YY,Xlims);
         YData = YY/(ymax+FlatY);
      
         if ~isempty(YData)
             set(double(View.Curves(ct)),'XData',XX,'YData',YData)
         else
             set(double(View.Curves(ct)),'XData',[],'YData',[])
         end
      end 
end