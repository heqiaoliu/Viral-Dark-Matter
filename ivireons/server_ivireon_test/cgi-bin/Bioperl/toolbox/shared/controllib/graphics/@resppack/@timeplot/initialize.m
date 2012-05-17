function initialize(this, ax, gridsize)
%  INITIALIZE  Initializes the @timeplot objects.
%
%  INITIALIZE(H,AX,[M N]) creates an @axesgrid object of size MxN
%  to display response plots.

%  Author(s): Bora Eryilmaz
%  Copyright 1986-2009 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:25:22 $

% Axes geometry parameters
geometry = struct('HeightRatio',[],...
   'HorizontalGap', 16, 'VerticalGap', 16, ...
   'LeftMargin', 12, 'TopMargin', 20);

% Create @axesgrid object
this.AxesGrid = ctrluis.axesgrid(gridsize, ax, ...
   'Visible',     'off', ...
   'Geometry',    geometry, ...
   'LimitFcn',  {@updatelims this}, ...
   'Title',    'Time Response', ...
   'XLabel',  'Time',...
   'YLabel',  'Amplitude',...
   'XScale',  'linear',...
   'YScale',  'linear',...
   'XUnit',  'sec');
             
% Generic initialization
init_graphics(this)

% Add listeners
addlisteners(this)