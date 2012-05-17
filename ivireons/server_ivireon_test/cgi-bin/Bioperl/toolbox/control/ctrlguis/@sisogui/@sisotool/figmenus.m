function Menus = figmenus(sisodb)
%FIGMENUS  Add the SISO Tool figure menus.
%
%   See also SISOTOOL.

%   Karen D. Gondoly and P. Gahinet
%   Revised : Kamesh Subbarao 11-07-2001
%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.53.4.16 $  $Date: 2009/04/21 03:08:31 $

% Main figure
SISOfig = sisodb.Figure;
LoopData = sisodb.LoopData;

% File menu
FileMenu.Top = uimenu('Parent',SISOfig,'Label',xlate('&File'),...
    'HandleVis','off', 'Tag','File');
FileMenu.Import = uimenu('Parent',FileMenu.Top,...
   'Label',xlate('&Import...'),...
   'Tag', 'Import', ...
   'Callback',{@LocalImport sisodb});
uimenu('Parent',FileMenu.Top,'Enable','off',...
   'Label',xlate('&Export...'), ...
   'Tag', 'Export', ...
   'Callback',{@LocalExport sisodb});  

uimenu('Parent',FileMenu.Top,'Enable','off',...
   'Label',xlate('&Save Session...'), ...
   'Tag', 'SaveSession', ...
   'Separator','on', ...
   'Callback',{@LocalSave sisodb});  
uimenu('Parent',FileMenu.Top,...
   'Label',xlate('&Load Session...'), ...
   'Tag', 'LoadSession', ...
   'Callback',{@LocalLoad sisodb});  

uimenu('Parent',FileMenu.Top,...
   'Label',xlate('&Toolbox Preferences...'), ...
   'Tag', 'ToolboxPreferences', ...
   'Separator','on', ...
   'Callback','ctrlpref');

uimenu('Parent',FileMenu.Top, ...
   'Label',xlate('&Print...'),...
   'Tag', 'Print', ...
   'Callback',{@LocalPrint sisodb 'print'}, ...
   'Separator','on', ...
   'Accelerator','P');
uimenu('Parent',FileMenu.Top, ...
   'Label',xlate('Print to &Figure'),...
   'Tag', 'PrintToFigure', ...
   'Callback',{@LocalPrint sisodb 'print2fig'});

uimenu('Parent',FileMenu.Top, ...
   'Callback',{@LocalClose sisodb},... 
   'Separator','on', ...
   'Label',xlate('&Close'), ...
   'Tag', 'Close', ...
   'Accelerator','W');

% Edit menu
EditMenu.Top = uimenu('Parent',SISOfig,'Label',xlate('&Edit'), ...
    'Tag', 'Edit', 'HandleVis','off');
EditMenu.Undo = uimenu('Parent',EditMenu.Top,...
		       'Label',xlate('&Undo'),'Enable','off', ...
               'Tag', 'Undo', ...
		       'Accelerator','Z',...
		       'Callback',{@LocalUndo sisodb});  
EditMenu.Redo = uimenu('Parent',EditMenu.Top,...
		       'Label',xlate('&Redo'), 'Enable','off', ...
               'Tag', 'Redo', ...
		       'Accelerator','Y',...
		       'Callback',{@LocalRedo sisodb});
% Install listener for enable state
Recorder = sisodb.EventManager.EventRecorder;
set(EditMenu.Undo,'UserData',...
   handle.listener(Recorder,findprop(Recorder,'Undo'),...
   'PropertyPostSet',{@LocalDoMenu EditMenu.Undo 1}));
set(EditMenu.Redo,'UserData',...
   handle.listener(Recorder,findprop(Recorder,'Redo'),...
   'PropertyPostSet',{@LocalDoMenu EditMenu.Redo 0}));

uimenu('Parent',EditMenu.Top, ...
   'Separator','on', ...
   'Label',xlate('&Tuned Parameters...'),...
   'Tag', 'TunedParameters', ...
   'CallBack',{@LocalFormatComp sisodb});
uimenu('Parent',EditMenu.Top , ...
   'Callback',{@LocalEditPref sisodb}, ...
   'Label',xlate('SISO Tool &Preferences...'),...
   'Tag', 'SISOToolPreferences');

% View menus
% RE: Includes all plots that can be viewed within main window
ViewMenu.Top = uimenu('Parent',SISOfig,'Label',xlate('&View'), ...
    'Tag', 'View', 'HandleVis','off');
% Design Plot Configuration
uimenu('Parent', ViewMenu.Top, 'Enable','off', ...
   'Label', xlate('Design &Plots Configuration...'), ...
   'Tag', 'DesignPlotsConfiguration', ...
   'Callback', {@LocalConfigDesignPlots sisodb});
% Other menus
CLPoleMenu = uimenu('Parent', ViewMenu.Top, 'Enable','off', ...
   'Separator','on',...
   'Label', xlate('&Closed-Loop Poles...'), ...
   'Tag', 'ClosedLoopPoles', ...
   'Callback', {@LocalDataView sisodb 'Dynamics'});
set(CLPoleMenu,'UserData',...
   handle.listener(LoopData,'ConfigChanged',{@LocalUpdateCLPoleMenu sisodb CLPoleMenu}))

uimenu('Parent',ViewMenu.Top, ...
   'Label',xlate('&Design History...'),'Enable','off',...
   'Tag', 'DesignHistory', ...
   'Callback',{@LocalDataView sisodb 'History'});

% Designs menu
CompMenu.Top = uimenu('Parent',SISOfig,'Label',xlate('&Designs'), ...
    'Tag', 'Designs', 'HandleVis','off');
CompEdit = uimenu('Parent',CompMenu.Top, ...
    'Label',xlate('&Edit Compensator...'),'Enable','off', ...  
    'Tag', 'EditCompensator', ...
    'CallBack',{@LocalEditComp sisodb 1});
ClearMenu = uimenu('Parent',CompMenu.Top, ...
   'Label',xlate('&Clear'),'Enable','off', ...
   'Tag', 'Clear');
uimenu('Parent',ClearMenu, ...
   'Label',xlate('All Compensators'), ...
   'Tag', 'AllCompensators', ...
   'CallBack',{@LocalClearComp sisodb 0});
set(ClearMenu,'UserData',...
   handle.listener(LoopData,'ConfigChanged',{@LocalEditClearMenu sisodb CompEdit ClearMenu}))

uimenu('Parent',CompMenu.Top, ...
   'Separator','on', ...
   'Label',xlate('&Store/Retrieve...'),'Enable','off',...
   'Tag', 'StoreRetrieve', ...
   'CallBack',{@LocalStoreRetrieveDesign sisodb});
% uimenu('Parent',CompMenu.Top, ...
%    'Label',xlate('&Take Snapshot'),'Enable','off')
% uimenu('Parent',CompMenu.Top, ...
%    'Label',xlate('Clear Snapshots'),'Enable','off')


% Analysis menu
AnaMenu.Top = uimenu('Parent',SISOfig,'Label',xlate('&Analysis'), ...
    'Tag', 'Analysis', 'HandleVis','off');
% 1. Predefined responses
if sisodb.LoopData.getconfig > 0
    %Do not display these menus for SCD case
    hPlot = zeros(5,1);
    hPlot(1) = uimenu('Parent',AnaMenu.Top, ...
        'Label',xlate('Response to Step Command'), ...
        'Tag', 'ResponseToStepCommand', ...
        'Enable','off');
    hPlot(2) = uimenu('Parent',AnaMenu.Top, ...
        'Label',xlate('Rejection of Step Disturbance'), ...
        'Tag', 'RejectionOfStepDisturbance', ...
        'Enable','off');
    hPlot(3) = uimenu('Parent',AnaMenu.Top, ...
        'Label',xlate('Closed-Loop Bode'), ...
        'Tag', 'ClosedLoopBode', ...
        'Enable','off');
    hPlot(4) = uimenu('Parent',AnaMenu.Top,...
        'Label',xlate('Compensator Bode'), ...
        'Tag', 'CompensatorBode', ...
        'Enable','off');
    hPlot(5) = uimenu('Parent',AnaMenu.Top, ...
        'Label',xlate('Open-Loop Nyquist'), ...
        'Tag', 'OpenLoopNyquist', ...
        'Enable','off');
    PlotContents = struct(...
        'PlotType',{'step';'step';'bode';'bode';'nyquist'},...
        'VisibleModels',{[1 2];[3 4];1;7;6});
else 
    hPlot = [];
end
AnaMenu.PlotSelection = hPlot;

% 2. Custom response setup
hc = uimenu('Parent',AnaMenu.Top,...
    'Separator','on','Label',xlate('Other Loop Responses...'),...
    'Tag', 'OtherLoopResponses', ...
    'Enable','off','CallBack',{@LocalSetupResp sisodb hPlot});

if sisodb.LoopData.getconfig > 0
    set(hPlot,'CallBack',{@LocalShowResp sisodb PlotContents hPlot})
end

% Tools menu
ToolMenu.Top= uimenu('Parent',SISOfig,'Label',xlate('&Tools'),'HandleVis','off');
% 1. Conversions
C2DMenu = uimenu('Parent',ToolMenu.Top, ...
    'Label',xlate('Continuous/Discrete &Conversions...'), ...
    'Tag', 'ContinuousDiscreteConversions', ...
    'Enable','off', ...
    'CallBack',{@LocalDiscretize sisodb});
set(C2DMenu,'UserData',...
   handle.listener(LoopData,'ConfigChanged',{@LocalUpdateC2DMenu sisodb C2DMenu}))

% 2. Draw Simulink diagram
if license('test', 'SIMULINK') && ~isequal(sisodb.LoopData.getconfig,0)
    uimenu('Parent',ToolMenu.Top, ...
        'Enable','off',...
        'Label',xlate('Draw &Simulink Diagram...'), ...
        'Tag', 'DrawSimulinkDiagram', ...
        'Callback',{@LocalDraw LoopData});
end
% 3. Automated Tuning
uimenu('Parent',ToolMenu.Top, ...
        'Enable','off',...
        'Label',xlate('&Automated Tuning...'), ...
        'Tag', 'AutomatedTuning', ...
        'Callback',{@LocalAutomatedTuning sisodb});


% Window menu
WindowMenu.Top = uimenu(SISOfig, 'Label', xlate('&Window'), ...
    'HandleVis','off', ...
    'Tag', 'Window', ...
    'Callback', winmenu('callback'), 'Tag', 'winmenu');
winmenu(double(SISOfig));  % Initialize the submenu

% Help menu
HelpMenu.Top = uimenu('Parent',SISOfig,'Label',sprintf('&Help'),'HandleVis','off');
uimenu('Parent',HelpMenu.Top, ...
   'Label',sprintf('SISO Design Tool &Help'), ...
   'Tag', 'SISODesignToolHelp', ...
   'Callback','ctrlguihelp(''sisotoolmainhelp'');');
uimenu('Parent',HelpMenu.Top, ...
   'Label',sprintf('Control System &Toolbox Help'), ...
   'Tag', 'ControlSystemToolboxHelp', ...
   'Callback','doc(''control/'');');
uimenu('Parent',HelpMenu.Top, ...
   'Label',sprintf('&What''s This?'), ...
   'Tag', 'WhatsThis', ...
   'Separator','on',...
   'CallBack',{@LocalWhatsThis sisodb});
uimenu('Parent',HelpMenu.Top, ...
   'Label',sprintf('&Importing/Exporting Models'), ...
   'Tag', 'ImportingExportingModels', ...
   'Separator','on',...
   'CallBack','ctrlguihelp(''sisoimportexport'');');
uimenu('Parent',HelpMenu.Top, ...
   'Label',sprintf('Tuning &Compensators'), ...
   'Tag', 'TuningCompensators', ...
   'CallBack','ctrlguihelp(''sisocompdesign'');');
uimenu('Parent',HelpMenu.Top, ...
   'Label',sprintf('Viewing Loop &Responses'), ...
   'Tag', 'ViewingLoopResponses', ...
   'Callback','ctrlguihelp(''sisoloopresponses'');');
uimenu('Parent',HelpMenu.Top, ...
   'Label',sprintf('&Viewing System Data'), ...
   'Tag', 'ViewingSystemData', ...
   'Callback','ctrlguihelp(''sisomodeldata'');');
uimenu('Parent',HelpMenu.Top, ...
   'Label',sprintf('&Storing/Retrieving Designs'), ...
   'Tag', 'StoringRetrievingDesigns', ...
   'Callback','ctrlguihelp(''sisosavecomp'');');
uimenu('Parent',HelpMenu.Top, ...
   'Label',sprintf('C&ustomizing the SISO Tool'), ...
   'Tag', 'CustomizingTheSISOTool', ...
   'Callback','ctrlguihelp(''sisocustomizing'');');
uimenu('Parent',HelpMenu.Top, ...
   'Label',sprintf('&Demos'), ...
   'Tag', 'Demos', ...
   'Separator','on',...
   'CallBack','demo toolbox control');
uimenu('Parent',HelpMenu.Top, ...
   'Label',sprintf('&About Control System Toolbox'), ...
   'Tag', 'AboutControlSystemToolbox', ...
   'Separator','on',...
   'CallBack','aboutcst');

Menus = struct(...
    'File',FileMenu,...
    'Edit',EditMenu,...
    'View',ViewMenu,...
    'Compensator',CompMenu,...
    'Analysis',AnaMenu,...
    'Tools',ToolMenu,...
    'Window',WindowMenu,...
    'Help',HelpMenu);

%-------------------------Local Functions-------------------------

%%%%%%%%%%%%%%%%%%%
%%% LocalImport %%%
%%%%%%%%%%%%%%%%%%%
function LocalImport(hSrc,event,sisodb)

 % store the last warning thrown 
[ lastWarnMsg lastWarnId ] = lastwarn; 
oldstate = warning('off','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame'); 
jf = get(sisodb.Figure, 'JavaFrame');
if ~isempty(jf)
    jframe = javax.swing.SwingUtilities.getWindowAncestor(jf.getAxisComponent);
else
    jframe = [];
end
warning(oldstate.state,'MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame'); 
 % restore the last warning thrown 
lastwarn(lastWarnMsg, lastWarnId); 

% opens import dialog
h = sisogui.ImportDialog(sisodb,jframe);
h.show;


%%%%%%%%%%%%%%%%%%%
%%% LocalExport %%%
%%%%%%%%%%%%%%%%%%%
function LocalExport(hSrc,event,sisodb)
% Opens export dialog
sisodb.DesignTask.showExportDialog;


%%%%%%%%%%%%%%%%%
%%% LocalSave %%%
%%%%%%%%%%%%%%%%%
function LocalSave(hSrc,event,sisodb)
% Save session to file

ProjectNode = sisodb.getNode.getRoot;

[projectframe,workspace,manager] = slctrlexplorer;
 manager.saveas(ProjectNode);


%%%%%%%%%%%%%%%%%
%%% LocalLoad %%%
%%%%%%%%%%%%%%%%%
function LocalLoad(hSrc,event,sisodb)
% Load session from file

% Query user for file name/location
[fname,p] = uigetfile('*.mat','Load Session');

% Save session data
if ischar(fname),
   [fname,r] = strtok(fname,'.');
   fullname = fullfile(p,[fname '.mat']);
   try
      sw = warning('off'); [lw,lwid] = lastwarn(''); %#ok<WNOFF>
      s = load(fullname,'SessionData');
      warning(sw); lastwarn(lw,lwid);
      load(sisodb,s.SessionData)
      % Update status bar and history
      Msg = sprintf('Loaded session from file %s.mat',fname);
      sisodb.EventManager.newstatus(Msg);
      sisodb.EventManager.recordtxt('history',Msg);
   catch
      warning(sw); lastwarn(lw,lwid);
      try
          explorer.loadProject(fullname)
      catch ME
      errordlg('Selected MAT file does not contain a valid SISO Tool session.',...
         'Load Error','modal')
      end
   end
end


%%%%%%%%%%%%%%%%%%
%%% LocalPrint %%%
%%%%%%%%%%%%%%%%%%
function LocalPrint(hSrcProp,event,sisodb,request)
% Print callback
sisodb.print(request);


%%%%%%%%%%%%%%%%%%
%%% LocalClose %%%
%%%%%%%%%%%%%%%%%%
function LocalClose(hSrc,event,sisodb)
% Close SISO Tool
delete(sisodb.Figure);


%%%%%%%%%%%%%%%%%
%%% LocalUndo %%%
%%%%%%%%%%%%%%%%%
function LocalUndo(hMenu,event,sisodb)
% Undo callback
StackLength = length(sisodb.EventManager.EventRecorder.Undo);
% Prevent undo if stack is less then desired length g229541
if StackLength > 1
    sisodb.EventManager.undo;
end

%%%%%%%%%%%%%%%%%
%%% LocalRedo %%%
%%%%%%%%%%%%%%%%%
function LocalRedo(hMenu,event,sisodb)
% Redo callback
StackLength = length(sisodb.EventManager.EventRecorder.Redo);
% Prevent redo if stack is less then desired length g229541
if StackLength > 0
   sisodb.EventManager.redo;
end


%%%%%%%%%%%%%%%%%%%
%%% LocalDoMenu %%%
%%%%%%%%%%%%%%%%%%%
function LocalDoMenu(hProp,event,hMenu,MinStackLength)
% Update menu state and label
Stack = event.NewValue;
if length(Stack)<=MinStackLength
    % Empty stack
    set(hMenu,'Enable','off','Label',sprintf('&%s',xlate(get(hProp,'Name'))))
else
    % Get last transaction's name
    ActionName = Stack(end).Name;
    Label = sprintf('&%s %s',xlate(get(hProp,'Name')),ActionName);
    set(hMenu,'Enable','on','Label',Label)
end


%%%%%%%%%%%%%%%%%%%%% 
%%% LocalEditPref %%% 
%%%%%%%%%%%%%%%%%%%%% 
function LocalEditPref(hSrc,event,sisodb) 
% Edit SISO Tool prefs 
edit(sisodb.Preferences); 


%%%%%%%%%%%%%%%%%%%%%
%%% LocalDataView %%%
%%%%%%%%%%%%%%%%%%%%%
function LocalDataView(hSrcProp,event,sisodb,ViewID)
% Launches System Data view
switch ViewID
   case 'History'
      View = histview(sisodb);
      % Bring it to front
      figure(View)
   case 'Dynamics'
      View = sisodb.DataViews.Dynamics;
      if isempty(View)
         View = clview(sisodb);
         sisodb.DataViews.Dynamics = View;
      else
         % Bring it to front
         View.setVisible(1);
         View.toFront;
      end
end


%%%%%%%%%%%%%%%%%%%%%
%%% LocalShowResp %%%
%%%%%%%%%%%%%%%%%%%%%
function LocalShowResp(hSrc,event,sisodb,PlotContents,hMenus)
% Show subset of predefined plots
MenuIndex = find(hSrc==hMenus);
ViewInfo = get(hSrc,'UserData');  % stores handle of view associated with menu
% Update menu state
if strcmp(get(hSrc,'Checked'),'on')
   % Unselecting menu
   % RE: Relies on listener to view visibility to uncheck menu
   sisodb.DesignTask.AnalysisPlotConfig.removeResponse(PlotContents(MenuIndex));
   set(hSrc,'Checked','off');
else
   % Selecting menu
   try
       % Add the response
       idx = sisodb.DesignTask.AnalysisPlotConfig.addResponse(PlotContents(MenuIndex));

       % Link it to the menu
       ViewerObj = sisodb.AnalysisView;
       ViewerObj.linkMenu(MenuIndex,ViewerObj.Views(idx));
       figure(double(sisodb.AnalysisView.Figure))
   catch ME
       errordlg(ltipack.utStripErrorHeader(ME.message),'SISO Tool Error','modal')
       return
   end
   set(hSrc,'Checked','on')
end
 



%%%%%%%%%%%%%%%%%%%%%%
%%% LocalSetupResp %%%
%%%%%%%%%%%%%%%%%%%%%%
function LocalSetupResp(hSrc,event,sisodb,hCheckMenus)
% Open response setup dialog
% hSrc = handle of Custom... menu (UserData contains dialog handle)

sisodb.DesignTask.show('AnalysisPlot');

% Unselect all check menus
if ~isempty(hCheckMenus)
    set(hCheckMenus,'Checked','off')
end

%%%%%%%%%%%%%%%%%%%%
%%% LocalConvert %%%
%%%%%%%%%%%%%%%%%%%%
function LocalDiscretize(hSrc,event,sisodb)
% Opens continuous/discrete conversion UI

%---Callback for the Convert to Discrete/Continuous menu 
% Check at most one model in system is dynamic
LoopData = sisodb.LoopData;

% static status for fixed models
booFixed = isstatic(LoopData.Plant);

% static status for tuned models
Tuned = LoopData.C;
numTuned = length(Tuned);
booTuned = false(numTuned,1);
for cnt = 1:numTuned
    booTuned = isStatic(Tuned(cnt));
end

boo = [booFixed; booTuned];
numstatic = sum(boo); % number of static components
numComponents = length(boo); % number of components

% If more than one dynamic model display warning
if numstatic < numComponents - 1
    WarnTxt = {'Continuous/discrete conversions are performed' ; ...
            'independently on each of the components.';...
            ' ';...
            'The resulting feedback loop may not accurately describe';...
            'your system when all components have dynamics.';...
            ' '};
    if strcmp(questdlg(WarnTxt,'Conversion Warning','OK','Cancel','Cancel'),'Cancel')
        return
    end
end

% Open conversion GUI (modal)
if isequal(LoopData.getconfig,0)
    % Add a drawnow to prevent thread lock between closing the question dialog 
    % and the creation of the options dialog which is an MJDialog.
    drawnow
    c2ddialog = jDialogs.ControlDesignOptionsDialog(sisodb);
else
    sisodb.c2dtool;
end



%%%%%%%%%%%%%%%%%
%%% LocalDraw %%%
%%%%%%%%%%%%%%%%%
function LocalDraw(hSrcProp,event,LoopData)
% Print callback
LoopData.drawdiagram;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% LocalResponseOptimization %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalAutomatedTuning(hSrcProp,event,sisodb)
% Callback to display automated tuning tab
sisodb.DesignTask.show('SROTuning');

%%%%%%%%%%%%%%%%%%%%%%%
%%% LocalFormatComp %%%
%%%%%%%%%%%%%%%%%%%%%%%
function LocalFormatComp(hSrc,event,sisodb)
% Callback for Compensator:Format menu
edit(sisodb.Preferences); 
selecttab(sisodb.Preferences,'Options');


%%%%%%%%%%%%%%%%%%%%%%
%%% LocalEditMenu %%%
%%%%%%%%%%%%%%%%%%%%%%
function LocalEditClearMenu(hSrc,event,sisodb,EditMenu,ClearMenu)
% Updates submenus
C = sisodb.LoopData.C;
nC = length(C);
ClearSubMenus = flipud(get(ClearMenu,'Children')); ClearSubMenus(1,:) = [];
if length(ClearSubMenus)<nC
   % Add submenus
   for ct=length(ClearSubMenus)+1:nC
        uimenu('Parent',ClearMenu,'CallBack',{@LocalClearComp sisodb ct});
   end
   ClearSubMenus = flipud(get(ClearMenu,'Children')); ClearSubMenus(1,:) = [];
end
% Adjust visibility and labels
for ct=1:nC
   set(ClearSubMenus(ct),'Label',C(ct).Identifier,'Visible','on')
end
for ct=nC+1:length(ClearSubMenus)
   set(ClearSubMenus(ct),'Visible','off')
end

%%%%%%%%%%%%%%%%%%%%%%
%%% LocalEditComp %%%
%%%%%%%%%%%%%%%%%%%%%%
function LocalEditComp(hSrc,event,sisodb,idxC)
% Callback for Edit menu
% Design plot configuration panel visible & bring to front
sisodb.DesignTask.show('PZEditor');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% LocalStoreRetrieveDesign %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalStoreRetrieveDesign(hSrc,event,sisodb)
% Adds and Retrieves current design to design history

% Revisit Create a method
[projectframe,workspace] = slctrlexplorer;
projectframe.setSelected(sisodb.getNode.getSnapshotFolder.getTreeNodeInterface);
projectframe.toFront;
projectframe.setVisible(true);

%%%%%%%%%%%%%%%%%%%%%%
%%% LocalClearComp %%%
%%%%%%%%%%%%%%%%%%%%%%
function LocalClearComp(hSrc,event,sisodb,ClearedModels)
% Callback for "clear compensator" event
sisodb.clearcomp(ClearedModels)  % idxC or 0 for all
    
%%%%%%%%%%%%%%%%%%%%%%
%%% LocalWhatsThis %%%
%%%%%%%%%%%%%%%%%%%%%%
function LocalWhatsThis(hSrc,event,sisodb)
% Callback for What's This menu item
HelpIcon = sisodb.HG.Toolbar(end);
set(HelpIcon,'State','on')



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% LocalConfigDesignPlots %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalConfigDesignPlots(hSrc,event,sisodb)

% Design plot configuration panel visible & bring to front
sisodb.DesignTask.show('DesignPlot');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% LocalUpdateCLPoleMenu %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalUpdateCLPoleMenu(hSrc,event,sisodb,MenuItem)
% Disable menu if plant is FRD or HasDelays
P = sisodb.LoopData.Plant.getP;
if isa(P,'ltipack.frddata') || hasdelay(P)
    set(MenuItem,'Enable','off');
else
    set(MenuItem,'Enable','on');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% LocalUpdateC2DMenu %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalUpdateC2DMenu(hSrc,event,sisodb,MenuItem)
% Disable menu if plant is FRD 
if isa(sisodb.LoopData.Plant.getP,'ltipack.frddata')
    set(MenuItem,'Enable','off');
else
    set(MenuItem,'Enable','on');
end


