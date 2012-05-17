function setfigposition(h, figPos)
%SETFIGPOSITION  Set figure window position for multipath figure object.

%   Copyright 1996-2007 The MathWorks, Inc.
%   $Revision: 1.1.6.6 $  $Date: 2007/06/08 15:52:12 $

% Get figure window handle.
fig = h.FigureHandle;

% Get or set figure position.
if nargin==1
    figPos = get(fig, 'position');  % Assumes fig units pixels.
else
    set(fig, 'position', figPos);
end

% Get figure width and height.
figWidth = figPos(3);
figHeight = figPos(4);
figCenter = figWidth/2;

% Window cannot be sized smaller than 500x400.
minWidth = 500;
minHeight = 400;
widthOK = (figWidth>=minWidth);
heightOK = (figHeight>=minHeight);
if (~widthOK)
    figWidth = minWidth;
end
if (~heightOK)
    figHeight = minHeight;
end
if (~widthOK || ~heightOK)
    oldPos = h.SavedPosition;
    d = (figPos - h.SavedPosition);
    if (d(1)>0)
        figPos(1) = oldPos(1) + oldPos(3) - figWidth;
    end
    if (d(2)>0)
        figPos(2) = oldPos(2) + oldPos(4) - figHeight;
    end
    figPos([3 4]) = [figWidth figHeight];
    set(fig, 'position', figPos);
end
h.SavedPosition = figPos;


% Position uicontrols.

ui = h.UIHandles;

% Constants used for positioning uicontrols
tH = 15;  % Text height
tH2 = 18;  % Control height
mH = 18;  % Menu height
axesPanelMargin = 10;

% Visualization menu
setuiposition(ui.VisMenuText, [10 figHeight-tH-10 100  tH]);
if isunix
    % To ensure that the popup menu items fit in the box.
    setuiposition(ui.VisMenu,     [115 figHeight-mH-5  180 mH]);
else
    setuiposition(ui.VisMenu,     [115 figHeight-mH-5  150 mH]);
end    

% Animation menu
setuiposition(ui.AnimationMenuText, ...
    [figWidth-100-100-20 figHeight-tH-10 100 tH]);
setuiposition(ui.AnimationMenu, ...
    [figWidth-100-20+5  figHeight-mH-5  100 mH]);

% Axes panel
apWidth = figWidth-2*axesPanelMargin;
apHeight = figHeight-45;
apHCenter = apWidth/2;
setuiposition(ui.AxesPanel, ...
    [axesPanelMargin axesPanelMargin apWidth apHeight]);

% Control panel
cpWidth = 450;
cpHeight = 50;
setuiposition(ui.ControlPanel, ...
    [apHCenter-cpWidth/2 apHeight-cpHeight-1 cpWidth cpHeight]);

% UI controls within control panel

x1 = 5;  % Left margin for frame counter
x2 = 165; % Left margin for slider control etc.
y1 = cpHeight - 20;  % Top margin within control panel.

% Frame count
setuiposition(ui.FrameCountText, [x1    y1-10 100 tH]);
setuiposition(ui.FrameCount,     [x1+105 y1-10 100 tH]);

% Slider and sample index
setuiposition(ui.SliderText, [x2+20               y1-10    80  tH]);
setuiposition(ui.Slider,     [x2+100+5            y1-10    110 tH2]);
setuiposition(ui.SampleIdx,  [x2+100+5+(110-100)/2  y1-10-tH 100  tH]);

% Path number edit box
setuiposition(ui.PathNumberText, [x2+20               y1-10    80+5  tH]);
setuiposition(ui.PathNumber,     [x2+100+5+5            y1-10    30 tH2]);

% Pause button
setuiposition(ui.PauseButton, [x2+100+5+110+5 y1-10 60 tH2]);

% Set axes positions.
h.setaxespositions;

drawnow expose

%--------------------------------------------------------------------------
function setuiposition(uiName, pos)
set(uiName, 'position', pos);
