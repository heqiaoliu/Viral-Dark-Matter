function initialize(this, ax, gridsize)
%  INITIALIZE  Initializes the @timeplot objects.
%
%  INITIALIZE(H,AX,GRIDSIZE) creates an @axesgrid object of size
%  GRIDSIZE to display wave plots.

%  Author(s): Bora Eryilmaz
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:27:28 $

% Axes geometry parameters
geometry = struct('HeightRatio',[],...
   'HorizontalGap', 16, 'VerticalGap', 16, ...
   'LeftMargin', 12, 'TopMargin', 20);

% Create @axesgrid object
this.AxesGrid = ctrluis.axesgrid(gridsize, ax, ...
   'Visible',     'off', ...
   'Geometry',    geometry, ...
   'LimitFcn',  {@updatelims this}, ...
   'Title',    'Time Series', ...
   'XLabel',   'Time',...
   'YLabel',  'Amplitude',...
   'XUnit',  'sec');
             
% Generic initialization
init_graphics(this)

% Add listeners
addlisteners(this)