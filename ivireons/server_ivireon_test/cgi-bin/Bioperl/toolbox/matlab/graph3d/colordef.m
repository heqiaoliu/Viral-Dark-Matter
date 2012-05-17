function hh = colordef(arg1,arg2)
%COLORDEF Set color defaults.
%   COLORDEF WHITE or COLORDEF BLACK changes the color defaults on the
%   root so that subsequent figures produce plots with a white or
%   black axes background color.  The figure background color is
%   changed to be a shade of gray and many other defaults are changed
%   so that there will be adequate contrast for most plots.
%
%   COLORDEF NONE will set the defaults to their MATLAB 4 values.
%   The most noticeable difference is that the axis background is set
%   to 'none' so that the axis background and figure background colors
%   are the same.  The figure background color is set to black.
%
%   COLORDEF(FIG,OPTION) changes the defaults of the figure FIG
%   based on OPTION.  OPTION can be 'white','black', or 'none'.
%   The figure must be cleared first (via CLF) before using this
%   variant of COLORDEF.
%
%   H = COLORDEF('new',OPTION) returns a handle to a new figure
%   created with the specified default OPTION.  This form of the
%   command is handy in GUI's where you may want to control the
%   default environment.  The figure is created with 'visible','off'
%   to prevent flashing.
%
%   See also WHITEBG.

%   Copyright 1984-2009 The MathWorks, Inc.
%   $Revision: 1.7.4.5 $  $Date: 2009/03/05 18:50:45 $


error(nargchk(1,2,nargin,'struct'));

% If only one input, then set properties on the root
if nargin==1,
  fig = 0;
  option = arg1;
elseif nargin==2
    if ischar(arg1)
        % If first input is a string, it must be the string 'new'
        if ~strcmpi(arg1, 'new')
            error('MATLAB:colordef:InvalidOption', ...
                'Invalid option specified for the first input to colordef.');
        else
            % Create a new, invisible figure
            fig = figure('visible', 'off');
        end
    % All non-character inputs must be handles to figures or the root 
    elseif all(ishghandle(arg1))
        if isscalar(arg1) && ~ishghandle(arg1, 'figure') && ~ishghandle(arg1, 'root')
            % If the first input is a scalar handle, it can be the root 
            % object or a figure window
            error('MATLAB:colordef:RootOrFigureHandle', ...
                'colordef(FIG, OPTION) requires a handle to root or a figure window');
        elseif ~isscalar(arg1) && ~all(ishghandle(arg1, 'figure'))
            error('MATLAB:colordef:FigureHandleExpected', ...
                'Vectors of handles passed to colordef must include only figure handles.');
        else
            fig = arg1;
        end
    else
        error('MATLAB:colordef:InvalidHandle', 'Invalid figure handle.');
    end
    option = arg2;
end

if all(ishghandle(fig, 'figure')) && ~isempty(findobj(fig, 'type', 'axes'))
    error('MATLAB:colordef:MustClearFigure', ...
        'The figure must be cleared using CLF to use COLORDEF(FIG, OPTION).');
end



switch option
case 'white'
  wdefault(fig)
case 'black'
  kdefault(fig)
case 'none'
  default4(fig)
otherwise
  error('MATLAB:colordef:UnknownDefaultOption', 'Unknown color default option: %s.',option)
end

if nargout>0, hh = fig; end

%----------------------------------------------------------
function kdefault(fig)
%KDEFAULT Black figure and axes defaults.
%   KDEFAULT sets up certain figure and axes defaults
%   for plots with a black background.
%
%   KDEFAULT(FIG) only affects the figure with handle FIG.

if nargin==0, fig = 0; end

whitebg(fig,[0 0 0])
if isunix 
   fc = [.35 .35 .35]; % On UNIX compensate for no gamma correction.
else
  fc = [.2 .2 .2];
end
if fig==0,
  set(fig,'DefaultFigureColor',fc)
else
  set(fig,'color',fc)
end
set(fig,'DefaultAxesColor',[0 0 0])
set(fig,'DefaultAxesColorOrder', ...
   1-[0 0 1;0 1 0;1 0 0;0 1 1;1 0 1;1 1 0;.25 .25 .25]) % ymcbgrw
if fig == 0
  cmap = 'DefaultFigureColormap';
else
  cmap = 'colormap';
end
set(fig,cmap,jet(64))
set(fig,'DefaultSurfaceEdgeColor',[0 0 0])

%------------------------------------------------------------
function wdefault(fig)
%WDEFAULT White figure and axes defaults.
%   KDEFAULT sets up certain figure and axes defaults
%   for plots with a white background.
%
%   WDEFAULT(FIG) only affects the figure with handle FIG.

if nargin==0, fig = 0; end

whitebg(fig,[1 1 1])
if fig==0,
  set(fig,'DefaultFigureColor',[.8 .8 .8])
else
  set(fig,'color',[.8 .8 .8])
end
set(fig,'DefaultAxesColor',[1 1 1])
set(fig,'DefaultAxesColorOrder', ...
    [0 0 1;0 .5 0;1 0 0;0 .75 .75;.75 0 .75;.75 .75 0;.25 .25 .25]) % bgrymck
if fig == 0
  cmap = 'DefaultFigureColormap';
else
  cmap = 'colormap';
end
set(fig,cmap,jet(64))
set(fig,'DefaultSurfaceEdgeColor',[0 0 0])

%----------------------------------------------------------------
function default4(fig)
%DEFAULT MATLAB version 4.0 figure and axes defaults.
%   DEFAULT4 sets certain figure and axes defaults to match what were
%   the defaults for MATLAB version 4.0.
%
%   DEFAULT4(FIG) only affects the figure with handle FIG.

if nargin==0, fig = 0; end
set(fig,'DefaultAxesColor','none')
whitebg(fig,[0 0 0])
set(fig,'DefaultAxesColorOrder',[1 1 0;1 0 1;0 1 1;1 0 0;0 1 0;0 0 1]) % ymcrgb
if fig == 0
  cmap = 'DefaultFigureColormap';
else
  cmap = 'colormap';
end
set(fig,cmap,hsv(64))
set(fig,'DefaultSurfaceEdgeColor',[0 0 0])
