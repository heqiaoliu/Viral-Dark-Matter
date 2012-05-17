function conformalShowOutput(ax, B, xData, yData)
% conformalShowOutput Superpose the output image on the 'z' plane.
%
% Supports conformal transformation demo, ipexconformal.m
% ("Exploring a Conformal Mapping").

% Copyright 2005-2009 The MathWorks, Inc. 
% $Revision: 1.1.6.1 $  $Date: 2009/11/09 16:24:54 $

line('Parent',ax,'XData',[0 0],'YData',get(ax,'YLim'),'Color','k','LineWidth',1);
line('Parent',ax,'XData',get(ax,'XLim'),'YData',[0 0],'Color','k','LineWidth',1);

h = image('Parent',ax,'CData',B,'XData',xData,'YData',yData);

% Plot circles with radii of 1, 2, and 1/2.
theta = 2 * pi * (0 : 90) / 90;
line('Parent',ax,'XData', 1*cos(theta),'YData', 1*sin(theta),'Color','r','LineWidth',1);
line('Parent',ax,'XData', 2*cos(theta),'YData', 2*sin(theta),'Color','k','LineWidth',1);
line('Parent',ax,'XData', cos(theta)/2,'YData', sin(theta)/2,'Color','k','LineWidth',1);

% Use partial transparence to de-emphasize the image
alphaData = 0.6 * ones(size(B,1),size(B,2));
set(h,'AlphaData',alphaData);
