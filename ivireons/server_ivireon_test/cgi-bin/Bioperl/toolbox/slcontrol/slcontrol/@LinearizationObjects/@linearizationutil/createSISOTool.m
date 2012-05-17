function sisodb = createSISOTool(this,LoopData,DesignViewsTableData) 
% CREATESISOTOOL  Create the sisotool.
%
 
% Author(s): John W. Glass 17-Aug-2005
% Copyright 2005-2008 The MathWorks, Inc.
% $Revision: 1.1.8.8 $ $Date: 2008/12/29 02:19:47 $

%% Create GUI database
sisodb = sisogui.sisotool;
sisodb.LoopData = LoopData;

%% Show waitbar
hWaitbar = waitbar(0,sprintf('SISO Design GUI is loading. Please wait...'),'Name',...
    sprintf('Simulink Control Design'));

%% Create GUI
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

% Create graphical design tools (editors)
waitbar(0.2,hWaitbar)

% Render GUI frames, menus, and toolbar
addcontrols(sisodb)

% Install GUI-wide listeners
addlisteners(sisodb)

% Create text editors
waitbar(0.3, hWaitbar)
ted1 = sisogui.pzeditor(LoopData, sisodb);
ted2 = sisogui.tooldlg([]);
sisodb.TextEditors = [ted1;ted2];

%% Loop over the design view to determine which editors are available
% Get the loop names and add the its identifier for comparison later
waitbar(0.4, hWaitbar)
LocalCreateEditors(sisodb,DesignViewsTableData);

% Store database handle and set figure callbacks
waitbar(0.6,hWaitbar)
set(SISOfig,'UserData',sisodb,...
    'CloseRequestFcn',{@LocalCloseCB sisodb},...
    'DeleteFcn',@(x,y) close(sisodb),...
    'ResizeFcn',@(x,y) resize(sisodb),...
    'KeyPressFcn',@(x,y) keyevent(sisodb),...
    'WindowButtonMotionFcn',@(x,y) mouseevent(sisodb,'wbm'))

%% Render Loop Data
LoopData.send('FirstImport');
LoopData.dataevent('all');
waitbar(0.8,hWaitbar)

%% Push placeholder "first import" transaction onto stack
T = ctrluis.transaction(LoopData);
sisodb.EventManager.record(T);

%% Complete the initialization
% Make figure visible
set(SISOfig,'Visible','on')
set(sisodb.PlotEditors(1:min(6,end)),'Visible','on');
waitbar(1,hWaitbar)
close(hWaitbar)

% Initialize status and history
ImportStatus = sprintf('Right-click on the plots for more design options.');
sisodb.EventManager.newstatus(ImportStatus);
sisodb.EventManager.recordtxt('history',...
    sprintf('%s: Starting SISO Tool for system: %s.',date,sisodb.LoopData.Name));

% Call the start-up message box
LocalStartUpMsgBox(sisodb);

%% -------------------------Internal Functions-------------------------
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalCreateEditors(sisodb,DesignViewsTableData);

TunedLoopNameList = get(sisodb.LoopData.L,{'Name'});
for ct = 1:size(DesignViewsTableData,1)
    PlotType = DesignViewsTableData{ct,2};
    if ~strcmp(PlotType,'None')
        switch PlotType;
            case 'Root Locus'
                EditorClass = 'sisogui.rleditor';
            case 'Open-Loop Bode'
                EditorClass = 'sisogui.bodeditorOL';
            case 'Nichols'
                EditorClass = 'sisogui.nicholseditor';
            case 'Closed-Loop Bode'
                EditorClass = 'sisogui.bodeditorF';
        end

        idxL = find(strcmp(DesignViewsTableData{ct,1},TunedLoopNameList));
        
        if ~isempty(sisodb.PlotEditors)
            Editor = find(sisodb.PlotEditors,'-isa',EditorClass,'EditedLoop',idxL);
            if isempty(Editor)
                % Create new editor
                Editor = addeditor(sisodb,EditorClass,idxL);
            end
        else
            % Create new editor
            Editor = addeditor(sisodb,EditorClass,idxL);
        end
    end
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LocalOpenFig 
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

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LocalCloseCB %%%
function LocalCloseCB(hSrc,event,sisodb)
set(hSrc,'Visible','off')

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LocalInitPref
function Preferences = LocalInitPref(sisodb,SISOfig)
% Initializes preferences
Preferences = sisogui.sisoprefs(sisodb);

% Set default fonts
set(SISOfig,...
    'DefaultUIControlFontSize',Preferences.UIFontSize,...
    'DefaultAxesFontSize',Preferences.AxesFontSize,...
    'DefaultTextFontSize',Preferences.AxesFontSize)

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LocalHelpCB
function LocalHelpCB(hFigure,eventData)
% Invoke help browser
Selection = get(hFigure,'CurrentObject');
HelpTopicKey = get(Selection,'HelpTopicKey');
if length(HelpTopicKey)
    helpview(get(hFigure,'HelpTopicMap'),HelpTopicKey,'CSHelpWindow');
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LocalStartUpMsgBox
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
