function figmenus(this)
%figure menus for tstool

%   Copyright 2005-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.19 $  $Date: 2010/05/13 17:42:53 $

%% Create toolbar
htoolbar = uitoolbar(this.TreeManager.Figure,'HandleVisibility','off');

%check if Simulink is installed
mlock
persistent isSimulinkInstalled;
if isempty(isSimulinkInstalled)
    isSimulinkInstalled = license('test', 'Simulink') && exist('bdclose', 'file');
end


%%%%%%%%%%%%%%%%%%%% File menu %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fileMenu = uimenu('Parent',this.TreeManager.Figure,'Label','File', 'Tag', 'ts.File');
ic1 = fullfile(matlabroot,'toolbox','matlab','timeseries','import_ml_data.gif'); %#ok<MCTBX,MCMLR>
uipushtool(htoolbar,'Tooltip','Import time series or collection object',...
    'CData',localGetIcon(ic1,72),'ClickedCallback',{@localAddTS this});

%% File - Import Menu
importMenu = uimenu('Parent',fileMenu,'Label',xlate('Import from Workspace'), 'Tag', 'ts.ImportFromWorkspace');
uimenu('Parent',importMenu,'Label',...
    xlate('Array Data...'),'Callback', {@localImport this xlate('MATLAB workspace')}, 'Tag', 'ts.ArrayData');
uimenu('Parent',importMenu,'Label',...
    xlate('Time Series Objects or Collections...'),'Callback',{@localAddTS this}, 'Tag', 'ts.tsObjects');
uimenu('Parent',fileMenu,'Label',xlate('Create Time Series from File...'),...
    'Callback', {@localImport this xlate('Excel Workbook (.xls)')},'Tag','ts.ImportFromFile');

% Simulink Data import pushtool and import option
if isSimulinkInstalled
    ic2 = fullfile(matlabroot,'toolbox','matlab','timeseries','import_sl_data.gif'); %#ok<MCTBX,MCMLR>
    uipushtool(htoolbar,'Tooltip','Import Simulink data logs',...
        'CData',localGetIcon(ic2,33),'ClickedCallback',{@localAddSimTS this});
    uimenu('Parent',importMenu,'Label',...
        xlate('Simulink Data Logs...'),'Callback',{@localAddSimTS this}, 'Tag', 'ts.tsSimulink');
end
ic3 = fullfile(matlabroot,'toolbox','matlab','timeseries','import_data.gif'); %#ok<MCTBX,MCMLR>
uipushtool(htoolbar,'Tooltip',xlate('Create time series from file or workspace data'),...
    'CData',localGetIcon(ic3,24),...
    'ClickedCallback',{@localImport this 'Excel Workbook (.xls)'});

%% File - Export submenu
exportMenu = uimenu('Parent',fileMenu,'Label','Export...','Tag','ts.export');
uimenu('Parent',exportMenu,'Label', ...
    'To File...','Callback',{@localFileExport this}, 'Tag', 'ts.ToFile');
uimenu('Parent',exportMenu,'Label', ...
    'To Workspace','Callback',{@localWorkspaceExport this}, 'Tag', 'ts.ToWorkspace');

%% File - macro recorder
recorder = tsguis.recorder;
uimenu('Parent',fileMenu,'Label','Record Code...',...
    'Separator','on','Callback',@(es,ed) edit(recorder,this.TreeManager.Figure), 'Tag', 'ts.RecordMcode');

%% File - close submenu
uimenu('Parent',fileMenu,'Label','Close','Separator','on',...
    'Callback',@(es,ed) delete(get(this,'TreeManager')), 'Tag', 'ts.Close');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Edit menu %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
editMenu = uimenu('Parent',this.TreeManager.Figure,'Label','Edit','Tag','ts.edit', 'Tag', 'ts.Edit');

%% Edit Undo and Redo menus and toolbar
undoMenu = uimenu('Parent',editMenu,'Label','Undo','Callback', ...
    @localUndo,'Tag','ts.undo','Interruptible',...
    'off','BusyAction','cancel');
redoMenu = uimenu('Parent',editMenu,'Label','Redo','Callback',...
    @localRedo,'Tag','ts.redo','Interruptible',...
    'off','BusyAction','cancel');
load(fullfile(matlabroot,'toolbox','matlab','icons','undo.mat')); %#ok<MCMLR,MCTBX>
undoTB = uipushtool(htoolbar,'Tooltip','Undo data change',...
    'Tag','ts.undo','CData',undoCData,...
    'ClickedCallback',@localUndo,'Interruptible',...
    'off','BusyAction','cancel');
load(fullfile(matlabroot,'toolbox','matlab','icons','redo.mat')); %#ok<MCTBX,MCMLR>
redoTB = uipushtool(htoolbar,'Tooltip','Redo data change',...
    'Tag','ts.redo','CData',redoCData,...
    'ClickedCallback',@localRedo,'Interruptible',...
    'off','BusyAction','cancel');
r = tsguis.recorder;
L = [handle.listener(r,r.findprop('Undo'),'PropertyPostSet',...
       {@setUndoStatus undoMenu undoTB r});...
     handle.listener(r,r.findprop('Redo'),'PropertyPostSet',...
       {@setRedoStatus redoMenu redoTB r})];
this.Listeners = [this.Listeners; L];
setUndoStatus([],[],undoMenu,undoTB,r)
setRedoStatus([],[],redoMenu,redoTB,r)

%% Copy menu
copyMenu = uimenu('Parent',editMenu,'Label','Copy','Separator','on',...
    'Callback',{@localCopy this},'Tag','ts.copy');

%% Copy toolbar button
copyTB = uipushtool(htoolbar,'Tooltip','Copy time series object',...
    'Tag','ts.copy','CData',localGetIcon('copy.gif',8),...
    'ClickedCallback',{@localCopy this});

%% Paste toolbar button
pasteTB = uipushtool(htoolbar,'Tooltip','Paste time series object',...
    'Tag','ts.paste','CData',localGetIcon('paste.gif',58),...
    'ClickedCallback',{@localPaste this this.TreeManager},'Interruptible',...
    'off','BusyAction','cancel');

%% Paste menu
pasteMenu = uimenu('Parent',editMenu,'Label','Paste','Callback',...
    {@localPaste this this.TreeManager},'Tag','ts.paste','Interruptible',...
    'off','BusyAction','cancel');

%% Paste action listeners
this.Listeners = [this.Listeners;...
     handle.listener(this,this.findprop('Clipboard'),'PropertyPostSet',...
     {@localClipBoardUpdate this pasteMenu pasteTB})];
localClipBoardUpdate([],[],this,pasteMenu,pasteTB)

%% Edit - delete menu
deleteMenu = uimenu('Parent',editMenu,'Label','Remove','Separator','on',...
    'Callback',{@localDelete this},'Tag','ts.delete','Interruptible',...
    'off','BusyAction','cancel');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Data menu %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
dataMenu = uimenu('Parent',this.TreeManager.Figure,'Label','Data','Tag','ts.data');

%% Data - manipulation submenus
selectionMenu = uimenu('Parent',dataMenu,'Label','Select data on Time Plot...','Callback',...
    {@localDataSelect this},'Tag','ts.select');
uimenu('Parent',dataMenu,'Label','Remove Missing Data...','Callback',...
    {@localPreproc this},'Tag','ts.remove');
uimenu('Parent',dataMenu,'Label','Detrend...','Callback',...
    {@localPreproc this },'Tag','ts.detrend');
uimenu('Parent',dataMenu,'Label','Filter...','Callback',...
    {@localPreproc this},'Tag','ts.filter');
uimenu('Parent',dataMenu,'Label','Interpolate...','Callback',...
    {@localPreproc this},'Tag','ts.interp');

mergeMenu = uimenu('Parent',dataMenu,'Label','Resample...','Callback',...
    {@localMerge this},'Tag','ts.merge','Separator','on');
%% Data - Arithmetic
matlabMenu = uimenu('Parent',dataMenu,'Label','Transform Algebraically...','Callback',...
    {@localArith this},'Tag','ts.arith');
shiftMenu = uimenu('Parent',dataMenu,'Label','Synchronize...','Callback',...
    {@localTimeShift this},'Tag','ts.shift'); 

%% Data - stats submenu
statsMenu = uimenu('Parent',dataMenu,'Label','Descriptive Statistics...',...
    'Callback',{@localOpenStats this.Tsnode this.TreeManager},...
    'Separator','on','Tag','ts.descriptive');

%% Plot menu - note xlate does not seem to work in anon fcns
plotMenu = uimenu('Parent',this.TreeManager.Figure,'Label','Plot', 'Tag', 'ts.Plot');
newPlotMenu = uimenu('Parent',plotMenu,'Label','New Plot', 'Tag', 'ts.NewPlot');
timePlotStr = xlate('Time Plots');
uimenu('Parent',newPlotMenu,'Label',xlate('Time Plot'), ...
    'Callback',@(es,ed) addPlot(this,timePlotStr), 'Tag', 'ts.TimePlot');
specPlotStr = xlate('Spectral Plots');
uimenu('Parent',newPlotMenu,'Label',xlate('Spectral Plot'), ...
    'Callback',@(es,ed) addPlot(this,specPlotStr), 'Tag', 'ts.SpectralPlot');
xyPlotStr = xlate('XY Plots');
uimenu('Parent',newPlotMenu,'Label',xlate('XY Plot'), ...
    'Callback',@(es,ed) addPlot(this,xyPlotStr), 'Tag', 'ts.XYPlot');
corrPlotStr = xlate('Correlations');
uimenu('Parent',newPlotMenu,'Label', ...
    xlate('Correlation Plot'),'Callback',@(es,ed) addPlot(this,corrPlotStr), 'Tag', 'ts.CorrelationPlot');
histPlotStr = xlate('Histograms');
uimenu('Parent',newPlotMenu,'Label', ...
    xlate('Histogram'),'Callback',@(es,ed) addPlot(this,histPlotStr), 'Tag', 'ts.Histogram');

%% Help menu
helpMenu = uimenu('Parent',this.TreeManager.Figure,'Label','Help');
uimenu('Parent',helpMenu,'Label','Time Series Help','Callback',...
    @localOpenHelp, 'Tag', 'ts.TimeSeriesHelp');
helpCSH = uimenu('Parent',helpMenu,'Label',xlate('Context-Sensitive Help'),...
    'Callback',{@localToggleCSH this},'Tag','CSHmenu','Checked','on','Separator',...
    'on');
uimenu('Parent',helpMenu,'Label','About MATLAB','Callback',...
    @(es,ed) helpmenufcn(this.TreeManager.Figure,'HelpAbout'),...
    'Separator','on'); 


%% Create the context sensitive help toolbar button
ic = fullfile(matlabroot,'toolbox','matlab','timeseries','help_context.gif'); %#ok<MCTBX,MCMLR>
tbbtnCSH = uitoggletool(htoolbar,'Tooltip','DispContextHelp',...
    'Tag','DispContextHelp','CData',localGetIcon(ic,99),'Tag','CSHtool');
set(tbbtnCSH,'State','on','OnCallback',...
    @(es,ed) set(get(this,'TreeManager'),'HelpShowing','on'),...
    'offcallback', @(es,ed) set(get(this,'TreeManager'),'HelpShowing','off'),...
    'TooltipString','Show/hide context sensitive help');
this.Listeners = [this.Listeners;...
     handle.listener(this.TreeManager,this.TreeManager.findprop('HelpShowing'),...
     'PropertyPostSet',{@localCSHListenerCallback this})];
%line styles ..
uimenu('Parent',plotMenu,'Label','Set Line Properties...',...
    'Callback',{@localLineStyle this});

%====
%% Exclude undo/redo who's enabled status is set by listeners to the 
%% @recorder object
this.TreeManager.Menus = [fileMenu; copyMenu; deleteMenu;...
    plotMenu; dataMenu;mergeMenu; exportMenu; ...
    selectionMenu; shiftMenu; matlabMenu; statsMenu; helpCSH];
this.TreeManager.ToolbarButtons = [copyTB;tbbtnCSH];
%====

%--------------------------------------------------------------------------
function localAddTS(~,~,h)

h.TSnode.createChild;

%--------------------------------------------------------------------------
function localAddSimTS(~,~,h)

h.SimulinkTSnode.createChild;

%--------------------------------------------------------------------------
function localLineStyle(~,~,this)
%

if isempty(this.StyleDlg) || ~ishghandle(this.StyleDlg)
   % Create style dialog
   this.StyleDlg = styledlg(this);
   this.Listeners = [this.Listeners; ...
        handle.listener(this,'ObjectBeingDestroyed',...
        {@localCloseStyleDlg this})];
else
   % Bring it up front
   set(this.StyleDlg,'Visible','on');
end

%--------------------------------------------------------------------------
function localCopy(~,~,this)

%% Copy the currently selected node to the @tsviewer clipboard if it is a
%% @tsnode or a @viewnode
selectednode = this.Treemanager.getselectednode;
if isa(selectednode,'tsguis.tsnode') || isa(selectednode,'tsguis.viewnode') ||...
        isa(selectednode,'tsguis.tscollectionNode')
     this.Clipboard = selectednode;
end

%--------------------------------------------------------------------------
function localPaste(~,~,this,manager)

%% Paste the clipboard to the currently selected node in the @tsviewer
selectednode = this.Treemanager.getselectednode;
if ~isempty(selectednode)
    selectednode.paste(manager);
end

%--------------------------------------------------------------------------
function localDelete(~,~,this)

thisnode = this.TreeManager.getselectednode;
manager = this.TreeManager;

%% Only @viewnodes and @tsnodes can be deleted
if isa(thisnode,'tsguis.viewnode') && ~isempty(thisnode.up)
    % Select the root so the deleted node is not selected
    this.TreeManager.reset
    this.TreeManager.Tree.setSelectedNode(thisnode.getRoot.down.getTreeNodeInterface);
    drawnow % Force the node to show seelcted
    this.TreeManager.Tree.repaint
    thisnode.up.removeNode(thisnode)
    return
end

% check if the member being removed belongs to a collection (no need to
% check if it is a time series, since it must be for the test below to pass)
if strcmp(class(thisnode.up),'tsguis.tscollectionNode')
    % timeseries chosen for deletion belongs to a tscollection
    manager.reset
    manager.Tree.setSelectedNode(thisnode.up.getTreeNodeInterface);
    drawnow % Force the node to show seelcted
    manager.Tree.repaint
    %Record the remove-ts transaction
    T = tsguis.nodetransaction;
    recorder = tsguis.recorder;
    T.ObjectsCell = {thisnode.Timeseries};
    T.Action = 'removed';
    T.ParentNodeHandle = thisnode.up;

    thisnode.up.Tscollection.removets(thisnode.Timeseries.Name);

    if strcmp(recorder.Recording,'on')
        T.addbuffer(xlate('%% Delete Tscollection Member'));
        T.addbuffer([thisnode.up.Tscollection.Name,' = removets(',thisnode.up.Tscollection.Name,', ',thisnode.Timeseries.Name,');'],thisnode.up.Tscollection);
    end

    %% Store transaction
    T.commit;
    recorder.pushundo(T);

    return
end

if (strcmp(class(thisnode),'tsguis.tsnode') && ~isempty(thisnode.up)) ||...
        strcmp(class(thisnode.up),'tsguis.simulinkTsParentNode')
    remove(thisnode,manager);
end



%--------------------------------------------------------------------------
function localTimeShift(~,~,this)

%% Time shift menu callback to open the time shift dialog

%% Get the current node
thisnode = this.TreeManager.getselectednode;

%% Try calling the openshift on it
if ~isempty(thisnode)
    try
        thisnode.openshiftdlg(this.Treemanager)
    catch %#ok<CTCH>
        msg = sprintf('The Synchronize Time Series dialog is not available for: %s',...
            thisnode.Label);
        errordlg(msg,'Time Series Tools','modal')
        return    
    end
end

%--------------------------------------------------------------------------
function localDataSelect(~,~,this)

%% Data select menu callback to open the date select dialog

%% Get the current node
thisnode = this.TreeManager.getselectednode;

%% Try calling the openselectdlg on it
if ~isempty(thisnode)
    try
        thisnode.openselectdlg(this.Treemanager)
    catch         %#ok<CTCH>
        msg = sprintf('The Select Data dialog is not available for: %s',...
            thisnode.Label);
        errordlg(msg,'Time Series Tools','modal')
        return    
    end
end

%-------------------------------------------------------------------------
function localMerge(~,~,this)

%% Merge menu callback to open the merge dialog

%% Get the current node
thisnode = this.TreeManager.getselectednode;

%% Try calling the openselectdlg on it
if ~isempty(thisnode)
    try
        tsguis.datamergedlg(thisnode);
    catch %#ok<CTCH>
        msg = sprintf('The Resample dialog is not available for: %s',...
            thisnode.Label);
        errordlg(msg,'Time Series Tools','modal')
        return        
    end
end

%--------------------------------------------------------------------------
function localPreproc(eventSrc,~,this)

%% Preprocessing callback to open the preproc dialog

tag = get(eventSrc,'Tag');
switch tag
    case 'ts.remove'
        Ind = 4;
    case 'ts.detrend'
        Ind = 1;
    case 'ts.filter'
        Ind = 2;
    case 'ts.interp'
        Ind = 3;
    otherwise
        Ind = 1;
end

%% Get the current node
thisnode = this.TreeManager.getselectednode;

%% Try calling the openselectdlg on it
if ~isempty(thisnode)
    try
        if isa(thisnode,'tsguis.viewnode')
            RS = tsguis.preprocdlg(thisnode);
        else
            RS = tsguis.datapreprocdlg(thisnode);
        end
        set(RS.Handles.TABGRPpreproc,'SelectedIndex',Ind);
    catch %#ok<CTCH>
        msg = sprintf('The Process Data dialog is not available for: %s',...
            thisnode.Label);
        errordlg(msg,'Time Series Tools','modal')
        return
    end
end

%--------------------------------------------------------------------------
function localArith(~,~,this)

%% MATLAB expression callback to open the arithmetic dialog

%% Get the current node
thisnode = this.TreeManager.getselectednode;

%% Try calling the openarithdlg on it
if ~isempty(thisnode)
    try
        thisnode.openarithdlg(this.TreeManager)
    catch %#ok<CTCH>
        msg = sprintf('The Transform Algebraically dialog is not available for: %s',...
            thisnode.Label);
        errordlg(msg,'Time Series Tools','modal')
        return
    end
end


% -----------------------------------------------------------------------
% for importing
% -----------------------------------------------------------------------
function localImport(~,~,this,varargin)

importWizard = tsguis.ImportWizard(this);
if nargin>=4
    importOptions = get(importWizard.Handles.COMBsource,'String');
    ind = find(strcmp(importOptions,varargin{1})); 
    if ~isempty(ind)
       cb = get(importWizard.Handles.COMBsource,'Callback');
       set(importWizard.Handles.COMBsource,'Value',ind(1));
       feval(cb{1},[],[],cb{2:end});
    end
end


% -----------------------------------------------------------------------
% for exporting
% -----------------------------------------------------------------------
function localFileExport(~,~,this)

% Open export for selected time series node
node = this.TreeManager.getselectednode;
if isa(node,'tsguis.tsparentnode')
    node.exportSelectedObjects(2,this.TreeManager);
else  
    dlg = tsguis.allExportdlg;
    dlg.initialize('file',this.TreeManager.Figure,{node});
end

%--------------------------------------------------------------------------
function localWorkspaceExport(~,~,this)
%% export this timeseries object to workspace
node = this.TreeManager.getselectednode;
% note: don't change the order, since tsguis.simulinkTsNode is a child of tsguis.tsnode
if isa(node,'tsguis.tsnode') || isa(node,'tsguis.tscollectionNode') || ...
        isa(node,'tsguis.modelDataLogsNode')
    list = evalin('base','whos;');
    flag = false;
    if isa(node,'tsguis.tsnode')
        newName = genvarname(node.Timeseries.Name);
    elseif isa(node,'tsguis.tscollectionNode')
        newName = genvarname(node.Tscollection.Name);
    elseif isa(node,'tsguis.modelDataLogsNode')
        newName = genvarname(node.SimModelHandle.Name);
    end
    for i=1:length(list)
        if strcmp(list(i).name,newName)
            flag = true;
            break;
        end
    end
    if (isa(node,'tsguis.tsnode') && ~strcmp(node.Timeseries.name,newName)) || ...
            (isa(node,'tsguis.tscollectionNode') && ~strcmp(node.Tscollection.name,newName)) || ...
            (isa(node,'tsguis.modelDataLogsNode') && ~strcmp(node.SimModelHandle.Name,newName))
        warning('tstool:InvalidObjectName',...
            '%s %s','The time series object name is invalid.',...
            'Attempting to replace it by a variable named ',['''',newName,''''],'.');
    end
    if flag
        if isa(node,'tsguis.tsnode')
            ButtonName = questdlg(xlate('A variable with the same name as the timeseries object already exists in the workspace.  Do you want to overwrite the existing variable or abort this operation?'),...
                'Duplicated Variable Detected','Overwrite','Abort','Overwrite');
        elseif isa(node,'tsguis.tscollectionNode')
            ButtonName = questdlg(xlate('A variable with the same name as the tscollection object already exists in the workspace.  Do you want to overwrite the existing variable or abort this operation?'),...
                'Duplicated Variable Detected','Overwrite','Abort','Overwrite');
        elseif isa(node,'tsguis.modelDataLogsNode')
            ButtonName = questdlg(xlate('A variable with the same name as this object already exists in the workspace.  Do you want to overwrite the existing variable or abort this operation?'),...
                'Duplicated Variable Detected','Overwrite','Abort','Overwrite');            
        end
        ButtonName = xlate(ButtonName);
        switch ButtonName,
            case xlate('Overwrite')
                if isa(node,'tsguis.tsnode') 
                    assignin('base',newName,node.Timeseries.TsValue);
                elseif isa(node,'tsguis.tscollectionNode')
                    assignin('base',newName,node.Tscollection.TsValue);
                elseif isa(node,'tsguis.modelDataLogsNode')
                    assignin('base',newName,node.SimModelhandle.copy);
                end
            case xlate('Abort')
                return
        end
    else
        if isa(node,'tsguis.simulinkTsNode')
            assignin('base',newName,node.Timeseries.copy);
        elseif isa(node,'tsguis.tsnode')
            assignin('base',newName,node.Timeseries.TsValue);
        elseif isa(node,'tsguis.tscollectionNode')
            assignin('base',newName,node.Tscollection.TsValue);
        elseif isa(node,'tsguis.modelDataLogsNode')
            assignin('base',newName,node.SimModelhandle.copy);
        end
        msgbox(sprintf('Object ''%s'' was exported to the base workspace.',newName),'Time Series Tools','modal');
    end
elseif isa(node,'tsguis.tsparentnode')
    node.exportSelectedObjects(3,this.TreeManager);
else
    return
end

%--------------------------------------------------------------------------
function localOpenStats(~,~,h,manager)

dlg = tsguis.statsdlg(h,manager);
dlg.Visible = 'on';

%--------------------------------------------------------------------------
function setUndoStatus(~,~,undoMenu,undoTB,r)

%% Recorder Undo stack listener callback
if isempty(r.Undo)
    set(undoMenu,'Enable','off')
    set(undoTB,'Enable','off')
else
    set(undoMenu,'Enable','on')
    set(undoTB,'Enable','on')
end

%--------------------------------------------------------------------------
function setRedoStatus(~,~,redoMenu,redoTB,r)

%% Recorder Redo stack listener callback
if isempty(r.Redo)
    set(redoMenu,'Enable','off')
    set(redoTB,'Enable','off')
else
    set(redoMenu,'Enable','on')
    set(redoTB,'Enable','on')
end

%--------------------------------------------------------------------------
function localClipBoardUpdate(~,~,this,pasteMenu,pasteTB)

%% Callback to clipboard listener
if ~isempty(this.Clipboard) && ...
        isa(this.Clipboard,class(this.TreeManager.getselectednode))
    set(pasteMenu,'Enable','on')
    set(pasteTB,'Enable','on')
else
    set(pasteMenu,'Enable','off')
    set(pasteTB,'Enable','off')
end
        
%--------------------------------------------------------------------------
function cdata = localGetIcon(thispath,I)

%% Get the icon for the data selection toolbar button
[cdata,map] = imread(thispath);

% Set all white (1,1,1) colors to be transparent (nan)
ind = (map(:,1)+map(:,2)+map(:,3)==3);
map(ind,:) = nan;
if nargin>1
    % required by some icons, where the last non-blck color takes over all
    % the trailing black values in the map
    map(I,:) = nan;
end
cdata = ind2rgb(cdata,map);

%--------------------------------------------------------------------------
function localUndo(es,ed) %#ok<INUSD>

r = tsguis.recorder;
undo(r);

%--------------------------------------------------------------------------
function localRedo(es,ed) %#ok<INUSD>

r = tsguis.recorder;
redo(r);

function localCloseStyleDlg(~,~,this)

if ~isempty(this.StyleDlg) && ishghandle(this.StyleDlg)
    delete(this.StyleDlg);
end

function localOpenHelp(es,ed) %#ok<INUSD>

mapfile = fullfile(docroot,'techdoc','data_analysis','data_analysis.map');
helpview(mapfile,'tsgui_help');

function localToggleCSH(~,~,h)

%% Toggle the state of the CSH panel
if strcmp(h.TreeManager.HelpShowing,'off')    
    h.TreeManager.HelpShowing = 'on';
else
    h.TreeManager.HelpShowing = 'off';
end

function localCSHListenerCallback(~,~,h)

%% Listener callback for changes in the HelopShowing property of the
%% TreeManager
m = findobj(h.TreeManager.Menus,'Tag','CSHmenu');
if ~isempty(m)
    set(m,'Checked',get(h.TreeManager,'HelpShowing'));
end
tb = findobj(h.TreeManager.ToolbarButtons,'Tag','CSHtool');
if ~isempty(tb)
    set(tb,'State',get(h.TreeManager,'HelpShowing'));
end