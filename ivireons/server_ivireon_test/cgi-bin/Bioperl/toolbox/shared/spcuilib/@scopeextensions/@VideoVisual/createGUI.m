function hInstall = createGUI(this)
%CREATEGUI Create the video specific UIMgr components.

%   Author(s): J. Schickler
%   Copyright 2007-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2010/03/31 18:43:14 $

plan = abstractVisual_createGUI(this);

% plan{1}.WidgetProperties = {plan{1}.WidgetProperties, ...
%     'Tooltip', sprintf('Color Format: Height x Width'), ...
%     'Callback', @(hco,ev) show(this.VideoInfo, true)};


mInfo = uimgr.uimenu('VideoInfo',-inf,'Video &Information');
mInfo.WidgetProperties = {...
    'callback', @(hco,ev) show(this.VideoInfo, true)};

mColormap = uimgr.uimenu('Colormap',inf,'&Colormap...');

hSource = this.Application.DataSource;
if isempty(hSource) || isRGB(hSource)
    ena = 'off';
else
    ena = 'on';
end
mColormap.Enable = ena;
mColormap.WidgetProperties = {...
    'callback', @(hco,ev) show(this.ColorMap, true)};

%  Place Video Info first
hVideoInfo = uimgr.uipushtool('VideoInfo',-inf);
hVideoInfo.IconAppData = 'info';
hVideoInfo.WidgetProperties = {...
    'busyaction','cancel', ...
    'tooltip','Video information', ...
    'click', @(hco,ev) show(this.VideoInfo, true)};

hKeyPlayback = uimgr.spckeygroup('Video');
hKeyPlayback.add( ...
    uimgr.spckeybinding('colormap','C',...
    @(h,ev) show(this.ColorMap, true), 'Change colormap'),...
    uimgr.spckeybinding('videoinfo','V',...
    @(h,ev) show(this.VideoInfo, true), 'Display video info'));

mVideoTools = uimgr.uimenugroup('VideoTools', -inf, mInfo, mColormap);

hInstall = uimgr.uiinstaller({plan{:}; ...
    mVideoTools, 'Base/Menus/Tools'; ...
    hVideoInfo, 'Base/Toolbars/Main/Tools/Standard'; ...
    hKeyPlayback, 'Base/KeyMgr'});

% -------------------------------------------------------------------------
function b = isRGB(hSource)

b = getNumInputs(hSource) == 3;

if ~b
    maxDimensions = getMaxDimensions(hSource, 1);
    b = numel(maxDimensions) == 3 && maxDimensions(3) == 3;
end

% [EOF]

% LocalWords:  UI hco ev videoinfo
