function load(this,SavedSession,NoRecord)
%LOAD   Reloads SISO Tool session.

%   Author(s): P. Gahinet
%   Copyright 1986-2007 The MathWorks, Inc.
%   $Revision: 1.17.4.5 $  $Date: 2007/05/18 04:59:24 $
LoopData = this.LoopData;
Version = SavedSession.Version; % before it gets updated...

% Upgrade saved data from versions 1.0 and 2.0
if isstruct(SavedSession)
   SavedSession = LocalUpgrade(this,SavedSession);
end

% Register transaction
if nargin<3
   % Save current session
   CurrentSession = save(this);
   % RE: no recording during undo/redo
   T = ctrluis.ftransaction('Load Session');
   T.UndoFcn = {@load this CurrentSession 'norecord'};
   T.RedoFcn = {@load this SavedSession 'norecord'};
   this.EventManager.record(T);
end

% Hide editors and viewer plots (postpones all updating 
% until all settings are restored)
%% REVISIT
set(this.PlotEditors,'Visible','off');
Viewer = this.AnalysisView;
if ~isempty(Viewer) && ishandle(Viewer)
   set(Viewer.Views(ishandle(Viewer.Views)),'Visible','off')
end

% Temporary fix to work around uitool segv at this time g142004
%drawnow;

% Import session data
LoopData.importdesign(SavedSession.Designs(1))
LoopData.History = SavedSession.Designs(2:end,:);

% Restore session preferences
% RE: After data so that change in comp. Format preferences do not cause errors
this.Preferences.load(SavedSession.Preferences);

% Restore Editor settings and update plots
Editors = this.PlotEditors;
if isempty(Editors)
   Editors = handle(zeros(0,1)); % UDDREVISIT: [] trips up FIND
end
for ct=1:length(SavedSession.EditorSettings)
    Settings = SavedSession.EditorSettings{ct};
    if Settings.EditedLoop > 0 % skip loading editors that do not have a target(ie -1)
        ed = find(Editors,'-isa',Settings.Class);
        if isempty(ed)
            ed = this.addeditor(Settings.Class,Settings.EditedLoop); % visible=off
        else
            ed = ed(1);
            ed.EditedBlock = LoopData.C(Settings.EditedBlock);
            ed.GainTargetBlock = LoopData.C(Settings.GainTargetBlock);
        end
        % load settings
        ed.load(Settings,Version) % will turn visibility on where appropriate
        % Delete from list of currently visible editors
        Editors(Editors==ed) = [];
    end
end


if isfield(SavedSession.ViewerSettings,'ViewerData')
    ViewerData = SavedSession.ViewerSettings.ViewerData;
    ViewerContents = SavedSession.ViewerSettings.ViewerContents;
else
    ViewerData = [];
    ViewerContents = SavedSession.ViewerSettings;
end
 
% Restore LTI Viewer Data such as plots and constraints
if ~isempty(ViewerData)
    ViewerObj = viewgui.SisoToolViewer(this);
    this.AnalysisView = ViewerObj;

    for ct = 1:6;
        PlotCell = ViewerData(ct).PlotCell;
        for ct2 = 1:length(PlotCell)
            if ~isempty(PlotCell(ct2).PlotType)
                NewView = ViewerObj.addview(PlotCell(ct2).PlotType);
                NewView.loadconstr(PlotCell(ct2).Constraints);
                PlotCells = ViewerObj.PlotCells;
                PlotCells{ct} = [PlotCells{ct} ; NewView];
                ViewerObj.PlotCells = PlotCells;
            end
        end
    end
end

% Restore LTI Viewer settings
vc = ViewerContents;
setViewerContents(this,vc)
% Restore analysis menus state (check mark) 
Menus = this.HG.Menus.Analysis.PlotSelection;
Viewer = this.AnalysisView;
for ct=1:length(vc)
   if ~isempty(vc(ct).SelectedMenu)
      set(Menus(vc(ct).SelectedMenu),'Checked','on')
      Viewer.linkMenu(vc(ct).SelectedMenu,Viewer.Views(ct));
   end
end

% Restore history 
this.EventManager.sethistory(SavedSession.History);

%--------------------------- Local Functions ----------------------


% BACKWARD COMPATIBILITY FOR VERSIONS 1 and 2
function SessionObj = LocalUpgrade(this,SavedSession)
% Upgrade from previous versions
nviews = length(SavedSession.ViewerContent);
if SavedSession.Version<2
   % Upgrade to version 2.0
   % Added Input Disturbance and Output Disturbance entries to Analysis menu
   SavedSession.ResponseMenuState = ...
      [SavedSession.ResponseMenuState(1);{'off'};SavedSession.ResponseMenuState(3:5)];
   % New ViewerContent format
   if nviews>0
      vismod = cell(nviews,1);
      for ct=1:nviews
         vismod{ct} = [SavedSession.ViewerContent(ct).OpenLoop ; SavedSession.ViewerContent(ct).ClosedLoop];
      end
      SavedSession.ViewerContent = struct('PlotType',{SavedSession.ViewerContent.PlotType}',...
         'VisibleModels',vismod,'SelectedMenu',[]);
   end
end

if SavedSession.Version <= 2
    %Convert from RespList strings to indices
    RespList = {...
        '$T_r2y', '$T_r2u', '$S_input', '$S_output', '$S_noise', ...
        '$L', '$C', '$F', '$G', '$H'};

    if ~isempty(SavedSession.ViewerContent)
        for ct = length(SavedSession.ViewerContent):-1:1
            [vis,idx] = intersect(SavedSession.ViewerContent(ct).VisibleModels,RespList);
            NewViewerContent(ct) = struct('PlotType',SavedSession.ViewerContent(ct).PlotType, ...
                'VisibleModels',idx,'SelectedMenu',SavedSession.ViewerContent(ct).SelectedMenu);
        end
        SavedSession.ViewerContent = NewViewerContent;
    end
end

% Upgrade to @session object
SessionObj = sisogui.session;
SessionObj.Preferences = SavedSession.Preferences;
SessionObj.History = SavedSession.History;
% Editor settings
% RE: Actual conversion handled by editor's load method
s1 = SavedSession.RootLocusEditor;
s1.Class = 'sisogui.rleditor'; 
s1.EditedLoop = 1; s1.EditedBlock=1; s1.GainTargetBlock = 1;

s2 = SavedSession.OpenLoopBodeEditor; 
s2.Class = 'sisogui.bodeditorOL'; 
s2.EditedLoop = 1; s2.EditedBlock=1; s2.GainTargetBlock = 1;

s3 = SavedSession.NicholsEditor;
s3.Class = 'sisogui.nicholseditor'; 
s3.EditedLoop = 1; s3.EditedBlock=1; s3.GainTargetBlock =1;

s4 = SavedSession.PrefilterBodeEditor;
if isequal(SavedSession.LoopData.Configuration,4)
    s4.Class = 'sisogui.bodeditorOL';
    s4.MarginVisible = 'on';
else
    s4.Class = 'sisogui.bodeditorF'; 
end
s4.EditedLoop = 2; s4.EditedBlock=2; s4.GainTargetBlock = 2;

SessionObj.EditorSettings = {s1;s2;s3;s4};
% Design data
LoopData = SavedSession.LoopData;
Config = LoopData.Configuration;
D = LocalUpgradeData(LoopData,Config);
for ct=1:length(LoopData.SavedDesigns)
   D(ct+1,1) = LocalUpgradeData(LoopData.SavedDesigns(ct),Config);
end
SessionObj.Designs = D;
% Viewer data
SessionObj.ViewerSettings = SavedSession.ViewerContent;

  

function Design = LocalUpgradeData(LoopData,Config)
% Upgrade design
Design = sisoinit(LoopData.Configuration);
if isfield(LoopData,'SystemName')
   Design.Name = LoopData.SystemName;
else
   Design.Name = LoopData.Name;
end
if Config<4
   Design.FeedbackSign = LoopData.FeedbackSign;
   Design.C.Name = LoopData.Compensator.Name;
   Design.C.Value = LoopData.Compensator.Model;
   Design.F.Name = LoopData.Filter.Name;
   Design.F.Value = LoopData.Filter.Model;
else
   Design.FeedbackSign = [LoopData.FeedbackSign,1];
   Design.C1.Name = LoopData.Compensator.Name;
   Design.C1.Value = LoopData.Compensator.Model;
   Design.C2.Name = LoopData.Filter.Name;
   Design.C2.Value = LoopData.Filter.Model;
end
Design.G.Name = LoopData.Plant.Name;
Design.G.Value = LoopData.Plant.Model;
Design.H.Name = LoopData.Sensor.Name;
Design.H.Value = LoopData.Sensor.Model;






