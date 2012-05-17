function h = sinestreamplot(varargin)
%  SINESTREAMPLOT  Constructor for @sinestreamplot class
%
%  H = TIMEPLOT(AX,[M N]) creates a @fftplot object with an M-by-N grid of
%  axes (@axesgrid object) in the area occupied by the axes with handle AX.
%

% Author(s): Erman Korkut 12-Mar-2009
% Revised:
% Copyright 1986-2009 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:25:01 $

% Create class instance
h = resppack.sinestreamplot;
ax = varargin{1};
gridsize = varargin{2};

% Generic property init
init_prop(h, ax, gridsize);

% User-specified initial values (before listeners are installed...)
h.set(varargin{3:end});

% Initialize the handle graphics objects used in @timeplot class.
h.initialize(ax, gridsize);




