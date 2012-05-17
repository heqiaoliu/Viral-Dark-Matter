function menu = getPopupSchema(this,manager,varargin)
% GETPOPUPSCHEMA Constructs the default popup menu

% Copyright 2005-2008 The MathWorks, Inc.
% $Revision: 1.1.6.10 $ $Date: 2009/12/14 22:25:57 $

%% Create menus
menu  = com.mathworks.mwswing.MJPopupMenu;
menu.setName('PopupMenu');
menuDelete = com.mathworks.mwswing.MJMenuItem(xlate('Remove'));
menuDelete.setName('Remove');
menuCopy = com.mathworks.mwswing.MJMenuItem(xlate('Copy'));
menuCopy.setName('Copy');
menuPaste = com.mathworks.mwswing.MJMenuItem(xlate('Paste'));
menuPaste.setName('Paste');
menuRename = com.mathworks.mwswing.MJMenuItem(xlate('Rename'));
menuRename.setName('Rename');
menuRemoveMissing = com.mathworks.mwswing.MJMenuItem(xlate('Remove Missing Data...'));
menuRemoveMissing.setName('Remove Missing Data...');
menuDetrend = com.mathworks.mwswing.MJMenuItem(xlate('Detrend...'));
menuDetrend.setName('Detrend...');
menuFilter = com.mathworks.mwswing.MJMenuItem(xlate('Filter...'));
menuFilter.setName('Filter...');
menuInterpolate = com.mathworks.mwswing.MJMenuItem(xlate('Interpolate...'));
menuInterpolate.setName('Interpolate...');
menuExport = com.mathworks.mwswing.MJMenu(xlate('Export'));
menuExport.setName('Export');
menuExportFile = com.mathworks.mwswing.MJMenuItem(xlate('To File...'));
menuExportFile.setName('To File...');
menuExportWorkspace = com.mathworks.mwswing.MJMenuItem(xlate('To Workspace'));
menuExportWorkspace.setName('To Workspace');
menuResample = com.mathworks.mwswing.MJMenuItem(xlate('Resample...'));
menuResample.setName('Resample...');
menuExpression = com.mathworks.mwswing.MJMenuItem(xlate('Transform Algebraically...'));
menuExpression.setName('Transform Algebraically...');
%ViewsMenu = com.mathworks.mwswing.MJMenu(xlate('Add to Plot'));

%% Add them
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
menu.add(menuResample);
menu.addSeparator;
%menu.add(menuArithmetic);
menu.add(menuExpression);
%menu.addSeparator;
%menu.add(ViewsMenu);

%% Add view type menus and their children comprising menus for "new view"
%% and all existing views - removed for faster performance
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
%     newViewMenu = com.mathworks.mwswing.MJMenuItem(xlate('New plot...'));
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
set(handle(menuDelete,'callbackproperties'),'ActionPerformedCallback',...
    {@localRemove,this,manager})
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
set(handle(menuResample,'callbackproperties'),'ActionPerformedCallback',...
    @(es,ed) tsguis.datamergedlg(this))
set(handle(menuExpression,'callbackproperties'),'ActionPerformedCallback',...
    @(es,ed) openarithdlg(this,manager,get(this,'Label')));

%% Add listener to update the enabled state of the paste menu depending on
%% the contents of the viewer clipboard
this.addListeners(handle.listener(manager.Root.Tsviewer,...
    manager.Root.Tsviewer.findprop('Clipboard'),'PropertyPostSet',...
    {@localSetPasteMenu manager.Root.Tsviewer menuPaste}));
localSetPasteMenu([],[],manager.Root.Tsviewer,menuPaste) % Exercise it

% --------------------------------------------------------------------------- %
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

    %Record this transaction if this tsnode is a child of tscollectionNode
    %newname = newname{1};
    if isa(this.up,'tsguis.tscollectionNode')
        T = tsguis.nodetransaction;
        recorder = tsguis.recorder;
        newname = genvarname(newname);
        namepair = {this.Timeseries.Name,newname};
        
        %Add rename related info to the trnasaction object
        T.ObjectsCell = {this.Timeseries};
        T.Action = 'renamed';
        T.ParentNodeHandle = this.up;
        T.NamePair = namepair;
        
        %Store transaction
        %(note: nodetransaction does not require the action to be actually
        %performed before committing the transaction)
        T.commit; 
        recorder.pushundo(T);
    end

    %Rename the timeseries object (node name will be updated by the
    %updateNodeNameCallback
    this.Timeseries.Name = newname;
%     
% else
%     msgbox('Invalid name. Time series names must be non-empty and cause isvarname to return true.',...
%         'Time Series Tools','modal')
end

%-------------------------------------------------------------------------
function localSetPasteMenu(eventSrc,eventData,viewer,MenuPaste)

%% Callback to tsviewer clipboard listener which sets the enabled state of
%% the paste menu
MenuPaste.setEnabled(isa(viewer.ClipBoard,'tsguis.tsnode'));

%-------------------------------------------------------------------------
function LocalExportWorkspace(eventSrc, eventData, this)

%% export this timeseries object to workspace
list=evalin('base','whos;');
flag=false;
newName = genvarname(this.Timeseries.name);
for i=1:length(list)
    if strcmp(list(i).name,newName)
        flag=true;
        break;
    end
end
if ~strcmp(this.Timeseries.name,newName)
        warning('tstool:InvalidObjectName',...
            '%s %s','The time series object name is invalid.',...
            'Attempting to replace it by a variable named ',['''',newName,''''],'.');
end


if flag
    ButtonName = questdlg(sprintf('A variable with the name of %s already exists in the workspace.  Do you want to overwrite the existing variable or abort this operation?',newName),...
        'Duplicated Variable Detected','Overwrite','Abort','Overwrite');
    ButtonName = xlate(ButtonName);
    switch ButtonName,
        case xlate('Overwrite')
            assignin('base',newName,this.Timeseries.TsValue);
        case xlate('Abort')
            return
    end
else
    assignin('base',newName,this.Timeseries.TsValue);
end

msgbox(sprintf('Object ''%s'' was exported to the base workspace.',this.Timeseries.name),'Time Series Tools','modal');

%-------------------------------------------------------------------------
function localRemove(es,ed,this,manager)
% remove the timeseries

if strcmp(class(this.up),'tsguis.tscollectionNode')
    % timeseries chosen for deletion belongs to a tscollection
    manager.reset
    manager.Tree.setSelectedNode(this.up.getTreeNodeInterface);
    drawnow % Force the node to show seelcted
    manager.Tree.repaint
    %Record the remove-ts transaction
    T = tsguis.nodetransaction;
    recorder = tsguis.recorder;
    T.ObjectsCell = {this.Timeseries}; 
    T.Action = 'removed';
    T.ParentNodeHandle = this.up;

    this.up.Tscollection.removets(this.Timeseries.Name);

    if strcmp(recorder.Recording,'on')
        T.addbuffer(xlate('%% Delete Tscollection Member'));
        T.addbuffer([this.up.Tscollection.Name,' = removets(',this.up.Tscollection.Name,', ',this.Timeseries.Name,');'],this.up.Tscollection);
    end
    
    %% Store transaction
    T.commit;
    recorder.pushundo(T);

else
    remove(this,manager)
end

%--------------------------------------------------------------------------
function localPreproc(eventSrc,eventData,this,Ind)


RS = tsguis.datapreprocdlg(this);
set(RS.Handles.TABGRPpreproc,'SelectedIndex',Ind);
