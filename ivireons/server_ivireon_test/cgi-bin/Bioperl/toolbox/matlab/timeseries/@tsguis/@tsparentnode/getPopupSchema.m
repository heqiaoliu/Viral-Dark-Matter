function menu = getPopupSchema(this,manager)
% GETPOPUPSCHEMA Constructs the default popup menu

% Author(s): 
% Revised: 
% Copyright 1986-2005 The MathWorks, Inc.
% $Revision: 1.1.6.5 $ $Date: 2005/12/15 20:57:49 $

%% Add the Add time series menu
menu  = com.mathworks.mwswing.MJPopupMenu;
menuAddTs = com.mathworks.mwswing.MJMenuItem(xlate('Import Workspace Objects...'));
menuImportRawData = com.mathworks.mwswing.MJMenuItem(xlate('Import Raw Data...'));
menuPaste = com.mathworks.mwswing.MJMenuItem(xlate('Paste...'));
menu.add(menuAddTs);
menu.add(menuImportRawData);
menu.add(menuPaste);

this.Handles.MenuItems = [menuAddTs;menuPaste;menuImportRawData];
set(handle(menuAddTs,'CallbackProperties'), 'ActionPerformedCallback', ...
    @(es,ed) addNode(this));
set(handle(menuImportRawData,'CallbackProperties'), 'ActionPerformedCallback', ...
    @(es,ed) tsguis.ImportWizard(tsguis.tsviewer));
set(handle(menuPaste,'CallbackProperties'), 'ActionPerformedCallback', ...
    @(es,ed) paste(this,manager));


%% Add listener to update the enabled state of the paste menu depending on
%% the contents of the viewer clipboard
this.addListeners(handle.listener(manager.Root.Tsviewer,...
    manager.Root.Tsviewer.findprop('Clipboard'),'PropertyPostSet',...
    {@localSetPasteMenu manager.Root.Tsviewer menuPaste}));
localSetPasteMenu([],[],manager.Root.Tsviewer,menuPaste) % Exercise it

function localSetPasteMenu(eventSrc,eventData,viewer,MenuPaste)

%% Callback to tsviewer clipboard listener which sets the enabled state of
%% the paste menu
MenuPaste.setEnabled(strcmp(class(viewer.ClipBoard),'tsguis.tsnode') || ...
    strcmp(class(viewer.ClipBoard),'tsguis.tscollectionNode'));

