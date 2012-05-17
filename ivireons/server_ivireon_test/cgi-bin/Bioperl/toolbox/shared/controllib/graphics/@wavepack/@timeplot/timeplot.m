function h = timeplot(varargin)
%TIMEPLOT  Constructor for @timeplot class (time series plot).
%
%  H = TIMEPLOT(AX,N) creates a @timeplot object with N axes (channels)
%  in the area occupied by the axes with handle AX.
%
%  H = TIMEPLOT(N) uses GCA as default axes.
%
%  H = TIMEPLOT(N,'Property1','Value1',...) initializes the plot with the
%  specified attributes.

%  Author(s): Bora Eryilmaz
%  Copyright 1986-2008 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:27:30 $

% Create class instance
h = wavepack.timeplot;

% Parse input list
if ishghandle(varargin{1},'axes')
   ax = varargin{1};
   varargin = varargin(2:end); 
else
   ax = gca;
end
gridsize = [varargin{1} 1];

% Check for hold mode
[h,HeldRespFlag] = check_hold(h, ax, gridsize);
if HeldRespFlag
   % Adding to an existing response (h overwritten by that response's handle)
   % RE: Skip property settings as I/O-related data may be incorrectly sized (g118113)
   return
end

% Generic property init
init_prop(h, ax, gridsize);

% User-specified initial values (before listeners are installed...)
h.set(varargin{2:end});

% Initialize the handle graphics objects used in @timeplot class.
h.initialize(ax, gridsize);




