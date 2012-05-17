function menu = getDefuaultPopupSchema(this,manager,varargin)
% GETPOPUPSCHEMA Constructs the default popup menu

% Author(s): James G. Owen
% Revised: 
% Copyright 1986-2005 The MathWorks, Inc.
% $Revision: 1.1.6.5 $ $Date: 2005/12/15 20:58:20 $

%% Create menus
menu  = com.mathworks.mwswing.MJPopupMenu;
menuDelete = com.mathworks.mwswing.MJMenuItem(xlate('Delete'));
menuCopy = com.mathworks.mwswing.MJMenuItem(xlate('Copy'));
menuPaste = com.mathworks.mwswing.MJMenuItem(xlate('Paste'));
menuRename = com.mathworks.mwswing.MJMenuItem(xlate('Rename'));

%% Add them
menu.add(menuCopy);
menu.add(menuPaste);
menu.addSeparator;
menu.add(menuDelete);
menu.add(menuRename);

%% Assign menu callbacks
set(handle(menuDelete,'callbackproperties'),'ActionPerformedCallback',...
    @(es,ed) remove(this,manager));
set(handle(menuCopy,'callbackproperties'),'ActionPerformedCallback',...
    @(es,ed) copynode(this,manager))
set(handle(menuPaste,'callbackproperties'),'ActionPerformedCallback',...
    @(es,ed) pastenode(this,manager))
set(handle(menuRename,'callbackproperties'),'ActionPerformedCallback',...
    {@LocalRename,this,manager});

%% Add listener to update the enabled state of the paste menu depending on
%% the contents of the viewer clipboard
this.addListeners(handle.listener(manager.Root.Tsviewer,...
    manager.Root.Tsviewer.findprop('Clipboard'),'PropertyPostSet',...
    {@localSetPasteMenu manager.Root.Tsviewer menuPaste}));
localSetPasteMenu([],[],manager.Root.Tsviewer,menuPaste) % Exercise it

% --------------------------------------------------------------------------- %
function LocalRename(eventSrc,eventData,this,manager)

name = inputdlg(xlate('New node name'),xlate('Time Series Tools'),1,{this.Label});
if length(name)>0
    %Check duplicate or empty names
    [newname, status] = chkNameDuplication(this.up,name{1},class(this));
    if ~status
        return;
    end
   this.Label = newname;
end

function localSetPasteMenu(eventSrc,eventData,viewer,MenuPaste)

%% Callback to tsviewer clipboard listener which sets the enabled state of
%% the paste menu
MenuPaste.setEnabled(isa(viewer.ClipBoard,'tsguis.viewnode'));
