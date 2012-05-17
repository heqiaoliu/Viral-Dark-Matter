function draw(this,Data,NormalRefresh)
%DRAW  Draws Bode response curves.
%
%  DRAW(VIEW,DATA) maps the response data in DATA to the curves in VIEW.

%  Author(s):  
%  Copyright 1986-2005 The MathWorks, Inc.
%  $Revision: 1.1.6.3 $ $Date: 2005/06/27 23:06:16 $

AxGrid = this.AxesGrid;

% Input and output sizes
[Ny, Nu] = size(this.Curves);

% Draw points
for row=1:Ny
    for col=1:Nu
       % REVISIT: remove conversion to double (UDD bug where XOR mode ignored)
       set(double(this.Curves(row,col)), 'XData', Data.XData(:,col), ...
           'YData', Data.YData(:,row),'Marker','x','Linestyle','None');        
    end
end

%% Draw selected points
if ~isempty(this.SelectedRectangles)
    for row=1:Ny
        Irow = (this.SelectedRectangles(:,1)==row);
        for col=1:Nu
            Icol = (this.SelectedRectangles(:,2)==col);
            xdata = Data.XData(:,col);
            ydata = Data.YData(:,row);
            theseRectangles = this.SelectedRectangles(Irow&Icol,:);
            I = false(size(xdata));
            for k=1:size(theseRectangles,1)
                I = I | (xdata>=theseRectangles(k,3) & ...
                              xdata<=theseRectangles(k,4) & ...
                              ydata>=theseRectangles(k,5) & ...
                              ydata<=theseRectangles(k,6));
            end
            set(double(this.SelectionCurves(row,col)), 'XData',xdata(I), ...
                       'YData',ydata(I),'Marker','o','Linestyle','None'); 
        end
    end
else 
   for ct = 1:Ny*Nu 
       set(this.SelectionCurves(ct),'ydata',[],'xdata',[])
   end
end