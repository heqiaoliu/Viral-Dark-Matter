function menu = getPopupSchema(this,manager,varargin)
% GETPOPUPSCHEMA Constructs the default popup menu for tscollection node

% Author(s): Rajiv Singh
% Copyright 2005-2008 The MathWorks, Inc.
% $Revision: 1.1.6.6 $ $Date: 2008/08/14 01:38:16 $

%% Create menus
menu  = com.mathworks.mwswing.MJPopupMenu;
menuDelete = com.mathworks.mwswing.MJMenuItem(xlate('Remove'));
menuCopy = com.mathworks.mwswing.MJMenuItem(xlate('Copy'));
menuPaste = com.mathworks.mwswing.MJMenuItem(xlate('Paste'));
menuRename = com.mathworks.mwswing.MJMenuItem(xlate('Rename'));
menuRemoveMissing = com.mathworks.mwswing.MJMenuItem(xlate('Remove Missing Data...'));
menuDetrend = com.mathworks.mwswing.MJMenuItem(xlate('Detrend...'));
menuFilter = com.mathworks.mwswing.MJMenuItem(xlate('Filter...'));
menuInterpolate = com.mathworks.mwswing.MJMenuItem(xlate('Interpolate...'));
menuExport = com.mathworks.mwswing.MJMenu(xlate('Export'));
menuExportFile = com.mathworks.mwswing.MJMenuItem(xlate('To File...'));
menuExportWorkspace = com.mathworks.mwswing.MJMenuItem(xlate('To Workspace'));
menuExpression = com.mathworks.mwswing.MJMenuItem(xlate('Transform Algebraically...'));
menuAddTs = com.mathworks.mwswing.MJMenuItem(xlate('Add Time Series...'));

%% Add them
menu.add(menuAddTs);
menu.addSeparator;
menu.add(menuCopy);
menu.add(menuPaste);
menu.addSeparator;
menu.add(menuDelete);
menu.add(menuRename);
menu.addSeparator;
menu.add(menuExport);
menuExport.add(menuExportFile);
menuExport.add(menuExportWorkspace);
menu.addSeparator;
menu.add(menuRemoveMissing);
menu.add(menuDetrend);
menu.add(menuFilter);
menu.add(menuInterpolate);
menu.addSeparator;
menu.add(menuExpression);

%% Assign menu callbacks
set(handle(menuDelete,'callbackproperties'),'ActionPerformedCallback',...
    @(es,ed) remove(this,manager))
set(handle(menuCopy,'callbackproperties'),'ActionPerformedCallback',...
    @(es,ed) copynode(this,manager))
set(handle(menuPaste,'callbackproperties'),'ActionPerformedCallback',...
    @(es,ed) pastenode(this,manager))
set(handle(menuRename,'callbackproperties'),'ActionPerformedCallback',...
    {@LocalRename,this}); 
set(handle(menuExportFile,'callbackproperties'),'ActionPerformedCallback',...
    @(es,ed) openExportdlg(this,manager))  
set(handle(menuExportWorkspace,'callbackproperties'),'ActionPerformedCallback',...
    {@LocalExportWorkspace,this});
set(handle(menuRemoveMissing,'callbackproperties'),'ActionPerformedCallback',...
    {@localPreproc this 4})
set(handle(menuDetrend,'callbackproperties'),'ActionPerformedCallback',...
    {@localPreproc this 1})
set(handle(menuFilter,'callbackproperties'),'ActionPerformedCallback',...
    {@localPreproc this 2})
set(handle(menuInterpolate,'callbackproperties'),'ActionPerformedCallback',...
    {@localPreproc this 3})
% set(handle(menuResample,'callbackproperties'),'ActionPerformedCallback',...
%     @(es,ed) tsguis.datamergedlg(this))
set(handle(menuExpression,'callbackproperties'),'ActionPerformedCallback',...
    @(es,ed) openarithdlg(this,manager,get(this,'Label')));

%% Add listener to update the enabled state of the paste menu depending on
%% the contents of the viewer clipboard
this.addListeners(handle.listener(manager.Root.Tsviewer,...
    manager.Root.Tsviewer.findprop('Clipboard'),'PropertyPostSet',...
    {@localSetPasteMenu manager.Root.Tsviewer menuPaste}));
localSetPasteMenu([],[],manager.Root.Tsviewer,menuPaste) % Exercise it

this.Handles.MenuItems = menuAddTs;
set(handle(menuAddTs,'CallbackProperties'), 'ActionPerformedCallback', ...
    {@localAddNewMember,this});
                       
                           
% ---------------------------------------------------------------------- %
function LocalRename(eventSrc,eventData,this)

name = inputdlg('New node name','Time Series Tools');
if ~isempty(name)
    %Check duplicate or empty names
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
    
    this.Tscollection.Name = newname;
end

%--------------------------------------------------------------------------
function localSetPasteMenu(eventSrc,eventData,viewer,MenuPaste)

%% Callback to tsviewer clipboard listener which sets the enabled state of
%% the paste menu
MenuPaste.setEnabled(isa(viewer.ClipBoard,'tsguis.tscollectionNode') ||...
    isa(viewer.ClipBoard,'tsguis.tsnode'));

%--------------------------------------------------------------------------
function LocalExportWorkspace(eventSrc,eventData,this)

%% Export this tscollection object to workspace
list = evalin('base','whos;');
flag = false; % Is the new var name already in the workspace
newName = genvarname(this.Tscollection.name);
for i=1:length(list)
    if strcmp(list(i).name,newName)
        flag = true;
        break;
    end
end
if ~strcmp(this.Tscollection.name,newName)
        warning('tstool:InvalidObjectName',...
            '%s %s','The tscollection object name is invalid.',...
            'Attempting to replace it by a variable named ',['''',newName,''''],'.');
end

%% Write the tscollection to the workspace, perhaps after warning
%% about an overwrite
if flag
    ButtonName = questdlg(sprintf('A variable with the name of %s already exists in the workspace.  Do you want to overwrite the existing variable or abort this operation?',newName),...
        'Duplicated Variable Detected','Overwrite','Abort','Overwrite');
    ButtonName = xlate(ButtonName);
    switch ButtonName,
        case xlate('Overwrite')
            assignin('base',newName,this.Tscollection.TsValue);
        case xlate('Abort')
            return
    end
else
    assignin('base',newName,this.Tscollection.TsValue);
end

msgbox(sprintf('Object ''%s'' was exported to the base workspace.',...
    this.Tscollection.Name),'Time Series Tools','modal');

%--------------------------------------------------------------------------
function localAddNewMember(es,ed,this)

importTsCallback(this);

%--------------------------------------------------------------------------
function localPreproc(eventSrc,eventData,this,Ind)


RS = tsguis.datapreprocdlg(this);
set(RS.Handles.TABGRPpreproc,'SelectedIndex',Ind);
