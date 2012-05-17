function initialize(this, ax, gridsize)
%  INITIALIZE  Initializes the @fftlot objects.
%
%  INITIALIZE(H,AX,[M N]) creates an @axesgrid object of size MxN
%  to display fft response plots.

% Author(s): Erman Korkut 12-Mar-2009
% Revised:
% Copyright 1986-2009 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:20:38 $

% Axes geometry parameters
geometry = struct('HeightRatio',[],...
   'HorizontalGap', 16, 'VerticalGap', 16, ...
   'LeftMargin', 12, 'TopMargin', 20);

% Create @axesgrid object
this.AxesGrid = ctrluis.axesgrid(gridsize, ax, ...
   'Visible',     'off', ...
   'Geometry',    geometry, ...
   'LimitFcn',  {@updatelims this}, ...
   'Title',    ctrlMsgUtils.message('Controllib:plots:strFFT'), ...
   'XLabel',  ctrlMsgUtils.message('Controllib:plots:strFrequency'),...
   'YLabel',  ctrlMsgUtils.message('Controllib:plots:strAmplitude'),...
   'XUnit',  'rad/s');
             
% Generic initialization
init_graphics(this)

% Add listeners
addlisteners(this)