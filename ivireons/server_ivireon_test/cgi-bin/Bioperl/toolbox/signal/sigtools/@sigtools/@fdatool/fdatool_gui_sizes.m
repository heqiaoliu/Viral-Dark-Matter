function sz = fdatool_gui_sizes(this)
%FDATOOL_GUI_SIZES Sizes and spacing for FDATool

%   Author(s): J. Schickler
%   Copyright 1988-2008 The MathWorks, Inc.
%   $Revision: 1.7.4.7 $  $Date: 2009/07/27 20:32:21 $

sz = gui_sizes(this);

sz.fig_w = 770;
sz.fig_h = 549;

if isrendered(this) && ishghandle(this.FigureHandle),
    hFig = get(this, 'FigureHandle');
    origUnits = get(hFig, 'Units'); set(hFig, 'Units', 'Pixels');
    sz.figpos = get(hFig, 'Position'); set(hFig, 'Units', origUnits);
else
    sz.figpos = figpos(sz);
end

sz.defaultpanel = [34 25 732 248] * sz.pixf;

sz.panel = sz.defaultpanel;
if isrendered(this) && ishghandle(this.Figurehandle),
    
    
    h = get(this, 'Handles');
    if isfield(h, 'recessedFr'),
        
        % The recessedFr vector stores the handle to the axes and the two
        % lines that give it the recessed look.  We are only interested in
        % the axes, not the lines
        hrf = h.recessedFr(1);
        origUnits = get(hrf, 'Units'); set(hrf, 'Units', 'Pixels');
        sz.panel = get(hrf, 'Position'); set(hrf, 'Units', origUnits);
    end
end

sz.fh1 = 252*sz.pixf;    % Analysis Area and Current Filter Info (w/o Tab)
sz.fh2 = 81*sz.pixf;     % Window Specs
sz.fh3 = 109*sz.pixf;    % Filter Order
sz.fh4 = 35*sz.pixf;     % Quantization frame height.
sz.fh5 = 76*sz.pixf;     % Design Method
sz.fh6 = 176*sz.pixf;    % Current Filter Info w/ Tab
sz.fh7 = 205*sz.pixf;    % Specifications 
sz.fh8 = 20*sz.pixf;     % Action Frame
sz.fh9 = 248*sz.pixf;    % Recessed Frame
sz.fh10 = 61 *sz.pixf;   % Quantization Switch

% Frame Widths
sz.fw1 = 178*sz.pixf;    % Current Filter Info, Design Method, Filter Type, etc.
                    
sz.fw2 = 548*sz.pixf;    % Analysis Frame & Quantizer Props
sz.fw3 = 356*sz.pixf;    % Width of Freq/Mag.
sz.fw4 = 715*sz.pixf;    % Width of the Action Frame
sz.fw5 = 713*sz.pixf;    % Import Parameters
sz.fw6 = 732*sz.pixf;    % Recessed Frame

% Frame Ys
sz.fy1 = 282*sz.pixf;    % Analysis Areas, Quantization Switch, and CFI (w/o tab)
sz.fy2 = 358*sz.pixf;    % Current Filter Information w/tab
sz.fy3 = 55*sz.pixf;     % All Specifications except Filter Order
sz.fy4 = 151*sz.pixf;    % Filter Order
sz.fy5 = 32*sz.pixf;     % Action Frame
sz.fy6 = 28*sz.pixf;     % Recessed Frame

% Frame Xs
sz.fx1 = 34*sz.pixf;      % CFI, QSwitch, Filter Type and Design Method
sz.fx2 = 217*sz.pixf;    % Analysis Area Filter Order and Window Specifications
sz.fx3 = 400*sz.pixf;    % Frequency Specifications & FREQMAG
sz.fx4 = 583*sz.pixf;    % Magnitude Specifications
sz.fx5 = 40*sz.pixf;     % Action Frame
sz.fx6 = 34*sz.pixf;     % Recessed Frame


% -----------------------------------------------------------------------
function figurePos = figpos(sz)

% Figure out screen resolution.
oldRootUnits = get(0,'Units');
set(0, 'Units', 'pixels');

% Calculate figure position according to resolution.
figurePos = get(0,'DefaultFigurePosition');
figurePos(3:4) = [sz.fig_w sz.fig_h]*sz.pixf;

% Make sure the title bar of the window isn't off the screen
rootScreenSize = get(0,'ScreenSize');

% (position is [x(from left) y(bottom edge from bottom) width height]
% check left edge and right edge
if ((figurePos(1) < 1) ...
      || (figurePos(1)+figurePos(3) > rootScreenSize(3)))
   figurePos(1) = 30;
end

% Make sure top of figure is not off the screen.
if figurePos(2) < 1 ...
      || figurePos(2)+figurePos(4) > rootScreenSize(4)-40*sz.pixf
   figurePos(2) = figurePos(2)-((figurePos(2)+figurePos(4)+100)-rootScreenSize(4))-40*sz.pixf;
end

set(0, 'Units', oldRootUnits);

% [EOF]
