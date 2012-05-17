function varargout = sisotool(varargin)
%SISOTOOL  SISO Design Tool.
%
%   SISOTOOL opens the SISO Design Tool.  This Graphical User Interface
%   lets you design single-input/single-output (SISO) compensators by
%   graphically interacting with the root locus, Bode, and Nichols plots of  
%   the open-loop system.  To import the plant data into the SISO Tool,  
%   select the Import item from the File menu. By default, the control  
%   system configuration is
%
%             r -->[ F ]-->O--->[ C ]--->[ G ]----+---> y
%                        - |                      |
%                          +-------[ H ]----------+
%
%   where C and F are tunable compensators.
%
%   SISOTOOL(G) specifies the plant model G to be used in the SISO Tool.  
%   Here G is any linear model created with TF, ZPK, or SS.
%
%   SISOTOOL(G,C) and SISOTOOL(G,C,H,F) further specify values for the 
%   feedback compensator C, sensor H, and prefilter F.  By default, 
%   C, H, and F are all unit gains.
%
%   SISOTOOL(VIEWS) or SISOTOOL(VIEWS,G,...) specifies the initial set of
%   views for graphically editing C and F.  You can set VIEWS to any of the
%   following strings or combination of strings:
%       'rlocus'      Root locus plot
%       'bode'        Bode diagram of the open-loop response
%       'nichols'     Nichols plot of the open-loop response
%       'filter'      Bode diagram of the prefilter F
%   For example 
%       sisotool({'nichols','bode'})
%   opens a SISO Design Tool showing the Nichols plot and Bode diagrams
%   for the open loop CGH.
%
%   SISOTOOL(INITDATA) initializes the SISO Design Tool with more general 
%   control system configurations.  Use SISOINIT to build the initialization  
%   data structure INITDATA.
%
%   SISOTOOL(SESSIONDATA) opens the SISO Design Tool with a previously
%   saved session where SESSIONDATA is the MAT file for the saved session.
%
%   See also SISOINIT, LTIVIEW, RLOCUS, BODE, NICHOLS.

%   Author(s): Karen D. Gondoly, P. Gahinet
%   Copyright 1986-2010 The MathWorks, Inc.
%   $Revision: 1.81.4.19 $  $Date: 2010/05/10 16:58:08 $

% Obsolete Syntax:  extra argument OPTIONS (structure) to specify any
% of the following options:
%   OPTIONS.Location    Location of C ('forward' for forward path,
%                       'feedback' for return path)
%   OPTIONS.Sign        Feedback sign (-1 for negative, +1 for positive)
ni=nargin;
error(nargchk(0,6,ni))

% Parse inputs
DataProvided = false;
SessionProvided = false;
OldSessionProvided = false;
if ni==0
   % Open GUI w/o data
   InitData = sisoinit(1);  % default config
   DataProvided = true;
   %InitData.G = [];         % no data specified
elseif isequal(length(varargin),1) && isa(varargin{1},'char') ...
        && ~any(strcmpi(varargin{1},{'rlocus','bode','nichols','filter'}));
    try
        explorer.loadProject(varargin{1});
        return
    catch
        [fname,~] = strtok(varargin{1},'.');
        fullname = [fname '.mat'];
        sw = ctrlMsgUtils.SuspendWarnings; %#ok<NASGU>
        s = load(fullname,'SessionData');
        clear sw
        if isempty(fields(s))
            ctrlMsgUtils.error('Control:compDesignTask:SISOTool1')
        else
            OldSessionProvided = true;
            InitData = sisoinit(1);
            DataProvided = true;
        end
    end
elseif isa(varargin{1},'sisodata.design')
   % Open GUI with setup object
   InitData = varargin{1};
   DataProvided = true;
elseif isa(varargin{1},'sisogui.session')
   % Open GUI with session data
   SessionData = varargin{1};
   InitData = SessionData.Designs(1);
   SessionProvided = true;
else
   % Parse input list
   % a) Views
   LastInput = 0;
   ValidViews = {'rlocus','bode','nichols','filter'};
   if ni && (iscellstr(varargin{1}) || ischar(varargin{1}))
      DesignViews = varargin{1};
      if ~iscell(DesignViews)
         DesignViews = {DesignViews};
      end
      AllValid = all(ismember(DesignViews,ValidViews));
      if ~AllValid,
          ctrlMsgUtils.error('Control:compDesignTask:SISOTool2')
      end
      LastInput = LastInput + 1;
      UseDefaultDesignViews = false;
   else
      UseDefaultDesignViews = true;
      DesignViews = {'rlocus','bode'};
   end
   
   idxG = LastInput+1; % position of G argument
   if ni>=idxG
      % System name is inherited from G
      InitData.Name = inputname(idxG);
   end
   
   % Models G,C,H,F
   ModelID = {'G';'C';'H';'F'};
   Models = cell(4,1);
   ModelNames = ModelID; % strcat('untitled',ModelID);
   ModelVars = repmat({''},[4 1]);
   for ct=1:min(4,ni-LastInput),
      NextArg = varargin{LastInput+1};
      isModel = (isa(NextArg,'lti') || isa(NextArg,'idmodel')); % REVISIT: should be "system" parent class
      if ~isa(NextArg,'double') && ~isModel
         % done scanning model inputs
         break
      else
         if ~isequal(NextArg,[])  % skip []'s
            DataProvided = true;
            Models{ct} = NextArg;
            VarName = inputname(LastInput+1);
            % Model name
            if isa(NextArg,'lti') && ~isempty(NextArg.Name)
               ModelNames{ct} = NextArg.Name;
            end
            % Variable name
            ModelVars{ct} = VarName;
         end
      end
      LastInput = LastInput+1;
   end
   
   % Options (last arg)
   if ni>LastInput && isa(varargin{LastInput+1},'struct')
      Options = varargin{LastInput+1};
      LastInput = LastInput+1;
   else
      Options = [];
   end
   
   % There should be no more input argument
   if ni>LastInput,
      ctrlMsgUtils.error('Control:general:InvalidSyntaxForCommand','sisotool','sisotool')
   end
   
   % Read options
   if isfield(Options,'Location')
      LoopConfig = Options.Location;
      if ~isa(LoopConfig,'char')
          ctrlMsgUtils.error('Control:compDesignTask:SISOTool3')
      else
         switch lower(LoopConfig(1:min(2,end))),
            case 'fo',
               LoopConfig = 1;  % forward loop
            case 'fe',
               LoopConfig = 2;  % feedback loop
            otherwise,
                ctrlMsgUtils.error('Control:compDesignTask:SISOTool3')
         end 
      end
   else
      LoopConfig = 1;
   end
   
   if isfield(Options,'Sign') 
      Sign = Options.Sign;
      if ~ismember(Sign,[1,-1]),
          ctrlMsgUtils.error('Control:compDesignTask:SISOTool4')
      end 
   else
      Sign = -1;
   end
   
   % Build init structure
   InitData = sisoinit(LoopConfig);
   InitData.FeedbackSign = Sign;
   hasFRD = false;
   for ct=1:4
      id = ModelID{ct};
      InitData.(id).Name = ModelNames{ct};
      InitData.(id).Variable = ModelVars{ct};
      if ~isempty(Models{ct})
         InitData.(id).Value = Models{ct};
         if isa(Models{ct},'frd') || isa(Models{ct},'idfrd')
             hasFRD = true;
         end
      end
   end
   
   if UseDefaultDesignViews
       if hasFRD
           DesignViews = {'bode'};
       else
           DesignViews = {'rlocus','bode'};
      end
   end
   
   idxf = find(strcmp(DesignViews,'filter'));
   if isempty(idxf)
       InitData.CL1.View = cell(1,0);
   end
   DesignViews(idxf) = [];
   InitData.OL1.View = DesignViews;
end

% Compensator IDs
CompID = InitData.Tuned;
nC = length(CompID); % number of tuned components
LoopID = InitData.Loops;
nL = length(LoopID);

%
%---- CREATE DATABASE ---------------
%

% Create model database
LoopData = sisodata.loopdata;

% Initialize configuration
LoopData.setconfig(InitData)    % triggers config. rendering

% Validate model data before creating GUI (avoids pain of destroying it)
if DataProvided
   try
      InitData = checkdata(LoopData,InitData);
   catch ME
      throw(ME)
   end
end

% Create GUI database
sisodb = sisogui.sisotool;
sisodb.LoopData = LoopData;

% Show waitbar
hWaitbar = waitbar(0,'SISO Design GUI is loading. Please wait...');


%
%---- CREATE GUI ---------------
%

% Create figure
SISOfig = LocalOpenFig;
sisodb.Figure = handle(SISOfig);

% Create event manager
sisodb.EventManager = ctrluis.framemgr(SISOfig);
sisodb.EventManager.EventRecorder = ctrluis.recorder;

% Initialize preferences
waitbar(0.1,hWaitbar)
sisodb.Preferences = LocalInitPref(sisodb,SISOfig);
CompFormat = sisodb.Preferences.CompensatorFormat;
for ct=1:length(LoopData.C)
   LoopData.C(ct).Format = CompFormat;
end

% Render GUI frames, menus, and toolbar
addcontrols(sisodb)

% Install GUI-wide listeners
addlisteners(sisodb)

% Create text editors
waitbar(0.3, hWaitbar)
ted1 = sisogui.pzeditor(LoopData, sisodb);
ted2 = sisogui.tooldlg([]);
sisodb.TextEditors = [ted1;ted2];


%
%---- RENDER LOOP DATA ---------------
%


% Render loop parameters
if ~isempty(InitData.Name)
    LoopData.Name = InitData.Name;  % triggers fig name update
end

if SessionProvided
   % Start up with saved session
   % Make figure visible
   waitbar(0.5,hWaitbar)
   set(SISOfig,'Visible','on')
   % Load session data
   waitbar(0.7,hWaitbar)
   sisodb.load(SessionData,'norecord')
   % Empty start (no plant data)
   ImportStatus = 'Right-click on the plots for more design options.';
else
   waitbar(0.7,hWaitbar)
   if DataProvided,
      % Import model data if provided (RE: already validated, so no error here...)
      LoopData.importdata(InitData);
      LoopData.LoopView = InitData.getLoopView;
      % Force update of configuration-dependent views and menus
      % RE: once all names are correct
      LoopData.send('ConfigChanged')
      % Notify peers of data change
      LoopData.dataevent('all');
      % Push placeholder "first import" transaction onto stack
      T = ctrluis.transaction(LoopData);
      sisodb.EventManager.record(T);
      % Status message
      ImportStatus = 'Right-click on the plots for more design options.';
   else
      LoopData.importdata(InitData);
      LoopData.LoopView = InitData.getLoopView;
      % Force update of configuration-dependent views and menus
      LoopData.send('ConfigChanged')
      % Empty start (no plant data)
      ImportStatus = 'Use Import... off the File menu to import the plant data.';
   end
   % Make figure and graphical editors visible (maximum of 4)
   waitbar(0.9,hWaitbar)
 %  set(SISOfig,'Visible','on')
   if length(sisodb.PlotEditors)>6
       ctrlMsgUtils.warning('Control:compDesignTask:MaxEditors')
   end
 %  set(sisodb.PlotEditors(1:min(4,end)),'Visible','on');
end


% Create graphical design tools (editors)
% Revisit
if ~SessionProvided
   for idxL=1:nL
      [~,iu] = unique(InitData.(LoopID{idxL}).View);
      LoopViews = InitData.(LoopID{idxL}).View(sort(iu));
      if InitData.(LoopID{idxL}).getProperty('Feedback')
          % Create one editor per requested view
          for ct=1:length(LoopViews)
              switch LoopViews{ct}
                  case 'rlocus'
                      sisodb.addeditor('sisogui.rleditor',idxL);      % Root Locus Editor
                  case 'bode'
                      sisodb.addeditor('sisogui.bodeditorOL',idxL);
                  case 'nichols'
                      sisodb.addeditor('sisogui.nicholseditor',idxL);
              end
          end
      else
          % Filter component
          if any(strcmp(LoopViews,'rlocus') | strcmp(LoopViews,'nichols'))
              ctrlMsgUtils.warning('Control:compDesignTask:EditorRequiresOpenLoop')
          end
          if any(strcmp(LoopViews,'bode'))
              sisodb.addeditor('sisogui.bodeditorF',idxL);
              % Editors = [Editors ; sisogui.bodeditorF(LoopData,1)]; % Filter Bode editor
          end
      end
   end
   
   % Initialize plot editors
   waitbar(0.95,hWaitbar)
end


% --- Add to project explorer
% Create the project explorer
%% Get the frame and workspace handles
[projectframe,workspace,treemanager] = slctrlexplorer;


% Block explorer to prevent closing during a load
% and set treemanager as busy to prevent closing of gui
projectframe.setBlocked(true, []);
treemanager.setBusy(true);

% Make sure to reset state of projectframe and treemanager if error occurs
try
    % Get the default nodes
    sisotask = controlnodes.SISODesignTask(sprintf('SISO Design Task'),sisodb);
    sisotask.Label = sisotask.createDefaultName(sprintf('SISO Design Task'), workspace);
    sisodb.LoopData.Name = sisotask.Label;

    % Add the SISO Task node to the workspace
    workspace.addNode(sisotask);
    % Set the project dirty flag
    project.Dirty = 1;
    sisodb.setNode(sisotask);

    % Create DesignTask
    junk = getTaskPanel(sisodb);

    % Show Architecture Panel
    sisodb.DesignTask.show;
    sisodb.DesignTask.refreshTab;

    % Show CETM
    projectframe.toFront;
    projectframe.setVisible(true);

    % Show SISOTOOL
    set(SISOfig,'Visible','on')
    if isempty(sisodb.PlotEditors)
        % Call layout when no graph editors are present so status text is
        % not improperly rendered.
        sisodb.layout;
    else
        % Setting the editor visibility on calls the layout function
        set(sisodb.PlotEditors(1:min(6,end)),'Visible','on');
    end

    if OldSessionProvided
        try
            load(sisodb,s.SessionData,'norecord')
            % Update status bar and history
            Msg = sprintf('Loaded session from file %s.mat',fname);
            sisodb.EventManager.newstatus(Msg);
            sisodb.EventManager.recordtxt('history',Msg);
        catch
            errordlg('Selected MAT file does not contain a valid SISO Tool session.',...
                'Load Error','modal')
        end
    end



    %
    %---- COMPLETE INIT IN BACKGROUND
    %

    waitbar(1,hWaitbar)
    close(hWaitbar)

    % Store database handle, set figure callbacks, and make figure visible
    set(SISOfig,'UserData',sisodb,...
        'CloseRequestFcn',{@LocalCloseCB sisodb},...
        'DeleteFcn',{@LocalDeleteTask sisodb},...
        'ResizeFcn',{@LocalResize sisodb},...
        'KeyPressFcn',{@LocalKeyevent sisodb},...
        'WindowButtonMotionFcn',{@LocalMouseevent sisodb})

    % Initialize status and history
    sisodb.EventManager.newstatus(ImportStatus);
    sisodb.EventManager.recordtxt('history',...
        sprintf('%s: Starting SISO Tool for system: %s',date,sisodb.LoopData.Name));

    % Call the start-up message box
    LocalStartUpMsgBox(sisodb);

    % Return figure handle if requested
    if nargout,
        varargout{1} = SISOfig;
    end

    % Set dirty listeners for the project
    sisotask.setDirtyListener
    
    % Unblock explorer
    projectframe.setBlocked(false, []);
    treemanager.setBusy(false);
    
catch
    % Unblock explorer
    projectframe.setBlocked(false, []);
    treemanager.setBusy(false);
end

%-------------------------Internal Functions-------------------------
   

%%%%%%%%%%%%%%%%%%%%
%%% LocalOpenFig %%%
%%%%%%%%%%%%%%%%%%%%
function SISOfig = LocalOpenFig()

Color = get(0,'DefaultUIControlBackground');
SISOfig = figure(...
   'Color',Color,...
   'IntegerHandle','off', ...
   'DoubleBuffer','on', ...
   'MenuBar','none', ...
   'Name','SISO Design Tool', ...
   'NumberTitle','off', ...
   'Unit','character', ...
   'Visible','off', ...
   'Tag','SISODesignFig',...
   'DockControls','off'); 

% Colormap must be set after figure is created
% (for some reason this will open a new figure if handlevis=off)
pos = get(SISOfig,'Position') + [0 -7 0 7];
set(SISOfig,'Colormap',gray,'HandleVisibility','callback','Position',pos);

% Install CS help
ctrlcshelp(SISOfig);
mapfile = ctrlguihelp;
if ~isempty(mapfile)
   set(SISOfig,'HelpTopicMap',mapfile,'HelpFcn',@LocalHelpCB);
end


%%%%%%%%%%%%%%%%%%%%
%%% LocalResize %%%
%%%%%%%%%%%%%%%%%%%%
function LocalResize(hSrc,event,sisodb)
resize(sisodb);

%%%%%%%%%%%%%%%%%%%%
%%% LocalMouseevent %%%
%%%%%%%%%%%%%%%%%%%%
function LocalMouseevent(hSrc,event,sisodb)
% Only process mouse event if not in a scribemode.
ModeManager = uigetmodemanager(sisodb.Figure);
if isempty(ModeManager.CurrentMode)
    mouseevent(sisodb,'wbm');
end

%%%%%%%%%%%%%%%%%%%%
%%% LocalKeyevent %%%
%%%%%%%%%%%%%%%%%%%%
function LocalKeyevent(hSrc,event,sisodb)
keyevent(sisodb);

%%%%%%%%%%%%%%%%%%%%
%%% LocalCloseCB %%%
%%%%%%%%%%%%%%%%%%%%
function LocalCloseCB(hSrc,event,sisodb)
set(hSrc,'Visible','off')


%%%%%%%%%%%%%%%%%%%%
%%% LocalDeleteTask %%%
%%%%%%%%%%%%%%%%%%%%
function LocalDeleteTask(hSrc,event,sisodb)
% Remove delete Fcn callback on figure
SISOfig = sisodb.Figure;
set(SISOfig,'DeleteFcn','')

DesignTaskNode = sisodb.getNode;
delete(DesignTaskNode.Handles.sisodbDeleteListener);
% Delete the current node
parent = DesignTaskNode.up;

if ~isempty(parent)
    parent.removeNode(DesignTaskNode);
end


%%%%%%%%%%%%%%%%%%%%%
%%% LocalInitPref %%%
%%%%%%%%%%%%%%%%%%%%%
function Preferences = LocalInitPref(sisodb,SISOfig)
% Initializes preferences
Preferences = sisogui.sisoprefs(sisodb);

% Set default fonts
set(SISOfig,...
   'DefaultUIControlFontSize',Preferences.UIFontSize,...
   'DefaultAxesFontSize',Preferences.AxesFontSize,...
   'DefaultTextFontSize',Preferences.AxesFontSize)

%%%%%%%%%%%%%%%%%%%
%%% LocalHelpCB %%%
%%%%%%%%%%%%%%%%%%%
function LocalHelpCB(hFigure,varargin)
% Invoke help browser
Selection = get(hFigure,'CurrentObject');
HelpTopicKey = get(Selection,'HelpTopicKey');
if length(HelpTopicKey)
   helpview(get(hFigure,'HelpTopicMap'),HelpTopicKey,'CSHelpWindow');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% LocalStartUpMsgBox %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalStartUpMsgBox(sisodb)
% Reads the cstprefs.mat file and shows start-up message box if required

h = sisodb.Preferences.ToolboxPreferences;
if strcmp(h.StartUpMsgBox.SISOtool,'on')   
   Handles = startupdlg(sisodb.Figure, 'SISOtool', h);
   set(Handles.Figure, 'Name', xlate('Getting Started with the SISO Design Tool'));
   set(Handles.HelpBtn,'Callback','ctrlguihelp(''sisotoolmainhelp'');');
   set(Handles.TextMsg,'String',{'The SISO Design Tool is an interactive graphical user interface that facilitates the design of compensators for single-input, single-output (SISO) feedback loops.' ...
         ' ' ...
         'Click the Help button to find out more about the SISO Design Tool.'});
end
