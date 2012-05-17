function hInstall = createGUI(this)
%CREATEGUI Create the GUI from UIMGR components.

%   Author(s): J. Schickler
%   Copyright 2007-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2010/01/25 22:46:51 $

iSet = uimgr.uimenugroup('InstrumentSets', 0, 'Ins&trumentation Sets');
iSet.Placement = 99;

iSetLoad = uimgr.uimenu('ISetLoad', '&Load Set ...');
iSetLoad.WidgetProperties = {...
    'callback', @(hco,ev) callback(this.Application, @() load(this), @(str, id) warningParser(this, str, id))};

iSetSave = uimgr.uimenu('ISetSave','&Save Set ...');
iSetSave.WidgetProperties = {...
    'callback', @(hco,ev) callback(this.Application, @() save(this), @(str, id) warningParser(this, str, id))};

% Setup group just for Load/Save
iSetLoadSave = uimgr.uimenugroup('ISetLoadSave', iSetLoad, iSetSave);

% Setup group for containing multiple recent config set items
iSetItems = uimgr.uimenugroup('ISetItems', '<dummy>');  % just one for now

% Attach recentfileslist object to items menu
iSetItems.add(this.RecentFilesUI);

iSetRecentFiles = uimgr.uimenugroup('ISetRecentFiles', iSetItems);

% Put all of config-set-handling items together and add to the file menu
iSet.add(iSetLoadSave, iSetRecentFiles);
iSet.placement = -2;

hInstall = uimgr.uiinstaller({iSet, 'Base/Menus/File/FileSets'});

% [EOF]
