function adjustview(View,Data,Event,NormalRefresh)
%ADJUSTVIEW  Adjusts view prior to and after picking the axes limits. 
%
%  ADJUSTVIEW(VIEW,DATA,'postlim') adjusts the HG object extent once the 
%  axes limits have been finalized (invoked in response, e.g., to a 
%  'LimitChanged' event).

%  Author(s):  
%  Copyright 1986-2005 The MathWorks, Inc.
%  $Revision: 1.1.6.4 $ $Date: 2005/09/29 16:34:24 $

%% Input and output sizes
AxGrid = View.AxesGrid;
[Ny, Nu] = size(View.Curves);

if strcmp(Event,'postlim') && strcmp(View.AxesGrid.YNormalization,'on')
    % Draw normalized data once X limits are finalized
    % Draw points
    for row=1:Ny
        for col=1:Nu
            ct=(row-1)*Nu+col;
            Xlims = get(ancestor(View.Curves(ct),'Axes'),'Xlim');
            set(ancestor(View.Curves(ct).Parent,'Axes'),'YLimMode','auto');
            Ylims = get(ancestor(View.Curves(ct),'Axes'),'Ylim');

            set(ancestor(View.Curves(ct).Parent,'Axes'),'XLimMode','auto');
            [ymin,ymax,FlatY] = ydataspan(Data.XData(:,col),Data.YData(:,row),Xlims);            
            YData = (Data.YData(:,row) - (ymin+ymax)/2)/((ymax-ymin)/2+FlatY);
            [xmin,xmax,FlatX] = ydataspan(Data.YData(:,row),Data.XData(:,col),Ylims);            
            XData = (Data.XData(:,col) - (xmin+xmax)/2)/((xmax-xmin)/2+FlatX);

            if ~isempty(XData) && ~isempty(YData)
                set(double(View.Curves(ct)),'XData',XData,'YData',YData)
            else
                set(double(View.Curves(ct)),'XData',[],'YData',[])
            end
        end
    end 
end

