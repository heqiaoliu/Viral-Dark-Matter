function conformalShowInput(ax, A, uData, vData)
% conformalShowInput Superpose the input image on the 'w' plane.
%
% Supports conformal transformation demo, ipexconformal.m
% ("Exploring a Conformal Mapping").

% Copyright 2005-2009 The MathWorks, Inc. 
% $Revision: 1.1.6.1 $  $Date: 2009/11/09 16:24:52 $

line('Parent',ax,'XData',[0 0],'YData',get(ax,'YLim'),'Color','k','LineWidth',1);
line('Parent',ax,'XData',get(ax,'XLim'),'YData',[0 0],'Color','k','LineWidth',1);

h = image('Parent',ax,'CData',A,'XData',uData,'YData',vData);

% Plot the ellipse and the interval [-1 1] on the real axis.
theta = 2 * pi * (0 : 90) / 90;
line('Parent',ax,'XData',(5/4) * cos(theta),'YData',(3/4) * sin(theta),'Color','k','LineWidth',1);
line('Parent',ax,'XData',    1 * cos(theta),'YData',    0 * sin(theta),'Color','r','LineWidth',1);

% Use partial transparence to de-emphasize the image.
alphaData = 0.6 * ones(size(A,1),size(A,2));
set(h,'AlphaData',alphaData);
