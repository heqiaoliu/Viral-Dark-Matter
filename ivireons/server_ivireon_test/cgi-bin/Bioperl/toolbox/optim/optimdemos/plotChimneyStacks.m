function plotChimneyStacks(h, titleStr)
%PLOTCHIMNEYSTACKS Plot chimney stacks for air pollution example
%
%   PLOTCHIMNEYSTACKS(H) plots the chimney stacks for the air pollution
%   example at the specified heights. 
%
%   PLOTCHIMNEYSTACKS(H, TITLESTR) additionally sets the title of the plot.
%
%   See also PLOTSULFURDIOXIDE

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/12/01 07:21:08 $

% Create a figure and axes
hFig = figure('Color', 'w');
regDim = 4000;
hAx = axes('Parent', hFig, 'xGrid', 'on', 'yGrid', 'off', 'zGrid', 'off');

% Plot the ground
xx = [-regDim regDim];
[XX,YY] = meshgrid(xx);
ground = zeros(size(XX));
surf(hAx, XX, YY, ground, ...
    'facecolor', 'g', 'facealpha', 0.6, 'edgecolor','none');
view(hAx, [-20 30]);
set(hAx, 'XLim', [-regDim, regDim], 'YLim', [-regDim, regDim], ...
    'ZLim', [0 1.1*max(h)]);

% Labels and title
xlabel('x (m)');
ylabel('y (m)');
zlabel('Stack Height (m)');
if nargin > 1
    title(titleStr);
else
    title('Chimney stack height');
end

% Chimney locations
xpos = [-3000,-2600,-1100,1000,1000,2700,3000,-2000,0,1500];
ypos = [-2500,-300,-1700,-2500,2200,1000,-1600,2500,0,-1600];

% Number of chimneys
nChimneys = length(xpos);

% Chimney colors
brown = [139 69 19];
brown = brown/255;

% Plot the chimneys
rad = 140;
nPts = 51;
[x,y,z] = cylinder(rad, nPts);
tol = 0.02*rad;
for i = 1:nChimneys
    
    % Cylinder coordinates
    xCyl = x+xpos(i);
    yCyl = y+ypos(i);
    zCyl = h(i)*z;
    
    % Draw the cylinder
    surface(xCyl, yCyl, zCyl, ...
        'facecolor', brown,...
        'linestyle', 'none', ...
        'Parent', hAx);
    
    % Add edges of the cylinder
    hL1 = line([xpos(i)+rad+tol; xpos(i)+rad+tol], [ypos(i); ypos(i)], zCyl, ...
        'linewidth', 2, ...
        'color', 'k');
    hL2 = line([xpos(i)-rad-tol; xpos(i)-rad-tol], [ypos(i); ypos(i)], zCyl, ...
        'linewidth', 2, ...
        'color', 'k');
    
    % Add line around the top of the cylinder
    hL3 = line(xCyl(2, :), yCyl(2, :), zCyl(2, :), ...
        'linewidth', 1, ...
        'color', 'k');
    
    % Add line around the bottom of the cylinder
    idxSt = (nPts+1)/2 + 1;
    hL4 = line(xCyl(1, idxSt:end), yCyl(1, idxSt:end), zCyl(1, idxSt:end), ...
        'linewidth', 1, ...
        'color', 'k');

    % Bring lines to the top of the graphical stack and send ground to
    % bottom
    uistack([hL1; hL2; hL3; hL4], 'top');
    
end