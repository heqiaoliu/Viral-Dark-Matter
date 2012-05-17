function hInstall = createGUI(this)
% Create a default UI

%   Copyright 2009-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $     $Date: 2010/03/31 18:41:26 $

p = abstractVisual_createGUI(this);

% Create different menus if the NTX feature is turned "On".
if this.NTXFeaturedOn
    % Add NTX related menus to the framework.
    hmenus = createNTXMenus(this);
    hInstall = uimgr.uiinstaller([p;...
                        hmenus]);
else
    mInfo = uimgr.uimenu('DataInfo',-inf,'Data &Information');
    mInfo.WidgetProperties = {...
        'callback', @(hco,ev) show(this.HistogramInfo, true)};
    
    
    %  Place Histogram Info first
    bHistogramInfo = uimgr.uipushtool('DataInfo');
    bHistogramInfo.AutoPlacement = true;
    bHistogramInfo.IconAppData = 'info';
    bHistogramInfo.WidgetProperties = {...
        'busyaction','cancel', ...
        'tooltip','Data information', ...
        'click', @(hco,ev) show(this.HistogramInfo, true)};
    
    kKeyPlayback = uimgr.spckeygroup('Histogram');
    kKeyPlayback.add( ...
        uimgr.spckeybinding('datainfo','D',...
                            @(h,ev) show(this.HistogramInfo, true), 'Display data information'));
    
    % Add the option to show/hide the legend to the View Menu.
    mViewLegend = uimgr.spctogglemenu('ShowLegend',inf,'Show Legend');
    % Disable the legend by default. We will enable it once the axes is made visible.
    mViewLegend.Enable = 'off';
    mViewLegend.WidgetProperties = {...,
        'checked', logical2checked(this.findProp('ShowLegend').Value),...
        'callback',@(hco,ev)showLegendToggle(this)};
    
    hInstall = uimgr.uiinstaller([p;...
                        {mInfo, 'Base/Menus/View';...
                        bHistogramInfo, 'Base/Toolbars/Main/Tools/Standard';...
                        kKeyPlayback, 'Base/KeyMgr';...
                        mViewLegend, 'Base/Menus/View'}]);
    
end

% -------------------------------------------------------------------------
function checkState = logical2checked(value)
% Convert from logical value to On/Off
if value
    checkState = 'on';
else
    checkState = 'off';
end

% -------------------------------------------------------------------------
function showLegendToggle(this)
%SHOWLEGENDTOGGLE Turn on/off legend

hProp = this.findProp('ShowLegend');
hProp.Value = ~hProp.Value;

%------------------------------------------
