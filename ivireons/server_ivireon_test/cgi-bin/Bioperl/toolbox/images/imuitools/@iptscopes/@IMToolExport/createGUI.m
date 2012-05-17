function plugInGUI = CreateGUI(this)   %#ok hSrc not used
%CreateGUI Build and cache UI plug-in for IMTool Export plug-in.
%   This adds the button and menu to the scope.
%   No install/render needs to be done here.

%   Copyright 2007-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2008/04/03 03:12:45 $

% Place=1 for each of these within their respective Export groups
mExport = uimgr.uimenu('IMToolExport','&Export to Image Tool');
mExport.WidgetProperties = {...
    'busyaction', 'cancel', ...
    'separator', 'on', ...
    'accel',     'e', ...
    'callback',  @(hco, ev) lclExport(this)};

% Add the Export to IMTool toolbar button.
bExport = uimgr.uipushtool('IMToolExport');
bExport.IconAppData = 'export_to_imtool';
bExport.WidgetProperties = {...
    'busyaction',    'cancel', ...
    'interruptible', 'off', ...
    'tooltip',       'Export to Image Tool', ...
    'click',         @(hco, ev) lclExport(this)};

% Create plug-in installer
plan = {mExport, 'Base/Menus/File/Export'; ...
        bExport, 'Base/Toolbars/Main/Export'};
plugInGUI = uimgr.uiinstaller(plan);

%% ------------------------------------------------------------------------
function lclExport(this)

try
    export(this);
catch ME
    uiscopes.errorHandler(ME.message);
end

% [EOF]
