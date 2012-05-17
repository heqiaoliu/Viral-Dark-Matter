function loadfrom(this, projects)
% LOADFROM Loads project objects from the selected file.

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 1986-2008 The MathWorks, Inc.
% $Revision: 1.1.6.14 $ $Date: 2008/10/31 06:58:15 $

% Block the explorer while the dialog is being created
this.Explorer.setBlocked(true, []);

% Create dialog
Dlg = LocalCreateDlg(this);

if nargin < 2
  projects = this.Root.getChildren;
end

% Populate list box
ud = get(Dlg, 'UserData');
set(ud.Edit(1), 'String', '', 'TooltipString', '')
LocalSetList(Dlg, this)
set(Dlg, 'Visible', 'on')

% Unblock the explorer
this.Explorer.setBlocked(false, []);

% --------------------------------------------------------------------------
function Dlg = LocalCreateDlg(this)
DlgH = 20;
DlgW = 50;
UIColor = get(0, 'DefaultUIControlBackgroundColor');
Dlg = figure('Name', 'Load Projects', ...
             'Visible', 'off', ...
             'Resize', 'off', ...
             'MenuBar', 'none', ...
             'Units', 'character', ...
             'Position', [0 0 DlgW DlgH], ...
             'Color',  UIColor, ...
             'IntegerHandle', 'off', ...
             'HandleVisibility', 'off', ...
             'WindowStyle', 'modal', ...
             'NumberTitle', 'off');
centerfig(Dlg, 0);

% Button group
xgap = 2;
BW = 12;  BH = 1.8; Bgap = 1;
X0 = DlgW-xgap-3*BW-2*Bgap;
Y0 = 0.7;
uicontrol('Parent',   Dlg, ...
          'Units','   character', ...
          'Position', [X0 Y0 BW BH], ...
          'Callback', @(x,y) LocalOK(Dlg,this), ...
          'Interruptible', 'off', ...
          'BusyAction', 'cancel', ...
          'String',   'OK');

X0 = X0+BW+Bgap;
uicontrol('Parent',   Dlg, ...
          'Units','   character', ...
          'Position', [X0 Y0 BW BH], ...
          'Callback', @(x,y) LocalCancel(Dlg), ...
          'String',   'Cancel');

X0 = X0+BW+Bgap;
uicontrol('Parent',   Dlg, ...
          'Units',    'character', ...
          'Callback', @(x,y) LocalHelp(Dlg), ...
          'Position', [X0 Y0 BW BH], ...
          'String',   'Help');

Y0 = Y0+BH+0.7;
uicontrol('Parent', Dlg, ...
          'BackgroundColor', UIColor, ...
          'Style', 'text', ...
          'String', 'Load from:', ...
          'HorizontalAlignment', 'left', ...
          'Units', 'character', ...
          'Position', [xgap Y0 11 1.2]);

X0 = xgap+12;
EW = DlgW-X0-6-xgap;
ud.Edit(1) = uicontrol('Parent', Dlg, ...
                       'Style', 'edit', ...
                       'BackgroundColor', 'white', ...
                       'HorizontalAlignment', 'left', ...
                       'String', '', ...
                       'Callback', @(x,y) LocalSetList(Dlg, this), ...
                       'Units', 'character', ...
                       'Position', [X0 Y0 EW 1.4]);

ud.Edit(2) = uicontrol('Parent', Dlg, ...
                       'Style', 'pushbutton', ...
                       'BackgroundColor', UIColor, ...
                       'String', '...', ...
                       'TooltipString', xlate('Select Project file'), ...
                       'Units', 'character', ...
                       'Callback', @(x,y) LocalSetFile(Dlg, this), ...
                       'Position', [X0+EW+1 Y0 5 1.4]);

y0 = DlgH-1.8;
uicontrol('Parent', Dlg, ...
          'BackgroundColor', UIColor, ...
          'Style', 'text', ...
          'String', 'Projects:', ...
          'HorizontalAlignment', 'left', ...
          'Units', 'character', ...
          'Position', [xgap y0 DlgW-2*xgap 1]);

Y0 = Y0+1.4+0.7;
LH = y0-Y0-0.5;
ud.List = uicontrol('Parent', Dlg, ...
                    'Style',  'listbox', ...
                    'Units',  'character', ...
                    'BackgroundColor',[1 1 1], ...
                    'Position', [xgap Y0 DlgW-2*xgap LH], ...
                    'Max', 2);

set(Dlg, 'UserData', ud)

% --------------------------------------------------------------------------
function LocalHelp(Dlg)
tag    = 'load_project';
window = 'CSHelpWindow';
try
  helpview( [docroot '/toolbox/slcontrol/slcontrol.map'], tag, window, Dlg );
catch
  try
    helpview( [docroot '/toolbox/sldo/sldo.map'], tag, window, Dlg );
  catch
    helpview( [docroot '/toolbox/mpc/mpc.map'], tag, window, Dlg );
  end
end

% --------------------------------------------------------------------------
function LocalCancel(Dlg)
% Deletes dialog
delete(Dlg)

% --------------------------------------------------------------------------
function LocalSetFile(Dlg, this)
% Select MAT file
ud  = get(Dlg, 'UserData');
str = get(ud.Edit(1), 'String');

[filename, pathname] = uigetfile('*.mat', 'Load Projects', str);
if ~isequal(filename,0) && ~isequal(pathname,0)
  % Append path if file is not in the current directory
  if ~strcmpi( pathname(1:end-1), pwd )
    filename = [ pathname filename ];
  end
  set(ud.Edit(1), 'String', filename, 'TooltipString', filename)
  LocalSetList(Dlg, this)
end

% --------------------------------------------------------------------------
function LocalSetList(Dlg, this)
ud = get(Dlg, 'UserData');
filename = get(ud.Edit(1), 'String');
set( ud.Edit(1), 'TooltipString', filename )

nodes = [];
if exist(filename, 'file') ~= 0
  try
    nodes = this.load(filename);
  catch
    util = slcontrol.Utilities;
    dlg = errordlg( util.getLastError, 'Load Error', 'modal' );
    % In case the dialog is closed before uiwait blocks MATLAB.
    if ishandle(dlg)
      uiwait(dlg)
    end
    return
  end
elseif ~isempty(filename)
  msg = sprintf( '%s\nFile not found.\nPlease verify the correct file name was given.', ...
                 filename );
  warndlg( msg, 'Select Project File' )
end

set(ud.List, 'String', get(nodes, {'Label'}), 'Value', 1:length(nodes))

% --------------------------------------------------------------------------
% REM: This callback is sychronized and will not execute simultaneously.
function LocalOK(Dlg, this)
% Load projects
ud = get(Dlg, 'UserData');
selection = get(ud.List,    'Value');
filename  = get(ud.Edit(1), 'String');

if exist(filename, 'file') ~= 0
  try
    nodes = this.load(filename);
  catch
    util = slcontrol.Utilities;
    dlg = errordlg( util.getLastError, 'Load Error', 'modal' );
    % In case the dialog is closed before uiwait blocks MATLAB.
    if ishandle(dlg)
      uiwait(dlg)
    end
    return
  end

  if ~isempty(selection)
    projects = nodes(selection);

    % Close dialog
    LocalCancel(Dlg);

    % Post load initialization
    projects = LocalPreLoadTasks(this, projects);

    % Add nodes
    newProjNodes = [];
    for ct = 1:length(projects)
      newProjNodes = [newProjNodes; this.Root.addNode( projects(ct) )];
    end

    % Post load initialization
    LocalPostLoadTasks(this, newProjNodes)

    % Select the first loaded project by default
    if ~isempty( newProjNodes )
      this.Explorer.setSelected( newProjNodes(1).getTreeNodeInterface );
    end
  elseif ~isempty(nodes)
    warndlg( 'No project has been selected.', 'Select Projects' )
  end
elseif ~isempty(filename)
  msg = sprintf( '%s\nFile not found.\nPlease verify the correct file name was given.', ...
                 filename );
  warndlg( msg, 'Select Project File', 'replace' )
end

% --------------------------------------------------------------------------
function projects = LocalPreLoadTasks(this, projects)
util = slcontrol.Utilities;

% Prepare before loading
for ct1 = length(projects):-1:1
  try
    projects(ct1).preLoad(this);
  catch
    dlg = errordlg( util.getLastError, 'Load Error', 'modal' );
    % In case the dialog is closed before uiwait blocks MATLAB.
    if ishandle(dlg)
      uiwait(dlg)
    end
    projects(ct1) = [];
  end
end

for ct1 = 1:length(projects)
  tasks = projects(ct1).getChildren;
  for ct2 = 1:length(tasks)
    if isa(tasks(ct2),'explorer.tasknode')
      try
        tasks(ct2).preLoad(this);
      catch
        dlg = errordlg( util.getLastError, 'Load Error', 'modal' );
        % In case the dialog is closed before uiwait blocks MATLAB.
        if ishandle(dlg)
          uiwait(dlg)
        end
        tasks(ct2).disconnect;
      end
    end
  end
end

% --------------------------------------------------------------------------
function LocalPostLoadTasks(this, projects)
% Process task nodes after loading projects and adding them to the tree.
for ct1 = 1:length(projects)
  projects(ct1).postLoad(this);
  tasks = projects(ct1).getChildren;
  for ct2 = 1:length(tasks)
    % If the node is not a task node (c.f. MPC) do not call postLoad
    if isa(tasks(ct2), 'explorer.tasknode')
      tasks(ct2).postLoad(this);
    end
  end
end
