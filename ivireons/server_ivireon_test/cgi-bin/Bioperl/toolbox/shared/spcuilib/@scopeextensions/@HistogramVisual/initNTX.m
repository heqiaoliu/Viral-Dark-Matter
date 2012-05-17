function initNTX(this, hVisParent)
%INITNTX  Initializes the NTXUI object. This creates the new histogram visual.

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2010/04/21 21:49:14 $

origUnits = get(0, 'units');
set(0, 'units', 'pix');
monitorPositions = get(0,'MonitorPositions');
set(0,'units',origUnits);
% get the size of the primary display
screenSize = monitorPositions(1,:);
if size(monitorPositions,1) > 1
  for i = 1:size(monitorPositions,1)
    % The [x,y] co-ordinates of the primary monitor are always less that
    % the [x,y] of other monitors. Get the true primary monitor size.
    if monitorPositions(i,1) < screenSize(1) && ...
            monitorPositions(i,2) < screenSize(2)
      screenSize = monitorPositions(i,:);
    end
  end
end
origUnits = get(this.Application.Parent,'units');
set(this.Application.Parent,'units','pix');
parentPos = get(this.Application.Parent,'outerposition');
pixelFactor = getPixelFactor;


% NTX needs the figure size to be at least 300 (bodyPanel min width) + 190
% (Dialog Panel width) + 18 (scroll-bar width) + 13 (gutters) pixels wide to
% display its contents properly. Resize the figure window if it is too
% narrow to hold all the controls and sub-panels. Resize the window to be at
% least 521 pixels wide.

if parentPos(3) < (521 * pixelFactor)
    % Since we are looking at the outer position of the framework, add a
    % few more pixels to make sure we get the required inner position.
    innerPos = getpixelposition(this.Application.Parent);
    parentPos(3) = (521 * pixelFactor) + (parentPos(3) - innerPos(3));
    % Check of the window is out of bounds of the screen size. Shift by
    % the difference between the sizes such that the entire figure is
    % visible.
    bottomRightPos = parentPos(1)+parentPos(3);
    if bottomRightPos > screenSize(3)
        parentPos(1) = parentPos(1)-(bottomRightPos-screenSize(3));
    end
    % Set the outerposition so that the entire figure is rendered within
    % the specified position.
    set(this.Application.Parent,'outerposition', parentPos);
end
if parentPos(4) < screenSize(4)/2
    parentPos(4) = screenSize(4)/2;
    % Check of the window is out of bounds of the screen size. Shift by
    % the difference between the sizes such that the entire figure is
    % visible.
    topRightPos = parentPos(2)+parentPos(4);
    if topRightPos > screenSize(4)
        parentPos(2) = parentPos(2)-(topRightPos-screenSize(4));
    end
    % Set the outerposition so that the entire figure (including toolbars,
    % menus, titlebar) is rendered within the specified position.
    set(this.Application.Parent,'outerposition', parentPos);
end
set(this.Application.Parent,'units',origUnits);
this.NTExplorerObj = embedded.ntx(hVisParent,[]);

%--------------------------------------------------------------------------
function pixelFactor = getPixelFactor
% Return height of one char in pixels (pixels per char)

pixels_per_inch = get(0,'screenPixelsPerInch');
% If on unix platforms, the default ScreenPixelsPerInch is 90 (maci64) and
% 72 (glnxa64). On windows the default is 96. Get the pixel factor by which
% the current DPI setting has to be compensated with. For large fonts
% setting the DPI can be 116 pixels per inch. The figure size needs to be
% compensated for this.
if ismac
    default_pixels_per_inch = 90;
elseif isunix 
    default_pixels_per_inch = 72;
else
    default_pixels_per_inch = 96;
end
pixelFactor = pixels_per_inch/default_pixels_per_inch;
 



% [EOF]
