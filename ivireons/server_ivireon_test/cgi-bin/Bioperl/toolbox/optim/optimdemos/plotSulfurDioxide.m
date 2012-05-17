function plotSulfurDioxide(h, theta, U, titleStr, xPt)
%PLOTSULFURDIOXIDE Plot sulfur dioxide for air pollution example
%
%   PLOTSULFURDIOXIDE(H, THETA, U) plots the sulfur dioxide concentration
%   for the air pollution example over the specified 20km-by-20km region.
%   The inputs specify the chimney stack heights, H, the wind direction,
%   THETA and wind speed, U.
%
%   PLOTSULFURDIOXIDE(H, THETA, U, TITLESTR) additionally sets the title of
%   the plot.
%
%   PLOTSULFURDIOXIDE(H, THETA, U, TITLESTR, XPT) additionally highlights a
%   point on the sulfur dioxide surface with the specified X and Y
%   coordinates.
%
%   See also PLOTCHIMNEYSTACKS

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/01/08 18:46:22 $

% Calculate the sulfur dioxide concentration over a grid
xx = -20000:1000:20000;
[xx, yy] = meshgrid(xx);
sd = concSulfurDioxide(xx, yy, h, theta, U);

% Plot a surface of it
hFig = figure('Color', 'w');
hAx = axes('Parent', hFig);
surf(hAx, xx, yy, sd, 'facecolor', [0.5 0.47 0.5]);
view(hAx, [-20,30]);

% Labels and title
xlabel('x (m)');
ylabel('y (m)');
zlabel('Sulfur Dioxide (g/m^{3})');
if nargin > 3 && ~isempty(titleStr)
    title(titleStr);
else
    title('Sulfur dioxide concentration');
end

% Add on the maximum allowed sulfur dioxide concentration
[xx, yy] = meshgrid([-20000 20000], [-20000 20000]);
surface(xx, yy, 1.25e-4*ones(size(xx)), 'facecolor', 'r', 'facealpha', 0.2);

% Add any point that have been specified
if nargin > 4
    line(xPt(1), xPt(2), concSulfurDioxide(xPt(1), xPt(2), h, theta, U), ...
        'MarkerSize', 24, 'Marker', '.');
end
