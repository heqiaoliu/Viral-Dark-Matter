function loadSISOTool(this,varargin) 
% LOADSISOTOOL  package method to load sisotool session
%
 
% Author(s): A. Stothert 02-Nov-2005
% Copyright 2005-2008 The MathWorks, Inc.
% $Revision: 1.1.6.6 $ $Date: 2008/12/29 01:47:09 $

%REVISIT
 
ni=nargin;
error(nargchk(0,6,ni))

% Open GUI with session data
SessionData = varargin{1};
InitData = SessionData.Designs(1);
SessionProvided = true;


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
try
    InitData = checkdata(LoopData,InitData);
catch ME
    throw(ME)
end


% Create GUI database
sisodb = sisogui.sisotool;
sisodb.LoopData = LoopData;

% Show waitbar
hWaitbar = waitbar(0,xlate('SISO Design GUI is loading. Please wait...'));


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


% Start up with saved session
% Make figure visible
waitbar(0.5,hWaitbar)
set(SISOfig,'Visible','on')
% Load session data
waitbar(0.7,hWaitbar)
sisodb.load(SessionData,'norecord')
% Empty start (no plant data)
ImportStatus = xlate('Right-click on the plots for more design options.');


set(SISOfig,'Visible','on')

% --- Add to project explorer
% Create the project explorer
sisodb.setNode(this);

this.sisodb = sisodb;
%junk = getTaskPanel(sisodb);



%
%---- COMPLETE INIT IN BACKGROUND
%

waitbar(1,hWaitbar)
close(hWaitbar)

% Store database handle, set figure callbacks, and make figure visible
set(SISOfig,'UserData',sisodb,...
    'CloseRequestFcn',{@LocalCloseCB sisodb},...
    'DeleteFcn',@(x,y) close(sisodb),...
    'ResizeFcn',@(x,y) resize(sisodb),...
    'KeyPressFcn',@(x,y) keyevent(sisodb),...
    'WindowButtonMotionFcn',@(x,y) mouseevent(sisodb,'wbm'))

% Initialize status and history
sisodb.EventManager.newstatus(ImportStatus);
sisodb.EventManager.recordtxt('history',...
    sprintf('%s: Starting SISO Tool for system: %s',date,sisodb.LoopData.Name));

% Call the start-up message box
LocalStartUpMsgBox(sisodb);



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
   'Tag','SISODesignFig'); 

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

%%%%%%%%%%%%%%%%%%%%
%%% LocalCloseCB %%%
%%%%%%%%%%%%%%%%%%%%
function LocalCloseCB(hSrc,event,sisodb)
set(hSrc,'Visible','off')