function plotSulfurDioxideUncertain(h, rTheta, rU, rX, rY, titleStr)
%PLOTSULFURDIOXIDEUNCERTAIN Plot sulfur dioxide for air pollution example
%with uncertainty.
%
%   PLOTSULFURDIOXIDEUNCERTAIN(H, RTHETA, RU, RX, RY) plots the sulfur
%   dioxide concentration for the air pollution example. The ground region
%   is specified by the ranges RX and RY, the chimney stack heights by H,
%   the wind direction range, rTheta, and mean wind speed range, rU. In
%   addition, the sulfur dioxide concentration limit is shown.
%
%   PLOTSULFURDIOXIDEUNCERTAIN(H, RTHETA, RU, RX, RY, TITLESTR)
%   additionally sets the title of the plot.
%
%   See also PLOTCHIMNEYSTACKS

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/01/08 18:46:23 $

% Calculate the sulfur dioxide concentration over a grid
xx = linspace(rX(1), rX(2), 20);
yy = linspace(rY(1), rY(2), 20);
[xx, yy] = meshgrid(xx, yy);
sd = zeros(size(xx));
[theta,U] = meshgrid(rTheta,rU);
for i = 1:size(xx, 1)
    for j = 1:size(yy, 1)
        thissd = concSulfurDioxide(xx(i, j), yy(i, j), h, theta, U);
        sd(i,j) = max(thissd(:));        
    end
end

% Plot a surface of it
hFig = figure('Color', 'w');
hAx = axes('Parent', hFig);
surf(hAx, xx, yy, sd, 'facecolor', [0.5 0.47 0.5]);
view(hAx, [-20,30]);
colormap(hot);

% Labels and title
xlabel('x (m)');
ylabel('y (m)');
zlabel('Sulfur Dioxide (g/m^{3})');
if nargin > 5 && ~isempty(titleStr)
    title(titleStr);
else
    title('Sulfur dioxide concentration');
end

% Add on the maximum allowed sulfur dioxide concentration
[xx, yy] = meshgrid(rX, rY);
surface(xx, yy, 1.25e-4*ones(size(xx)), 'facecolor', 'r', 'facealpha', 0.2);

