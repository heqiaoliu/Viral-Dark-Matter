function propertyChanged(this, eventData)
%PROPERTYCHANGED property change event handler

%   Copyright 2007-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.11 $  $Date: 2009/10/29 16:10:01 $

if ischar(eventData)
    hProp = findProp(this, eventData);
else
    hProp = get(eventData, 'AffectedObject');
end
value = get(hProp, 'Value');

switch hProp.Name
    case 'DisplayFullSourceName'
        send(this.Application, 'UpdateTitleBarEvent');
    case 'MessageLogAutoOpenMode'
        this.Application.MessageLog.AutoOpenMode = value;
    case 'ShowStatusbar'
        if this.Application.ScopeCfg.hideStatusBar
            value = false;
        end
        vis = logical2visible(value);
        showStatusbar(this, vis);
        
        hUIMgr = this.Application.getGUI;
        hMenu = hUIMgr.findwidget('Menus', 'View', 'ViewBars', 'ShowStatusBar');
        set(hMenu, 'Checked', vis);
        
    case {'ShowSaveConfigSet', 'ShowLoadConfigSet'}
        
        saveValue = getPropValue(this, 'ShowSaveConfigSet');
        loadValue = getPropValue(this, 'ShowLoadConfigSet');
        
        % If the savevalue is true, add the save menu.  Otherwise remove it.
        if saveValue
            addMenu(this, 'SaveMenu', 'CfgSetLoadSave');
        else
            removeMenu(this, 'SaveMenu', 'CfgSetLoadSave', 'CfgSetSave');
        end
        
        % If the loadValue is true, add the load and recent configs menus,
        % otherwise remove them.
        if loadValue
            addMenu(this, 'LoadMenu', 'CfgSetLoadSave');
            addMenu(this, 'RecentConfigurationsMenu');
        else
            removeMenu(this, 'LoadMenu', 'CfgSetLoadSave', 'CfgSetLoad');
            removeMenu(this, 'RecentConfigurationsMenu', 'CfgSetRecentFiles');
        end
        
        % If save or load is present, keep the edit menu item as a submenu.  If
        % not, remove them and change the cascading Configuration menu into the
        % edit action.
        hcfg = this.Application.getGUI.findchild('Menus', 'File', 'FileSets', 'Configs');
        if saveValue || loadValue
            
            addMenu(this, 'EditMenu');
            
            
            pvPairs = {...
                'Callback', '', ...
                'Label', uiscopes.message('ConfigurationCascadeMenu')};
            if hcfg.isRendered
                set(hcfg.WidgetHandle, pvPairs{:});
            else
                set(hcfg, 'WidgetProperties', pvPairs);
            end
        else
            removeMenu(this, 'EditMenu', 'CfgSetEdit');
            
            pvPairs = {...
                'Callback', @(h,ev) editConfigSet(this.Application.extDriver), ...
                'Label', uiscopes.message('ConfigurationEditMenu')};

            if hcfg.isRendered
                set(hcfg.WidgetHandle, pvPairs{:});
            else
                set(hcfg, 'WidgetProperties', pvPairs);
            end
        end
        
    case 'ShowMainToolbar'
        vis = logical2visible(value);
        showMainToolbar(this, vis);
        % reset view maintoolbar menu
        hUIMgr = this.Application.getGUI;
        hMenu = hUIMgr.findwidget('Menus', 'View', 'ViewBars','ShowMainToolbar');
        set(hMenu, 'Checked', vis);
        
    case 'ShowPlaybackToolbar'
        if isempty(this.Application.DataSource) || ...
                isempty(this.Application.DataSource.Controls) || ...
                ~shouldShowControls(this.Application.DataSource, 'Base')
            vis = 'off';
        else
            vis = logical2visible(value);
        end
        showPlaybackToolbar(this, vis);
        % reset view optiontoolbar menu
        hUIMgr = this.Application.getGUI;
        hMenu = hUIMgr.findwidget('Menus', 'View', 'ViewBars','ShowPlaybackToolbar');
        set(hMenu, 'Checked', vis);
        
    case 'ShowNewAction'
        vis = logical2visible(value);
        % change visibility of new items
        hUIMgr = this.Application.getGUI;
        hNewMenu = hUIMgr.findchild('Menus', 'File', 'New');
        hNewButton = hUIMgr.findchild('Toolbars', 'Main', 'New');
        set(hNewMenu, 'Visible', vis);
        set(hNewButton, 'Visible', vis);

end

% -------------------------------------------------------------------------
function removeMenu(this, field, varargin)

if isempty(this.(field))
    hUI = this.Application.getGUI;
    hMenu = hUI.findchild('Menus', 'File', 'FileSets', 'Configs', varargin{:});
    
    % Save the menu in the object to be added later.
    this.(field) = hMenu;
    
    % Remove the menu.
    remove(hMenu);
end

% -------------------------------------------------------------------------
function addMenu(this, field, varargin)

hMenu = this.(field);
if ~isempty(hMenu)
    
    hUI = this.Application.getGUI;
    
    % Capture the old placement.
    recentPlacement = hMenu.Placement;
    
    hParent = hUI.findchild('Menus', 'File', 'FileSets', 'Configs', varargin{:});
    
    % Add the menu back
    hParent.add(hMenu);
    
    % Reset to the correct position.
    hMenu.Placement = recentPlacement;
    
    if hParent.isRendered
        render(hParent);
    end
    this.(field) = [];
end


% -------------------------------------------------------------------------
function visState = logical2visible(value)

if value
    visState = 'on';
else
    visState = 'off';
end

% -------------------------------------------------------------------------
function showStatusbar(this, vis)
%SHOWSTATUSBAR show or hide status bar

statusBar = this.Application.UIMgr.findchild('StatusBar');
set(statusBar, 'Visible', vis);

% -------------------------------------------------------------------------
function showMainToolbar(this, vis)
%SHOWMAINTOOLBAR show or hide main toolbar

hUIMgr = getGUI(this.Application);
hToolbar = hUIMgr.findchild('Toolbars', 'Main');
set(hToolbar, 'Visible', vis);

% Fix the order of the toolbars by turning the playback on and off.
hPlaybackToolbar = hUIMgr.findchild('Toolbars', 'Playback');
if strcmpi(vis, 'on') && strcmpi(get(hPlaybackToolbar, 'Visible'), 'on')
    set(hPlaybackToolbar, 'Visible', 'Off');
    drawnow;
    set(hPlaybackToolbar, 'Visible', 'On');
end

% -------------------------------------------------------------------------
function showPlaybackToolbar(this, vis)
%SHOWOPTIONTOOLBAR show or hide option toolbar

hUIMgr = getGUI(this.Application);
hToolbar = hUIMgr.findchild('Toolbars', 'Playback');
set(hToolbar, 'Visible', vis);

% [EOF]
