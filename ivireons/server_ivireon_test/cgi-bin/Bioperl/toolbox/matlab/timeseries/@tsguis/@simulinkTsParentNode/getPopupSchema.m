function menu = getPopupSchema(this,manager,varargin)
% GETPOPUPSCHEMA Constructs the default popup menu for Simulink Ts Node.

% Author(s): Rajiv Singh
% Revised: 
% Copyright 2005 The MathWorks, Inc.
% $Revision: 1.1.6.3 $ $Date: 2005/12/15 20:56:49 $

%% Create menus
menu  = com.mathworks.mwswing.MJPopupMenu;
menuImportData = com.mathworks.mwswing.MJMenuItem(xlate('Import Logged Data...'));
menuPaste = com.mathworks.mwswing.MJMenuItem(xlate('Paste...'));

%% Add them
menu.add(menuImportData);
menu.add(menuPaste);

this.Handles.MenuItems = [menuImportData;menuPaste];
set(handle(menuImportData,'CallbackProperties'), 'ActionPerformedCallback', ...
    @(es,ed) addNode(this));
set(handle(menuPaste,'CallbackProperties'), 'ActionPerformedCallback', ...
    @(es,ed) paste(this,manager));

%% Add listener to update the enabled state of the paste menu depending on
%% the contents of the viewer clipboard
this.addListeners(handle.listener(manager.Root.Tsviewer,...
    manager.Root.Tsviewer.findprop('Clipboard'),'PropertyPostSet',...
    {@localSetPasteMenu manager.Root.Tsviewer menuPaste}));
localSetPasteMenu([],[],manager.Root.Tsviewer,menuPaste) % Exercise it


%--------------------------------------------------------------------------
function localSetPasteMenu(eventSrc,eventData,viewer,MenuPaste)

%% Callback to tsviewer clipboard listener which sets the enabled state of
%% the paste menu

CL = viewer.ClipBoard;
if ~isempty(CL) && isa(CL.getParentNode,'tsguis.simulinkTsParentNode')
    pasteFlag = true;
else
    pasteFlag = false;
end
    
MenuPaste.setEnabled(pasteFlag);
