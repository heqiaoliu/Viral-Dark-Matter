function menu = getPopupSchema(this,manager,varargin)
% GETPOPUPSCHEMA Constructs the default popup menu

% Copyright 1986-2008 The MathWorks, Inc.
% $Revision: 1.1.6.7 $ $Date: 2008/08/14 01:38:15 $

%% Create menus
menu  = com.mathworks.mwswing.MJPopupMenu;
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
menuResample = com.mathworks.mwswing.MJMenuItem(xlate('Resample...'));
menuExpression = com.mathworks.mwswing.MJMenuItem(xlate('Transform Algebraically...'));
%ViewsMenu = com.mathworks.mwswing.MJMenu(xlate('Add to Plot'));

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
    menu.add(menuRename);
    menu.addSeparator;
    set(handle(menuRename,'callbackproperties'),'ActionPerformedCallback',...
        {@LocalRename,this}); 
end
menu.add(menuExport);
menuExport.add(menuExportFile);
menuExport.add(menuExportWorkspace);
menu.addSeparator;
menu.add(menuRemoveMissing);
menu.add(menuDetrend);
menu.add(menuFilter);
menu.add(menuInterpolate);
menu.addSeparator;
menu.add(menuResample);
menu.addSeparator;
%menu.add(menuArithmetic);
menu.add(menuExpression);
%menu.addSeparator;
%menu.add(ViewsMenu);

%% Add view type menus and their children comprising menus for "new view"
%% and all existing views - removed for performance reasons
% viewsNode = manager.Root.Tsviewer.ViewsNode;
% viewTypeNodes = viewsNode.getChildren;
% for k=1:length(viewTypeNodes)
%     % Create the view type menu
%     viewTypeMenu = com.mathworks.mwswing.MJMenu(viewTypeNodes(k).Label);
%     ViewsMenu.add(viewTypeMenu);
%     
%     % Find the existing view nodes for this view type, if necessary
%     % exclusing nodes that are being removed (varargin{1})
%     viewNodes = viewTypeNodes(k).find('-class',viewTypeNodes(k).ChildClass);
%     if nargin==3
%         viewNodes = setdiff(viewNodes,varargin{1});
%     end
%     % Add the "new view" menu
%     newViewMenu = com.mathworks.mwswing.MJMenuItem(xlate('New view...'));
%     set(handle(newViewMenu,'Callbackproperties'),'ActionPerformedCallback', ...
%         {@localAddNewView,viewTypeNodes(k),manager,this.Timeseries})
%     viewTypeMenu.add(newViewMenu);
%     
%     % Add menus for each existing view
%     for j=1:length(viewNodes)
%         viewMenu = com.mathworks.mwswing.MJMenuItem(viewNodes(j).Label);
%         viewTypeMenu.add(viewMenu);
%         set(handle(viewMenu,'CallbackProperties'),'ActionPerformedCallback',...
%             @(es,ed) addTs(viewNodes(j),get(this,'Timeseries')),'MouseClickedCallback',...
%             @(es,ed) addTs(viewNodes(j),get(this,'Timeseries')));
%     end
% end

%% Assign menu callbacks
set(handle(menuCopy,'callbackproperties'),'ActionPerformedCallback',...
    @(es,ed) copynode(this,manager))
set(handle(menuPaste,'callbackproperties'),'ActionPerformedCallback',...
    @(es,ed) pastenode(this,manager))
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
set(handle(menuResample,'callbackproperties'),'ActionPerformedCallback',...
    @(es,ed) tsguis.datamergedlg(this))
set(handle(menuExpression,'callbackproperties'),'ActionPerformedCallback',...
    @(es,ed) openarithdlg(this,manager,get(this,'Label')));

%% Add listener to update the enabled state of the paste menu depending on
%% the contents of the viewer clipboard
this.addListeners(handle.listener(manager.Root.Tsviewer,...
    manager.Root.Tsviewer.findprop('Clipboard'),'PropertyPostSet',...
    {@localSetPasteMenu,manager.Root.Tsviewer,menuPaste,this}));
localSetPasteMenu([],[],manager.Root.Tsviewer,menuPaste,this) % Exercise it


%----------------------------------------------------------------------- %
function LocalRename(eventSrc, eventData, this)

name = inputdlg(xlate('New node name'),xlate('Time Series Tools'),1,{this.Label});
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
    oldname = this.Label;
    this.Timeseries.Name = newname;
    
    %explicitly update the timeseries name in the last table of the
    %sim-parent
    this.getParentNode.tstable_renamenode(this,oldname,newname);
end


%--------------------------------------------------------------------------
function localSetPasteMenu(eventSrc,eventData,viewer,MenuPaste,this)

%% Callback to tsviewer clipboard listener which sets the enabled state of
%% the paste menu
MenuPaste.setEnabled(isa(viewer.ClipBoard,'tsguis.simulinkTsNode') &&...
    isequal(viewer.ClipBoard.Timeseries,this.Timeseries));

%--------------------------------------------------------------------------
function LocalExportWorkspace(eventSrc, eventData, this)

%% export this timeseries object to workspace
list = evalin('base','whos;');
flag = false;
newName = genvarname(this.Timeseries.name);
for i = 1:length(list)
    if strcmp(list(i).name,newName)
        flag = true;
        break;
    end
end

if ~strcmp(this.Timeseries.name,newName)
        warning('tstool:InvalidObjectName',...
            '%s %s','The Simulink time series object name is invalid.',...
            'Attempting to replace it by a variable named ',['''',newName,''''],'.');
end

if flag
    ButtonName = questdlg(xlate('A variable with the same name as the timeseries object already exists in the workspace.  Do you want to overwrite the existing variable or abort this operation?'),...
        'Duplicate Variable Detected','Overwrite','Abort','Overwrite');
    ButtonName = xlate(ButtonName);
    switch ButtonName,
        case xlate('Overwrite')
            ts = this.Timeseries.copy;
            assignin('base',newName,ts);
        case xlate('Abort')
            return
    end
else
    ts = this.Timeseries.copy;
    assignin('base',newName,ts);
end

msgbox(sprintf('Object ''%s'' was exported to the base workspace.',this.Timeseries.name),'Time Series Tools','modal');

%--------------------------------------------------------------------------
function localPreproc(eventSrc,eventData,this,Ind)


RS = tsguis.datapreprocdlg(this);
set(RS.Handles.TABGRPpreproc,'SelectedIndex',Ind);