function y = vrplay(world)
%VRPLAY Play a VRML animation file.
%   
%   VRPLAY opens a new Simulink 3D Animation player GUI. The GUI
%   allows you to open and play VRML animation files. 
% 
%   VRPLAY(FILENAME) opens a new Simulink 3D Animation player GUI
%   and loads the virtual world based on FILENAME into the player.
%
%   X=VRPLAY(...) returns the player GUI figure handle.
%
%   Keyboard support
%   ----------------
%   P:Play  F:FFwd  Rt:StepFwd  Up:First  J:Jump
%   S:Stop  R:Rew   Lt:StepRev  Dn:Last   L:Loop
%
%   NOTE: 
%       VRPLAY works only with VRML animation files created using
%       the Simulink 3D Animation VRML recording functionality.
%
%   EXAMPLE: 
%       In order to play animation file based on the vr_octavia demo
%       example, run "vrplay('octavia_scene_anim.wrl')".
%
% See also VRVIEW.

% Copyright 1998-2010 HUMUSOFT s.r.o. and The MathWorks, Inc.
% $Revision: 1.1.6.13 $ $Date: 2010/05/10 17:54:29 $ $Author: batserve $

% GUI Data organization
% ---------------------
% Figure UserData
%   .hfig           handle to figure window
%   .htoolbar       handle to GUI button toolbar
%   .htimer         timer object associated with this player
%   .hStatusBar     structure of handles to parts of status bar
%   .loopmode       0=no looping, 1=looping
%   .paused         true/false flag indicating that we're in
%                   pause mode --- set to false by pressing play or stop
%   .hWorld         current vrworld handle
%   .fullname       full path to the current virtual world file
%   .shortname      current virtual world file name (name.ext)
%   .world_loaded   true/false - a virtual world is loaded/not loaded
%   .hTimeSensor    handle to Replay_control vr node
%   .stoptime       end time of saved animation (taken from Replay_control cycleInterval)
%   .curtime        current animation time
%   .timertick      timer period with which GUI elements are updated
%                   this does NOT define the VR figure FPS during playback
%                   VR scene playback is animated with full speed allowed
%                   by the computer
%   .jumpto         time to jump to
%   .eps            small positive value - for setting the scene time at time 0
%                   VRML TimeSensors don't route to interpolators properly at time 0 
%   .hSliderPanel   handle to the uipanel that contains the Time slider
%   .hTimeSlider    handle to the Time slider
%   .hStartTime     handle to uicontrol displaying animation start time (usually 0)
%   .hCurTime       handle to uicontrol displaying current animation time
%   .hStopTime      handle to uicontrol displaying animation end time
%
% Timer Object UserData
%   .hfig           handle to corresponding figure window

try
  % Check number of input args
  if nargin < 1
    world=[];
  end;

  % Test that input is a valid filename of a Simulink 3D Animation file
  hWorldOK = [];
  if ~isempty(world) 
    hWorldOK = TestWorldValid(world);
  end

  % Create GUI 
  hfig = CreateGUI;
  InitializeGUI(hfig);
  CreateTimer(hfig);

  % Load VR World if OK
  if ~isempty(hWorldOK)
    LoadWorld(hfig, hWorldOK);
  end;

  UpdateGUIControls(hfig);

  % Return GUI figure object if LHS requested
  if nargout>0
    y = hfig;
  end

  % Clean up
  set(hfig, 'Visible' ,'on');  % time to show the player
    
catch ME
  throwAsCaller(ME);
end

% --------------------------------------------------------
function hfig = CreateGUI

% Create figure
hfig = figure( ...
  'NumberTitle', 'off', ...
  'MenuBar', 'none', ...
  'Renderer', 'painters', ...
  'Resize', 'off', ...
  'HandleVisibility', 'callback', ...
  'IntegerHandle', 'off', ...
  'WindowKeyPressFcn', @KeypressFcn, ...
  'Visible', 'off', ...
  'CloseRequestFcn', @CloseGUIFcn, ...
  'DeleteFcn', @CloseGUIFcn, ...
  'Tag', 'vrplay_fig');

% compute initial position
testtxt = uicontrol('Parent', hfig, 'Style', 'text', 'String', 'Qq');
textheight = get(testtxt, 'Extent');
textheight = textheight(4);
setappdata(hfig, 'TextHeight', textheight);
delete(testtxt)

bottomreserved = 40+2*textheight;  % height of Status panel + Slider panel in pixels
defpos = vrgetpref('DefaultFigurePosition');
initpos = [100 100 defpos(3) bottomreserved];
set(hfig, 'Position', initpos);

hSliderPanel = uipanel('parent', hfig, ...
                       'Units', 'pixels', ...
                       'Position', [0 20 initpos(3)+2 44+textheight], ...
                       'Tag', 'vrplay_sliderpanel');

hTimeSlider = uicontrol('Parent', hSliderPanel, 'Style', 'slider', ...
                        'Position', [12 25 550 24], ...
                        'Min', 0, 'SliderStep', [0.005 0.05],  ...
                        'Callback', @cb_timeslider, ...
                        'Tag', 'vrplay_timeslider');

uicontrol('Parent', hSliderPanel, 'Position', [10 6 75 textheight-4], ...
          'String', 'Start time:', 'Style','text', 'HorizontalAlignment', 'left', ...
          'Tag', 'vrplay_startcaption');    

hStartTime = uicontrol('Parent', hSliderPanel, 'Position', [90 6 80 textheight-4], ...
                       'Style', 'text', 'HorizontalAlignment', 'right', ...
                       'Tag', 'vrplay_startvalue'); 

uicontrol('Parent', hSliderPanel, 'Position', [190 6 105 textheight-4], ...
          'String', 'Current time:', 'Style', 'text', 'HorizontalAlignment', 'left', ...
          'Tag', 'vrplay_currcaption');
                    
hCurTime = uicontrol('Parent', hSliderPanel, 'Position', [300 6 85 textheight-4], ...
                     'Style', 'text', 'HorizontalAlignment', 'right', ...
                     'Tag', 'vrplay_currvalue');   
                       
uicontrol('Parent', hSliderPanel, 'Position', [400 6 70 textheight-4], ...
          'String', 'Stop time:', 'Style', 'text', 'HorizontalAlignment', 'left', ...
          'Tag', 'vrplay_stopcaption');
      
hStopTime = uicontrol('Parent', hSliderPanel, ...
                      'Position', [475 6 90 textheight-4], ...
                      'Style', 'text', 'HorizontalAlignment', 'right', ...
                      'Tag', 'vrplay_stopvalue');
 
set(get(hSliderPanel, 'children'), 'Units', 'normalized');

% Setup default figure data
%
ud = get(hfig,'userdata');

ud.hfig           = hfig;
ud.initpos        = initpos;
ud.hSliderPanel   = hSliderPanel;
ud.hTimeSlider    = hTimeSlider;
ud.hStartTime     = hStartTime;
ud.hCurTime       = hCurTime;
ud.hStopTime      = hStopTime;
ud.hmenus         = CreateMenus(hfig);
ud.htoolbar       = CreateButtonBar(hfig);
ud.htimer         = [];
ud.hStatusBar     = AddStatusBar(hfig);
ud.loopmode       = 0;    % non-looping
ud.timertick      = 0.1;  % 10 FPS for updating GUI elements
ud.bottomreserved = bottomreserved;

set(hfig, 'name', 'Simulink 3D Animation Player');

set(hfig,'userdata', ud);


% -------------------------------------------------------------------------
function KeypressFcn(hfig, eventStruct)
% Handle keypresses in main window

ud = get(hfig, 'UserData');

% play/pause and loop are always enabled
switch (eventStruct.Key)
  case 'p'           % play/pause
    cb_play(hfig,[]);
  case 'l'           % loop
    cb_loop(hfig,[]);
end

% step buttons are enabled only if not running
isRunning = IsTimerRunning(ud);
switch (eventStruct.Key)
  case 'uparrow'     % go to start
    cb_goto_start(hfig,[]);
  case { 'pageup', 'r' }   % rewind
    cb_rewind(hfig,[]);
  case 'leftarrow'  % step back
    if ~isRunning
      cb_step_back(hfig,[]);
    end
  case 'rightarrow'  % step forward
    if ~isRunning
      cb_step_fwd(hfig,[]);
    end
  case { 'pagedown', 'f' }  % fast forward
    cb_ffwd(hfig,[]);
  case 'downarrow'   % go to end
    cb_goto_end(hfig,[]);
  case 'j'           % jump to
    EditJumptoTime(hfig);
end

% stop button is enabled only if running or paused
if isRunning || ud.paused
  switch (eventStruct.Key)
    case 's'           % stop
      cb_stop(hfig,[]);
  end
end


% --------------------------------------------------------
function CloseGUIFcn(~, ~, hfig)
% Ways to get here:
%    Close all force
%    delete(hfig)
%    click "x" button in GUI
%    menu "close"
%
% Some timing issues to consider:
%   - If we close the figure, we lose the figure userdata, and that holds the
%     handle to the timer.  If that is lost, the timer is invalid.  But, any
%     pending timer events will not properly resolve - and an error may occur.
%
%  - we want to close the world but if the timer is still running, 
%    it could cause another event (timeframe to be viewed) ... and that 
%    would potentially require the world to remain open. 
%    Hence, we must shut down the timers first

if nargin<3
  hfig = gcbf;
end

if ~isempty(hfig)
  % Close dialog windows, but not the main GUI
  % Nothing to do with usability --- it's that the main GUI
  % holds the timer and data objects, and we can't delete
  % the objects before flushing pending events, etc.
  %
  % Prevent recursive closing, trigger dialog objects to close
  set(hfig,'DeleteFcn','');

  % Now begin the timer shut-down sequence
  DeleteTimersCloseFig(hfig);
end

% --------------------------------------------------------
function DeleteTimersCloseFig(hfig)
% Only called by CloseGUIFcn
%
% 1. Shut down and delete timer object
% 2. Close the figure
%
% We must do this in this sequence.
% If we close the figure, we lose the figure userdata, and that holds the
% handle to the timer.  If that is lost, the timer is invalid.  But, any
% pending timer events will not properly resolve - and an error may occur.
%
% Remedy:
%   1 - load a new stopfcn into the timer
%   2 - send a stop event to the timer
%   3 - when the stopfcn is called, we know the timer events are flushed
%   4 - delete the timer
%   5 - delete the window
%
% We only use this sequence if the timer is currently running.  If the
% timer is NOT running, this will fail (hang waiting, never close figure)
% In that case, we simply delete the timer and close the window
% immediately.

mustWaitForTimer = false;
ud = get(hfig,'userdata');
if ~isempty(ud)
  if ~isempty(ud.htimer) && strcmp(ud.htimer.running,'on')
    mustWaitForTimer = true;
    set(ud.htimer,'stopfcn',{@DeleteTimers_finalStop,hfig});
    stop(ud.htimer);  % issue stop event then wait until callback
  end
end
if ~mustWaitForTimer
  % Timer wasn't running - clean up and exit
  FinalShutdownSteps(hfig);
end

% --------------------------------------------------------
function DeleteTimers_finalStop(~, ~, hfig)
% Only called by timer stopfcn as setup in DeleteTimersCloseFig
FinalShutdownSteps(hfig);

% --------------------------------------------------------
function FinalShutdownSteps(hfig)
% Final steps:
%  - delete the vr.canvas object
%  - close and delete the virtual world
%   (this closes also any additional vrfigures)
%  - delete timer object
%  - close VRPlay window
if isempty(hfig)
  return;
end

ud = get(hfig,'userdata');
world = [];
if ~isempty(ud)
  % remember world to delete later  
  if ud.world_loaded
    world = ud.hWorld;
  end
  % Delete the timer object
  delete(ud.htimer);
end

% clear canvas DeleteFcn not to be called recursively
if ~isempty(ud.hcanvas) && isvalid(ud.hcanvas)
  set(ud.hcanvas, 'DeleteFcn', '');
end

% Close the VRPlay window
delete(hfig);

% finally close and delete the world if necessary
if ~isempty(world)
  drawnow;  
  if isvalid(world)
    close(world);
    if ~isopen(world)
      delete(world);
    end
  end
end

% --------------------------------------------------------
function hStatusBar = AddStatusBar(hfig)

figpos = get(hfig, 'position');
textheight = getappdata(hfig, 'TextHeight');

% uipanel size needs to be extended by 2 pixels in each direction to get
% the right appearance
panelpos = [0 0 figpos(3)+2 textheight+3];

hStatusBar.hStatusPanel = uipanel('Parent', hfig, ...
                                  'Units', 'pixels', 'Position', panelpos, ...
                                  'Tag', 'vrplay_statuspanel');

% Render right after background frame, so when resizing occurs,
% this will be "overwritten" by other data
hStatusBar.StatusText = uicontrol('parent', hStatusBar.hStatusPanel, ...
  'Style','text', ...
  'Units','pixels', ...
  'Position',[3 1 100 textheight-2], ...
  'String','Ready', ...
  'HorizontalAlignment','left', ...
  'Tag', 'vrplay_statustext');

% -------------------------------------------------------------------------
function UpdateStandardStatusText(hfig)
% Setup some status bar text, indicating
% current state
%
ud = get(hfig,'userdata');
isRunning = IsTimerRunning(ud);
isPaused  = ~isRunning &  ud.paused;
isStopped = ~isRunning & ~ud.paused;

if isStopped
  str = 'Stopped';
elseif isPaused
  str = 'Paused';
else
  str = 'Playing';
end

UpdateStatusText(hfig,str);

% -------------------------------------------------------------------------
function UpdateStatusText(hfig,str)
% Set arbitrary text into status region

if isempty(hfig)
  return;
end
fd = get(hfig,'UserData');
set(fd.hStatusBar.StatusText,'string',str);

% --------------------------------------------------------
function UpdateGUIControls(hfig)
% Update GUI state, including:
%   - button enable states/icons
%   - status bar text

ReactToLoopMode(hfig);             % Initial update of button icon
UpdateButtonsAndMenus(hfig);
UpdateStandardStatusText(hfig);

% --------------------------------------------------------
function UpdateButtonsAndMenus(hfig)
% Update enable-states of menus and toolbar buttons

ud = get(hfig,'userdata');
isRunning = IsTimerRunning(ud);

% Open
hopen = [ud.htoolbar.open_file ud.hmenus.open_file];
set(hopen, 'enable', offon(~isRunning));

% Stop 
hstop = [ud.htoolbar.stop ud.hmenus.stop];
set(hstop, 'enable', offon(ud.world_loaded && (isRunning || ud.paused)));

% Play and New Window
hplay = [ud.hmenus.newwin ...
         ud.htoolbar.play ...
         ud.hmenus.play ...
         ud.htoolbar.goto_start ...
         ud.hmenus.goto_start ...
         ud.htoolbar.rewind ...
         ud.hmenus.rewind ...
         ud.htoolbar.ffwd ...
         ud.hmenus.ffwd ...
         ud.htoolbar.goto_end ...
         ud.hmenus.goto_end ...
         ud.htoolbar.jumpto ...
         ud.hmenus.jumpto ...
        ];
set(hplay, 'Enable', offon(ud.world_loaded));

% Step 
hstep = [ud.htoolbar.step_back ...
         ud.hmenus.step_back ...
         ud.htoolbar.step_fwd ...
         ud.hmenus.step_fwd ...
        ];
set(hstep, 'Enable', offon(ud.world_loaded && ~isRunning));



% --------------------------------------------------------
function labels = strip_menu_accel(labels)
% Helper function to remove accelerator chars ('&') from
% uimenu labels, when not on a PC platform
if ~ispc
  for i=1:numel(labels),
    s=labels{i}; s(s=='&')=''; labels{i}=s;
  end
end

% --------------------------------------------------------
function hitems = CreateMenus(hfig)
% Create menu items in figure

% FILE
labels = strip_menu_accel({'&File', ...
  '&Open...',...
  '&New Window', ...
  '&Close'});
mhFile = uimenu(hfig,'label',labels{1});
hitems.open_file = ...
  uimenu(mhFile, 'label',labels{2}, 'callback',@cb_open_file, ...
  'accel','o', 'Tag', 'vrplay_menu_open');
hitems.newwin = ...
  uimenu(mhFile, 'label', labels{3}, 'callback', @cb_new_window, ...
  'Tag', 'vrplay_menu_newwin'); % no accelerator
hitems.close = ...
  uimenu(mhFile, 'label', labels{4}, 'callback', @CloseGUIFcn, 'separator', 'on', ...
  'accel','w', 'Tag', 'vrplay_menu_close');

% PLAYBACK
labels = strip_menu_accel({'&Playback','Go to Firs&t', 'Re&wind', ...
  'Step &Back','&Stop','&Play','Step &Forward','Fast Fo&rward','Go to &Last', ...
  '&Jump to ...','L&oop'});
VRPlayback= uimenu(hfig,'label',labels{1});
hitems.goto_start = ...
  uimenu(VRPlayback, 'label' ,labels{2}, 'callback', @cb_goto_start, 'Tag', 'vrplay_menu_gotostart');
hitems.rewind = ...
  uimenu(VRPlayback, 'label', labels{3}, 'callback', @cb_rewind, 'Tag', 'vrplay_menu_rewind');
hitems.step_back = ...
  uimenu(VRPlayback, 'label', labels{4}, 'callback', @cb_step_back, 'Tag', 'vrplay_menu_stepback');
hitems.stop = ...
  uimenu(VRPlayback, 'label', labels{5}, 'callback', @cb_stop, 'Tag', 'vrplay_menu_stop');
hitems.play = ...
  uimenu(VRPlayback, 'label', labels{6}, 'callback', @cb_play, 'Tag', 'vrplay_menu_playpause');
hitems.step_fwd = ...
  uimenu(VRPlayback, 'label', labels{7}, 'callback', @cb_step_fwd, 'Tag', 'vrplay_menu_stepfwd');
hitems.ffwd = ...
  uimenu(VRPlayback, 'label', labels{8}, 'callback', @cb_ffwd, 'Tag', 'vrplay_menu_ff');
hitems.goto_end = ...
  uimenu(VRPlayback, 'label', labels{9}, 'callback', @cb_goto_end, 'Tag', 'vrplay_menu_gotoend');

hitems.jumpto = ...
  uimenu(VRPlayback, 'label', labels{10}, 'callback', @cb_jumpto, ...
  'separator','on', 'Tag', 'vrplay_menu_jumpto');
hitems.loop = ...
  uimenu(VRPlayback, 'label', labels{11}, 'callback', @cb_loop, 'Tag', 'vrplay_menu_loop');

% HELP
labels = strip_menu_accel({'&Help','&VRPlay Help', ...
  '&Simulink 3D Animation Help', ...
  '&About Simulink 3D Animation'});
mhHelp = uimenu(hfig,'label',labels{1});
uimenu(mhHelp,'label',labels{2},'callback',@cb_vrplayhelp, 'Tag', 'vrplay_menu_vrplayhelp');
uimenu(mhHelp,'label',labels{3},'callback',@cb_vrthelp, 'Tag', 'vrplay_menu_vrthelp');
uimenu(mhHelp,'label',labels{4},'callback',@cb_aboutvrt,'separator','on', 'Tag', 'vrplay_menu_about');

% --------------------------------------------------------
function hbuttons = CreateButtonBar(hfig)
% Create button bar

% Get a bunch of playback-related icons

icons    = load('vrplay_icons');
htoolbar = uitoolbar(hfig, 'Tag', 'vrplay_toolbar');   % Create toolbar
setappdata(htoolbar,'icons',icons); % Store icons in toolbar appdata

% Create hbuttons structure to be returned to caller:
%
hbuttons.toolbar = htoolbar;

% Define uitoolbar buttons

hbuttons.open_file = ...
uipushtool(htoolbar, ...
  'cdata', icons.openFolder, ...
  'tooltip','Open file', ...
  'click', @cb_open_file, ...
  'Tag', 'vrplay_butt_open');

% "VCR" controls
%
hbuttons.goto_start = ...
uipushtool(htoolbar, ...
  'cdata', icons.goto_start_default, ...
  'tooltip','Go to start', ...
  'separator','on', ...
  'click', @cb_goto_start, ...
  'Tag', 'vrplay_butt_gotostart');
hbuttons.rewind = ...
uipushtool(htoolbar, ...
  'cdata', icons.rewind_default, ...
  'tooltip','Rewind', ...
  'click', @cb_rewind, ...
  'Tag', 'vrplay_butt_rewind');
hbuttons.step_back = ...
uipushtool(htoolbar, ...
  'cdata', icons.step_back, ...
  'tooltip','Step back', ...
  'click', @cb_step_back, ...
  'Tag', 'vrplay_butt_stepback');
hbuttons.stop = ...
uipushtool(htoolbar, ...
  'cdata', icons.stop_default, ...
  'tooltip','Stop', ...
  'click', @cb_stop, ...
  'Tag', 'vrplay_butt_stop');
hbuttons.play = ...
uipushtool(htoolbar, ...
  'cdata', icons.play_on, ...
  'tooltip','Play', ...
  'click', @cb_play, ...
  'Tag', 'vrplay_butt_playpause');
hbuttons.step_fwd = ...
uipushtool(htoolbar, ...
  'cdata', icons.step_fwd, ...
  'tooltip','Step forward', ...
  'click', @cb_step_fwd, ...
  'Tag', 'vrplay_butt_stepfwd');
hbuttons.ffwd = ...
uipushtool(htoolbar, ...
  'cdata', icons.ffwd_default, ...
  'tooltip','Fast forward', ...
  'click', @cb_ffwd, ...
  'Tag', 'vrplay_butt_ff');
hbuttons.goto_end = ...
uipushtool(htoolbar, ...
  'cdata', icons.goto_end_default, ...
  'tooltip','Go to end', ...
  'click', @cb_goto_end, ...
  'Tag', 'vrplay_butt_gotoend');

% JumpTo, Loop
%
hbuttons.jumpto = ...
uipushtool(htoolbar, ...
  'cdata', icons.jump_to, ...
  'separator','on', ...
  'tooltip','Jump to...', ...
  'click', @cb_jumpto, ...
  'Tag', 'vrplay_butt_jumpto');
hbuttons.loop = ...
uipushtool(htoolbar, ...
  'cdata', icons.loop_off, ...
  'tooltip','Loop', ...
  'tag','loopbutton', ...
  'click', @cb_loop, ...
  'Tag', 'vrplay_butt_loop');

% --------------------------------------------------------
function icons = get_icons_from_fig(hfig)

udfig = get(hfig,'userdata');
udtb = getappdata(udfig.htoolbar.toolbar);
icons = udtb.icons;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%>%%%%%%
%  
%  FigResizeFcn
%  GUI Figure ResizeFcn (resize panels only in horizontal direction)
%  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function FigResizeFcn(hco, ~)

hfig = hco;
ud = get(hfig, 'userdata');

old_units = get(hfig, 'Units');
set(hfig, 'Units', 'pixels');
figpos = get(hfig, 'Position');

% protect against too small window
if figpos(4) < ud.bottomreserved+1
  figpos(4) = ud.bottomreserved+1;
  set(hfig, 'Position', figpos);
end

% set the new SliderPanel position, fixed in vertical dimension
% don't shrink to less than width necessary to display all GUI elements
newpos = [0 20 max(figpos(3)+2, 302) 63];
set(ud.hSliderPanel, 'Position', newpos);

% set the new StatusBar position, fixed in vertical dimension
% don't shrink to less than width necessary to display all GUI elements
newpos = [0 0 max(figpos(3)+2, 302) 22];
set(ud.hStatusBar.hStatusPanel, 'Position', newpos);

% set the new vrcanvas position - if present in the figure
if ~isempty(ud.hcanvas) && isvalid(ud.hcanvas)
  newpos = [0 ud.bottomreserved+3 figpos(3)+2 figpos(4)-ud.bottomreserved];
  set(ud.hcanvas, 'Position', newpos);
end

% restore original figure units
set(hfig, 'Units', old_units)


% -------------------------------------------------------------------------
function hWorldOK = TestWorldValid(filename)

% try to open the world
wtemp = vrworld(filename, 'new');
try
  open(wtemp);
catch ME
  delete(wtemp);
  throwAsCaller(ME);
end    

% Check that world is an animation file.
% Does the new virtual world contain 'Replay_control' node?
% 'Replay_control' is the name of TimeSensor used to control
% VRML animation mechanism. TimeSensor output is routed to 
% interpolators for animated objects. If the virtual world
% doesn't contain 'Replay_control' node, it is not an animation file
if any(strcmp(get(nodes(wtemp),'Name'), 'Replay_control'))
  hWorldOK = wtemp;
else
  close(wtemp);
  if ~isopen(wtemp)
    delete(wtemp);
  end
  throwAsCaller(MException('VR:filenotanim', 'Input argument is not a VRML animation file.'));
end


% -------------------------------------------------------------------------
function LoadWorld(hfig, hWorld)

ud = get(hfig,'userdata');

% Display the world passed as an argument (checked already to be an animation file)
ud.hWorld = hWorld;

figpos = get(hfig, 'Position');

% if world not yet loaded, extend figure height by the default vrfigure height
if ~ud.world_loaded
  defpos = vrgetpref('DefaultFigurePosition');
  maxpos = get(0, 'ScreenSize');
  ysizenew = defpos(4) + figpos(4);
  yposdiff = max(0, figpos(2)+ysizenew-maxpos(4)+80);
  figpos = [figpos(1) figpos(2)-yposdiff figpos(3) ysizenew];
  set(hfig, 'Position', figpos); 
end

ud.hcanvas = vr.canvas(ud.hWorld, ...
                       'Parent', hfig, ...
                       'Units', 'pixels', ...
                       'Position', [0 ud.bottomreserved+3 figpos(3)+2 figpos(4)-ud.bottomreserved], ...
                       'DeleteFcn', {@OnWorldClosing, hfig});
ud.world_loaded = true;
    
% Reconnect all the application data to the world
ud.fullname = get(ud.hWorld,'FileName');
[~, fname, ext] = fileparts(ud.fullname);
ud.shortname = strcat(fname, ext);

% get the TimeSensor node
ud.hTimeSensor = vrnode(ud.hWorld, 'Replay_control');
ud.stoptime = ud.hTimeSensor.cycleInterval;
set(ud.hTimeSlider,'Max',ud.stoptime);
set(ud.hStopTime,'String',num2str(ud.stoptime));

set(ud.hWorld,'TimeSource','external');
set(ud.hWorld,'Time',0);
ud.jumpto = 0;
ud.curtime = 0;
set(ud.hCurTime,'String',num2str(ud.curtime));
set(ud.hTimeSlider,'Value',ud.curtime);

% Look for any (say first) xxInterpolator node that has the '_recorded'
% suffix. Such node can be used to get the granularity of recorded key 
% values to set the minor slider step. Slider major step left always as
% 5% of full saved time range.
%
% Such Interpolator doesn't need to exist in a valid VRML animation
% file (if someone saved a VRML animation file from a static scene where no 
% objects were driven during simulation, e.g. no inputs to VR Sink etc.)
% In such case we leave the slider minor step at its default startup
% value. The same for degenerate files that have 0 (1) key value only
% or have interpolator key step 0.

% xx_recorded_converter scripts are placed into recording files after
% corresponding xx_recorded interpolators, get(nodes) works "last first",
% thus find with 'last' to find the first interpolator.
FirstInterpNode= ...
  find(~cellfun(@isempty,strfind(get(nodes(ud.hWorld),'Name'),'_recorded')),1,'last');

% As people can write any DEF names and interpolators into VRML file,
% this method of getting the time step is not foolproof. 
try
  if ~isempty(FirstInterpNode)
    AllNodes=get(ud.hWorld,'Nodes');
    % granularity is key(n+1)-key(n), here we use that key(1) is always 0.
    key2 = AllNodes(FirstInterpNode).key(2);
    if key2 ~= 0
      sliderstep = get(ud.hTimeSlider,'SliderStep');
      sliderstep(1) = key2;        % minor slider step
      set(ud.hTimeSlider, 'SliderStep', sliderstep);
    end
  end
catch ME  %#ok<NASGU>  ME is unused
end

set(hfig,'name', sprintf('Simulink 3D Animation Player: %s', ud.shortname));

% allow figure resize and set the ResizeFcn
set(hfig, 'Resize', 'on', 'ResizeFcn', @FigResizeFcn);

% set new user data
set(hfig,'userdata', ud);

% update button and menu states (needs to be done AFTER updating user data)
UpdateButtonsAndMenus(hfig);


% -------------------------------------------------------------------------
function OnWorldClosing(hfig)

% stop the timer
ud = get(hfig, 'UserData');
if ~isempty(ud.htimer)
  stop(ud.htimer);
end

% re-initialize the GUI
InitializeGUI(hfig);
set(hfig, 'Visible', 'on');


% -------------------------------------------------------------------------
function InitializeGUI(hfig)

% initialize GUI to show GUI controls but no world
ud = get(hfig, 'UserData');
pos = get(hfig, 'Position');
set(hfig, 'Visible', 'off', 'Position', [pos(1:2) ud.initpos(3:4)], 'Name', 'Simulink 3D Animation Player');
set(ud.hStartTime, 'String', '0');
set(ud.hCurTime, 'String', '0');
set(ud.hStopTime, 'String', '0');
set(ud.hTimeSlider, 'Value', 0, 'Max', 1);
ud.world_loaded = false;
ud.paused         = 0;
ud.curtime        = 0;
ud.jumpto         = 0;    % jump to time
ud.hcanvas        = [];
set(hfig, 'UserData', ud, 'Resize', 'off');
UpdateGUIControls(hfig);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  
%  cb_open_file
%  Open File callback
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% -------------------------------------------------------------------------

function cb_open_file(~, ~)

% Open file
hfig=gcbf;
ud = get(hfig,'userdata');

[fname, fpath] = uigetfile({'*.wrl', 'VRML Files (*.wrl)'}, 'Select a VRML animation file');
if isequal(fname, 0)    % user cancelled file selection 
  return;
end

world = fullfile(fpath, fname);
wtemp = vrworld(world);
% user has selected the same file as currently open - do nothing
if ud.world_loaded && strcmpi(ud.fullname, get(wtemp,'FileName')) && isopen(wtemp)
  return;
end

% delete the world, we are going to create it again by TestWorldValid
if ~isopen(wtemp)
  delete(wtemp)
end

try
  hWorldOK = TestWorldValid(world);
catch ME %#ok<NASGU>
  hwarn = warndlg( ...
    {'This VRML file is not a VRML animation file.', ...
    'Simulink 3D Animation Player can play only VRML files created using', ...
    'the Simulink 3D Animation 3D recording functionality.'}, ...
    'Simulink 3D Animation Player Error', 'modal');
  waitfor(hwarn);
  return;
end

% load the world if a valid animation file
LoadWorld(hfig, hWorldOK);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%>%%%%%%
%  
%  cb_new_window
%  New Window callback
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% -------------------------------------------------------------------------

function cb_new_window(~, ~)

% Open new vrfigure displaying the same world as already open in GUI
hfig = gcbf;
ud = get(hfig, 'userdata');
if ud.world_loaded
  vrfigure(ud.hWorld);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%>%%%%%%
%  
%  cb_timeslider
%  hTimeSlider callback
%  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function cb_timeslider(~, ~)

hfig=gcbf;
ud = get(hfig,'userdata');
if ud.world_loaded
  TimeChanged(hfig, get(ud.hTimeSlider,'Value'));
else
  % Don't allow user to set slider position ~0 when world is not loaded
  set(ud.hTimeSlider,'Value',0) 
end

% --------------------------------------------------------
function cb_goto_start(~, ~, hfig)
% goto start button callback
% jump to time 0

if nargin<3
  hfig  = gcbf;
end
ud = get(hfig,'userdata');
if ud.world_loaded
  if ud.curtime ~= 0  % prevent repeated presses
    TimeChanged(hfig, 0);
  end
end
    
% --------------------------------------------------------
function cb_rewind(~, ~, hfig)
% Rewind button callback
% Go back in time by a step corresponding to the TimeSlider bigger step
if nargin<3
  hfig  = gcbf;
end
ud = get(hfig,'userdata');

if ud.world_loaded
  step = get(ud.hTimeSlider,'SliderStep');
  step = step(2)*ud.stoptime;

  % We respect loopmode here, prevent going back round the clock
  curtime = get(ud.hWorld,'Time');
  if ~ud.loopmode && curtime < step
    curtime = 0;
  else
    curtime = mod(curtime-step,ud.stoptime);
  end
   
  TimeChanged(hfig, curtime);
end
    
% --------------------------------------------------------
function cb_play(~, ~, hfig)
% Play button callback

if nargin<3
  hfig = gcbf;
end

ud    = get(hfig,'userdata');
icons = get_icons_from_fig(hfig);
hPlayButton = ud.htoolbar.play;
hPlayMenu = ud.hmenus.play;

if ud.world_loaded
  % Check if timer is already running
  if IsTimerRunning(ud)
    % Movie already playing
    %  - Move to Pause mode
    %  - Show Play icon (currently must be pause indicator)

    % Stop timer, set pause mode
    ud.paused = 1;
    set(ud.hWorld,'TimeSource','external');
    % GUI elements updated with timer tick fcn, not necessary here
    stop(ud.htimer);

     % Set play icon, darker
    set(hPlayButton, ...
      'tooltip', 'Resume', ...
      'cdata', icons.play_off);
    set(hPlayMenu, 'label','Resume');
  else
    % Not running
    if ud.paused
      % Paused - move to play
      set(ud.hWorld,'TimeSource','freerun');
    else
      % Stopped - move to play
      set(ud.hWorld,'Time',0);
      set(ud.hWorld,'TimeSource','freerun');
    end
  % Show pause icon
    set(hPlayButton, ...
      'tooltip', 'Pause', ...
      'cdata', icons.pause_default);
    set(hPlayMenu, 'label','Pause');
    start(ud.htimer);
  end
  set(hfig,'userdata',ud);
  UpdateGUIControls(hfig);
end



% --------------------------------------------------------
function cb_stop(~, ~, hfig)
% Stop button callback

if nargin<3
  hfig  = gcbf;
end

ud = get(hfig,'userdata');

if ud.world_loaded
  ud.paused = 0;  % we're stopped, not paused
  isRunning = IsTimerRunning(ud);
  if isRunning
    stop(ud.htimer);
  else
    % Update buttons only - repaint Play with bright green also when
    % timer is stopped
    stop_playback(hfig);
  end
  set(ud.hWorld,'TimeSource','external');
  TimeChanged(hfig, 0, 0);
end

% --------------------------------------------------------
function cb_step_back(~, ~, hfig)
% Step back button callback
% Go back in time by a step corresponding to the TimeSlider smaller step

if nargin<3
  hfig  = gcbf;
end
ud = get(hfig,'userdata');

if ud.world_loaded
  
  step = get(ud.hTimeSlider,'SliderStep');
  step = step(1)*ud.stoptime;

  % We respect loopmode here, prevent going back round the clock
  curtime = get(ud.hWorld,'Time');
  if ~ud.loopmode && curtime < step
    curtime = 0;
  else
    curtime = mod(curtime-step,ud.stoptime);
  end
  
  TimeChanged(hfig, curtime);
end
   
    
% --------------------------------------------------------
function cb_step_fwd(~, ~, hfig)
% Step forward button callback
% Go forward by a step corresponding to the TimeSlider smaller step

if nargin<3
  hfig  = gcbf;
end
ud = get(hfig,'userdata');

if ud.world_loaded

  step = get(ud.hTimeSlider,'SliderStep');
  step = step(1)*ud.stoptime;

  % We respect loopmode here, prevent going forward round the clock
  curtime = get(ud.hWorld,'Time');
  if ~ud.loopmode && curtime >= (ud.stoptime - step)
    curtime = ud.stoptime;
  else
    curtime = mod(curtime+step,ud.stoptime);
  end
    
  TimeChanged(hfig, curtime);
end
    
% --------------------------------------------------------
function cb_ffwd(~, ~, hfig)
% Fast forward button callback
% Go forward by a step corresponding to the TimeSlider bigger step

if nargin<3
  hfig  = gcbf;
end
ud = get(hfig,'userdata');

if ud.world_loaded

  step = get(ud.hTimeSlider,'SliderStep');
  step = step(2)*ud.stoptime;

  % We respect loopmode here, prevent going forward round the clock
  curtime = get(ud.hWorld,'Time');
  if ~ud.loopmode && curtime >= (ud.stoptime - step)
    curtime = ud.stoptime;
  else
    curtime = mod(curtime+step,ud.stoptime);
  end
  
  TimeChanged(hfig, curtime);
end
    
% --------------------------------------------------------
function cb_goto_end(~, ~, hfig)
% Goto end button callback
%
% NOTE: For fwd/bkwd mode, goes to last frame as usual,
% and enters bkwd playback.  No special code needed.

if nargin<3
  hfig  = gcbf;
end
ud = get(hfig,'userdata');

if ud.world_loaded
  if ud.curtime ~= ud.stoptime  % prevent repeated presses
    TimeChanged(hfig, ud.stoptime);
  end  
end
    
% --------------------------------------------------------
function cb_loop(~, ~, hfig)
% Loop button callback
% Store loopmode state
if nargin<3
  hfig  = gcbf;
end
ud = get(hfig,'userdata');
ud.loopmode = ~ud.loopmode;
set(hfig,'userdata',ud);

ReactToLoopMode(hfig);

% --------------------------------------------------------
function cb_vrthelp(~, ~)
% Callback for Simulink 3D Animation help
vrmfunc('FnHelpTopic','sl3d_roadmap');

% --------------------------------------------------------
function cb_vrplayhelp(~, ~)
% Callback for VRPlay help
vrmfunc('FnHelpTopic','vr_play');

% --------------------------------------------------------
function cb_aboutvrt(~, ~)
% Callback for displaying Simulink 3D Animation About box

p = fileparts(mfilename('fullpath'));
fid = fopen(fullfile(p, 'Contents.m'),'rt');
if fid~=-1
  try
    while true
      tline = fgetl(fid);
      if ~ischar(tline)
        break
      end
      if ~isempty(strfind(tline,'Version'))
        % Version string is the 3rd token in the line
        linetokens = regexp(tline, '(\S+)', 'tokens');
        vstring = char(linetokens{3});
      end
      if ~isempty (strfind(tline,'HUMUSOFT s.r.o.'))
        % Copyright string is the full line stripped from leading %
        [~,r] = strtok(tline);
        % strip leading spaces
        start = find(~isspace(r),1);
        cstring = r(start:end);
      end
    end
    fclose(fid);
    str = {['Simulink 3D Animation ' vstring], cstring};
  catch ME %#ok<NASGU>
    str = 'Could not get Simulink 3D Animation version info from the Contents.m file.';
  end
else
  str = {'Simulink 3D Animation demonstration version.', ...
         '', ...
         'For product information please visit http://www.mathworks.com/products/3d-animation .', ...
        };
end
msgbox(str, 'About Simulink 3D Animation', 'modal');


% --------------------------------------------------------
function ReactToLoopMode(hfig,loopmode)
% React to loop mode
% If no mode passed in, get mode stored in userdata
%  (ud.loopmode)

ud = get(hfig,'userdata');
if nargin<2
  loopmode = ud.loopmode;
end

% Setup button in buttonbar:
icons = get_icons_from_fig(hfig);
if loopmode
  icon = icons.loop_on;
  tip = 'Loop: On';
  check = 'on';
else
  icon = icons.loop_off;
  tip = 'Loop: Off';
  check = 'off';
end

% Update menu check and button icon:
set(ud.htoolbar.loop,'cdata',icon,'tooltip',tip);
set(ud.hmenus.loop,'checked',check);

% --------------------------------------------------------
function EditJumptoTime(hfig)
% Get manually specified time in "Jump to" dialog box

% Initialize to last "jump to" value, NOT to the current time
% This way, the edit operation becomes useful for continually
% jumping to a particular frame

ud = get(hfig,'userdata');

if ud.world_loaded
  while true  % infinite loop in case user enters invalid information
    % Show dialog
    prompt   = {'Jump to time:'};
    def      = {num2str(ud.jumpto)};
    dlgTitle = 'Jump to time';
    lineNo   = 1;
    AddOpts.Resize      = 'off';
    AddOpts.WindowStyle = 'modal';
    AddOpts.Interpreter = 'none';
    answer = inputdlgwithenter(prompt,dlgTitle,lineNo,def,AddOpts);

    if ~isempty(answer)  % cancel pressed?
      new_jumpto = str2double(answer{1});
      if ~isnan(new_jumpto)  % User entered a numeric input
        if (new_jumpto >= 0) && (new_jumpto <= ud.stoptime)
          % Get properties again, in case something has
          % changed behind our backs while dialog was open
          ud = get(hfig,'userdata');
          ud.jumpto = new_jumpto;
          % signal time changed
          TimeChanged(hfig, new_jumpto);
        else  % User entered a numeric value out of range
          hwarn = warndlg({'Invalid time entered.' ...
            'Enter time between 0 and Stop time.'}, 'Simulink 3D Animation Player Error','modal');
          waitfor(hwarn);
          continue
        end
      else  % User entered a non-numeric input
        hwarn = warndlg({'Non-numeric value entered.' ...
          'Enter time between 0 and Stop time.'}, 'Simulink 3D Animation Player Error','modal');
        waitfor(hwarn);
        continue
      end
    end
    break  % stop infinite loop
  end
end
  
% --------------------------------------------------------

function cb_jumpto(~, ~)
EditJumptoTime(gcbf);

% --------------------------------------------------------

function TimeChanged(hfig, newtime, paused)
% update scene time and GUI elements
ud = get(hfig,'userdata');
ud.curtime = newtime;
set(ud.hWorld,'Time', ud.curtime);
set(ud.hCurTime,'String',num2str(ud.curtime));
set(ud.hTimeSlider,'Value',ud.curtime);

% put player in pause mode if currently stopped
if nargin<3
  paused = ~IsTimerRunning(ud);
end
ud.paused = paused;
set(hfig,'userdata',ud);
UpdateGUIControls(hfig);

% --------------------------------------------------------
function CreateTimer(hfig)

udFig = get(hfig,'userdata');

% Setup timer, done one-time at start of VRPlay
hTimer = timer( ...
  'ExecutionMode','fixedRate', ...
  'Period', udFig.timertick, ...
  'TimerFcn', @TimerTickFcn, ...
  'StopFcn', @TimerStopFcn, ...
  'BusyMode', 'drop', ...
  'TasksToExecute', inf);

% Store figure handle in timer
udTimer.hfig = hfig;
set(hTimer,'userdata',udTimer);

% Store timer handle in figure
udFig.htimer = hTimer;
set(hfig,'userdata', udFig);

% --------------------------------------------------------
function TimerTickFcn(hco, ~)

ud = get(hco,'userdata');     % hco = timer object
hfig = ud.hfig;
ud = get(hfig,'userdata');

if ud.world_loaded
  curtime = get(ud.hWorld,'Time');

  % If not in loop mode and the time is closer to Stop time than the timer tick, 
  % set it to exactly Stop time and stop playing.
  if ~ud.loopmode && ( curtime > (ud.stoptime-ud.timertick) )
    stop(ud.htimer); % stop timer
    set(ud.hWorld,'TimeSource','external');
    ud.curtime = ud.stoptime;
    set(ud.hWorld,'Time', ud.curtime);
  else  
    ud.curtime = mod(curtime,ud.stoptime);
  end
  % Update GUI elements
  set(ud.hCurTime,'String',num2str(ud.curtime));
  set(ud.hTimeSlider,'Value',ud.curtime);
 
  set(hfig,'userdata',ud);
end

% --------------------------------------------------------
function TimerStopFcn(hco, user)  %#ok
% Keep this here, not in cb_stop
%
% This gets called when stop-method is invoked on timer object
% Note that the stop button goes through cb_stop
ud = get(hco,'userdata');
stop_playback(ud.hfig);

% --------------------------------------------------------
function stop_playback(hfig)
% General stop-playback.
% Works for timer control and single/on-demand control.
% Resets internal and GUI/button state.
ud = get(hfig,'userdata');

% Get icons, handles to play button and menu item:
icons = get_icons_from_fig(hfig);
hPlayButton = ud.htoolbar.play;
hPlayMenu = ud.hmenus.play;

% Set play icon, brighter
set(hPlayButton, ...
  'tooltip', 'Play', ...
  'cdata', icons.play_on);
set(hPlayMenu, 'label','Play');
UpdateGUIControls(hfig);

% -------------------------------------------------------------------------
function isRunning = IsTimerRunning(ud)
% Return logical flag indicating whether timer object is running
isRunning = strcmp(get(ud.htimer,'Running'),'on');

% -------------------------------------------------------------------------
function s = offon(c)
% helper function to convert logical value to 'off' or 'on'
offonstr = {'off', 'on'};
s = offonstr{c+1};


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%>%%%%%%
%  
%  the following three functions are used to modify the behavior of dialog
%  created by INPUTDLG so that "Enter" key accepts the value and "Esc" key
%  discards the value even if the edit control has the focus
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% -------------------------------------------------------------------------
function answer = inputdlgwithenter(varargin)
% get a callback when creating the edit control so we have a chance to modify its properties
origcreatefcn = get(0, 'DefaultUicontrolCreateFcn');
set(0, 'DefaultUicontrolCreateFcn', @inputdlg_uictrlcreate);
answer = inputdlg(varargin{:});
set(0, 'DefaultUicontrolCreateFcn', origcreatefcn);

% -------------------------------------------------------------------------
function inputdlg_uictrlcreate(hco, ~)
% add a KeyPressFcn to the edit control for the value
if strcmp(get(hco, 'Style'), 'edit')
  set(hco, 'KeyPressFcn', @inputdlg_editkeypress);
end

% -------------------------------------------------------------------------
function inputdlg_editkeypress(hco, eventStruct)
% if Enter or Esc is pressed, call the KeyPressFcn of parent figure
switch (eventStruct.Key)
  case { 'return', 'escape' }
    drawnow;  % needed for the 'String' property of the edit control to be updated
    fig = get(hco, 'Parent');
    figkpress = get(fig, 'KeyPressFcn');
    figkpress(fig, eventStruct);
end



% [EOF] vrplay.m
