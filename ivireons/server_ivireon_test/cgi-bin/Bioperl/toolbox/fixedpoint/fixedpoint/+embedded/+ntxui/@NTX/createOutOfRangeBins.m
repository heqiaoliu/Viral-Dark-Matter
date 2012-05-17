function createOutOfRangeBins(ntx)
% Create arrows overlaying the x-axis label region
% Retains vector of two handles in ntx.hXRangeIndicators,
%   hp(1) has the XOver arrow, hp(2) has the xUnder arrow
%
% Needs a resize fcn to reposition axes properly

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $     $Date: 2010/03/31 18:21:03 $

dp = ntx.dp; % Get handle to DialogPanel

hax      = ntx.hHistAxis;
htXLabel = ntx.htXLabel;
rgbUnder = ntx.ColorUnderflowBar;
rgbOver  = ntx.ColorOverflowBar;

% Get x-extent from main axes position
set(hax,'units','pixels');
haxPosPix = get(hax,'pos');
x1_ax = haxPosPix(1); % 1st x-pixel in main axis
dx_ax = haxPosPix(3);
x2_ax = x1_ax+dx_ax-1; % last x-pixel in main axis

% Get vert extent to work with
set(htXLabel,'units','pix');
ext = get(htXLabel,'extent');
label_y_data = ext(2);
label_dy_data = ext(4); % label is one char in height
y1 = label_y_data + label_dy_data;  % top of xlabel

% Create new axes for indicators
Nx=40; Ny=30; % Nx-by-Ny pixel size
hOverAx = axes('parent',dp.hBodyPanel, ...
    'color', 'w',...
    'units','pix', ...
    'xdir','rev', ...
    'vis','off', ...
    'pos',[x1_ax 2 Nx Ny]);
hUnderAx = axes('parent',dp.hBodyPanel, ...
    'color', 'w',...
    'units','pix', ...
    'vis','off', ...
    'pos',[x2_ax-Nx+1 2 Nx Ny]);

% Create left (over) arrow
% Bug fix: duplicate patches to make colors appear properly
xd = zeros(8,2);
xd(:,1) = [0 0 1.5 1.5 3 1.5 1.5 0]'/3*Nx+x1_ax;
xd(:,2) = xd(:,1);
yd = zeros(8,2);
yd(:,1) = [2 1 1 0 1.5 3 2 2]'/3*Ny+y1;
yd(:,2) = yd(:,1);
zd = zeros(size(xd));
cd = zeros(1,2,3);
cd(1,1,:) = rgbOver;
cd(1,2,:) = rgbOver;
hp(2) = patch('parent',hOverAx, ...
    'vis','off', ...
    'facecolor','flat', ...
    'edgecolor','k', ...
    'cdata',cd, ...
    'xdata',xd, ...
    'ydata',yd, ...
    'zdata',zd);

% Create right (under) arrow
cd(1,1,:) = rgbUnder;
cd(1,2,:) = rgbUnder;
hp(1) = patch('parent',hUnderAx, ...
    'vis','off', ...
    'facecolor','flat', ...
    'edgecolor','k', ...
    'cdata',cd, ...
    'xdata',xd, ...
    'ydata',yd, ...
    'zdata',zd);

% Cache the vector of two handles to over- and under-range arrow axes
ntx.hXRangeIndicators = hp;
