function menu = getPopupSchema(this,manager,varargin)
% GETPOPUPSCHEMA Constructs the default popup menu for ModelDataLogs node

% Copyright 2005 The MathWorks, Inc.
% $Revision: 1.1.6.3 $ $Date: 2005/12/15 20:56:45 $

%% Create menus
menu  = com.mathworks.mwswing.MJPopupMenu;
menuCopy = com.mathworks.mwswing.MJMenuItem(xlate('Copy'));
menuPaste = com.mathworks.mwswing.MJMenuItem(xlate('Paste'));
menuExport = com.mathworks.mwswing.MJMenu(xlate('Export'));
menuExportFile = com.mathworks.mwswing.MJMenuItem(xlate('To File...'));
menuExportWorkspace = com.mathworks.mwswing.MJMenuItem(xlate('To Workspace'));

%ViewsMenu = com.mathworks.mwswing.MJMenu('Add to Plot');

%% Add them
menu.add(menuCopy);
menu.add(menuPaste);
menu.addSeparator;
if strcmp(this.up.Label,'Simulink Time Series')
    % remove
    menuDelete = com.mathworks.mwswing.MJMenuItem(xlate('Remove'));
    menu.add(menuDelete);
    set(handle(menuDelete,'callbackproperties'),'ActionPerformedCallback',...
        @(es,ed) remove(this,manager))
    
    %rename
    menuRename = com.mathworks.mwswing.MJMenuItem(xlate('Rename'));
    menu.add(menuRename);
    menu.addSeparator;
    set(handle(menuRename,'callbackproperties'),'ActionPerformedCallback',...
        {@LocalRename,this,manager}); 
end

menu.add(menuExport);
menuExport.add(menuExportFile);
menuExport.add(menuExportWorkspace);

%% Assign menu callbacks
set(handle(menuCopy,'callbackproperties'),'ActionPerformedCallback',...
    @(es,ed) copynode(this,manager))
set(handle(menuPaste,'callbackproperties'),'ActionPerformedCallback',...
    @(es,ed) pastenode(this,manager))
set(handle(menuExportFile,'callbackproperties'),'ActionPerformedCallback',...
    @(es,ed) openExportdlg(this,manager))  
set(handle(menuExportWorkspace,'callbackproperties'),'ActionPerformedCallback',...
    @(es,ed) exportToWorkspace(this));

%% Add listener to update the enabled state of the paste menu depending on
%% the contents of the viewer clipboard
this.addListeners(handle.listener(manager.Root.Tsviewer,...
    manager.Root.Tsviewer.findprop('Clipboard'),'PropertyPostSet',...
    {@localSetPasteMenu manager.Root.Tsviewer,menuPaste,this}));
localSetPasteMenu([],[],manager.Root.Tsviewer,menuPaste,this) % Exercise it                       
                           
%--------------------------------------------------------------------------
function localSetPasteMenu(eventSrc,eventData,viewer,MenuPaste,this)

%% Callback to tsviewer clipboard listener which sets the enabled state of
%% the paste menu
if ~isempty(viewer.ClipBoard)
    MenuPaste.setEnabled(isa(viewer.ClipBoard,'tsguis.simulinkTsArraynode') &&...
        isequal(viewer.ClipBoard.SimModelhandle,this.SimModelhandle))
else
    MenuPaste.setEnabled(false);
end


%--------------------------------------------------------------------------
function LocalRename(eventSrc, eventData, this, manager)

name = inputdlg('New node name','Time Series Tools');
if ~isempty(name) 
    
    % Check duplicate or empty names
    [newname, status] = chkNameDuplication(this.up,name{1},class(this));
    if ~status
        return;
    end

    % Check that this timeseries is not plotted
    viewerH = tsguis.tsviewer;
    if viewerH.isTimeseriesViewed(this)
        errordlg('Cannot change the name of a time series which appears in one or more plots.',...
            'Time Series Tools','modal')
        return
    end
    
    oldnodepath = constructNodePath(this);
    oldname = this.Label;
    %this.SimModelhandle.Name = newname{1};
    this.Label = newname;
    newnodepath = constructNodePath(this);
    %this.updatePanel; % propagate the name change info up the hierarachy
    
    %explicitly update the model name in the parent panel's tables.
    this.getParentNode.tstable_renamenode(this,oldname,newname);
    
    % Call fireTsStructureChangeEvent to update path cache and send
    % tsstructurechange event:    
    %  construct event data instance
    ed = tsexplorer.tstreeevent(manager.Root,'rename',this);
    manager.Root.fireTsStructureChangeEvent(ed,{oldnodepath,newnodepath});
end
