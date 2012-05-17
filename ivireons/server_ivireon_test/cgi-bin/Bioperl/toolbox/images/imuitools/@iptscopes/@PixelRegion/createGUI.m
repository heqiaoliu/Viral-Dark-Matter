function plugInGUI = CreateGUI(this)   %#ok hSrc not used
%CreateGUI Build and cache UI plug-in for PixelRegion plug-in.
%   This adds the button and menu to the scope.
%   No install/render needs to be done here.

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2009/11/16 22:24:55 $

hSrc = this.Application.DataSource;

if isempty(hSrc) || ~isDataLoaded(hSrc)
    enab = 'off';
else
    enab = 'on';
end

mPixel = uimgr.uimenu('PixelRegion', 1, 'Pixel &Region');
mPixel.Enable = enab;
mPixel.WidgetProperties = { ...
    'busyaction', 'cancel', ...
    'callback', @(hco, ev) launch(this)};

bPixel = uimgr.uipushtool('PixelRegion', 1);
bPixel.IconAppData = 'pixel_region';
bPixel.Enable = enab;
bPixel.WidgetProperties = { ...
    'busyaction', 'cancel', ...
    'tooltip', 'Pixel region', ...
    'click',   @(hco, ev) launch(this)};

% Create plug-in installer
plan = {mPixel, 'Base/Menus/Tools/VideoTools'; ...
        bPixel, 'Base/Toolbars/Main/Tools/Standard'};
plugInGUI = uimgr.uiinstaller(plan);

% [EOF]
