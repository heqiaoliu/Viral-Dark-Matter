function h = bodeplot(varargin)
%BODEPLOT  Constructor for @timeplot class
%
%  H = BODEPLOT(AX,[M N]) creates a @bodeplot object with an M-by-N grid of
%  axes (@axesgrid object) in the area occupied by the axes with handle AX.
%
%  H = BODEPLOT([M N]) uses GCA as default axes.
%
%  H = BODEPLOT([M N],'Property1','Value1',...) initializes the plot with the
%  specified attributes.

%  Author(s): Bora Eryilmaz, Pascal Gahinet
%  Copyright 1986-2008 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:20:04 $

% Create class instance
h = resppack.bodeplot;

% Parse input list
if ishghandle(varargin{1},'axes')
   ax = varargin{1};
   varargin = varargin(2:end); 
else
   ax = gca;
end
gridsize = varargin{1};

% Check for hold mode
[h,HeldRespFlag] = check_hold(h, ax, gridsize);
if HeldRespFlag
  % Adding to an existing response (h overwritten by that response's handle)
  % RE: Skip property settings as I/O-related data may be incorrectly sized
  % (g118113)
  return
end

% Generic property init
init_prop(h, ax, gridsize);

% User-specified initial values (before listeners are installed...)
h.set(varargin{2:end});

% Initialize the handle graphics objects used in @bodeplot class.
h.initialize(ax, gridsize);
