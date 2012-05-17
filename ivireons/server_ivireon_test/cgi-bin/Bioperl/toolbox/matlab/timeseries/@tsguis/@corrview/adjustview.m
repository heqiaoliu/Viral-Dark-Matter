function adjustview(View,Data,Event,NormalRefresh)
%ADJUSTVIEW  Adjusts view prior to and after picking the axes limits. 
%
%  ADJUSTVIEW(VIEW,DATA,'postlim') adjusts the HG object extent once the 
%  axes limits have been finalized (invoked in response, e.g., to a 
%  'LimitChanged' event).

%  Author(s):  
%  Copyright 1986-2005 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $ $Date: 2005/06/27 22:56:48 $


%% Input and output sizes
AxGrid = View.AxesGrid;
[Ny, Nu] = size(View.Curves);

if strcmp(Event,'postlim') & strcmp(View.AxesGrid.YNormalization,'on')
    % Draw normalized data once X limits are finalized
    % Draw points
    for row=1:Ny
        for col=1:Nu
            ct=(row-1)*Nu+col;
            [T,Y] = stairs(Data.Lags,Data.CData(:,row,col));
            Xlims = get(ancestor(View.Curves(ct),'Axes'),'Xlim'); 
            [ymin,ymax,FlatY] = ydataspan(T,Y,Xlims);            
            YData = (Y - (ymin+ymax)/2)/((ymax-ymin)/2+FlatY);
            if ~isempty(YData)
                set(double(View.Curves(ct)),'XData',T-0.5,'YData',YData);
            else
                set(double(View.Curves(ct)),'XData',[],'YData',[]);
            end
        end
    end
end