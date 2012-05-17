function this = SrcOptsExt(hApp, hReg, hCfg)
%SrcOptsExt Manage data source extensions.
%   A "required" extension that allows user to manage properties
%   and behaviors affecting all Source extensions.

% Copyright 2004-2006 The MathWorks, Inc.
% $Revision: 1.1.6.4 $ $Date: 2009/08/14 04:07:44 $

this = uiscopes.SrcOptsExt;
this.init(hApp, hReg, hCfg);

this.DataSourceChangedListener = handle.listener(hApp, ...
    'DataSourceChanged', @(hApp, ev) addRecentSource(this));

h = hApp.getGUI.findchild('Menus','File',...
    'RecentSourceItems', [appName2VarName(hApp) 'Preferences']);

this.RecentSources = h.recentFiles;

this.RecentSources.LoadCallback = @()loadRecentSource(this);
this.RecentSources.setMax(this.findProp('RecentSourcesListLength').Value);
this.RecentSources.EmptyListMsg = '<no recent source>';

propertyChanged(this, 'ShowRecentSources');

% [EOF]
