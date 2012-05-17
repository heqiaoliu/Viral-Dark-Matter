function saveas(this, projects, waitflag)
% SAVEAS Saves the project objects to the selected file.

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 1986-2008 The MathWorks, Inc.
% $Revision: 1.1.6.13 $ $Date: 2008/10/31 06:58:17 $

% Block the explorer while the dialog is being created
this.Explorer.setBlocked(true, []);

% Create dialog
Dlg = LocalCreateDlg(this);

if nargin < 2
  projects = this.Root.getChildren;
end

% Get all projects
nodes = this.Root.getChildren;
[dummy, ia, ib] = intersect(nodes, projects);

% Populate list box
ud = get(Dlg, 'UserData');
set(ud.List, 'String', get(nodes, {'Label'}), 'Value', ia)
LocalList(Dlg, this)
set(Dlg, 'Visible', 'on')

% Last chance to save when closing the CETM.
if nargin > 2
  uiwait(Dlg)
end

% Unblock the explorer
this.Explorer.setBlocked(false, []);

% --------------------------------------------------------------------------
function Dlg = LocalCreateDlg(this)
DlgH = 20;
DlgW = 50;
UIColor = get(0, 'DefaultUIControlBackgroundColor');
Dlg = figure('Name', 'Save Projects', ...
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

y0 = DlgH-1.8;
uicontrol('Parent', Dlg, ...
          'BackgroundColor', UIColor, ...
          'Style', 'text', ...
          'String', 'Projects:', ...
          'HorizontalAlignment', 'left', ...
          'Units', 'character', ...
          'Position', [xgap y0 DlgW-2*xgap 1]);

Y0 = Y0+BH+0.7;
LH = y0-Y0-0.5;

ud.List = uicontrol('Parent', Dlg, ...
                    'Style',  'listbox', ...
                    'Units',  'character', ...
                    'BackgroundColor',[1 1 1], ...
                    'Position', [xgap Y0 DlgW-2*xgap LH], ...
                    'Callback', @(x,y) LocalList(Dlg, this), ...
                    'Max', 2);
ud.FileName = '';
ud.QEFlag   = false;

set(Dlg, 'UserData', ud)

% --------------------------------------------------------------------------
function LocalHelp(Dlg)
tag    = 'save_project';
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
% Update file name when list selection changes
function LocalList(Dlg, this)
ud  = get(Dlg, 'UserData');
selection = get(ud.List, 'Value');

nodes    = this.Root.getChildren;
projects = nodes(selection);

% Determine file name.
if isempty(projects)
  % No project selected
  filename = '';
elseif length(projects) == 1
  % Single project selected.
  if isempty(projects.SaveAs)
    filename = 'Untitled.mat';
  else
    filename = projects.SaveAs;
  end
else
  % Multiple projects selected.
  filenames = unique( get(projects, {'SaveAs'}) );
  if length(filenames) == 1
    % Projects previously saved in the same file or new projects.
    if isempty(filenames{1})
      % New projects with empty SaveAs name.
      filename = 'Untitled.mat';
    else
      % Saved before in the same file.
      filename = filenames{1};
    end
  else
    % Projects previously saved in different files.  Use a common name now.
    filename = 'Untitled.mat';
  end
end

ud.FileName = filename;
set(Dlg, 'UserData', ud)

% --------------------------------------------------------------------------
% REM: This callback is sychronized and will not execute simultaneously.
function LocalOK(Dlg, this)
% Save projects
ud = get(Dlg, 'UserData');
selection = get(ud.List, 'Value');
filename  = ud.FileName;
nodes     = this.Root.getChildren;

if ~isempty(filename) && ~isempty(selection)
  projects = nodes(selection);

  if ~ud.QEFlag
    [filename, pathname] = uiputfile('*.mat', 'Save Projects', filename);
  else
    % REM: For QE only since cannot test native windows file save dialog.
    [pathname, filename, ext] = fileparts(filename);
    filename = [filename ext];
    if ~isempty(pathname)
      pathname = [pathname filesep];
    end
  end

  if ~isequal(filename,0) && ~isequal(pathname,0)
    % Append path if file is not in the current directory
    if ~strcmpi( pathname(1:end-1), pwd )
      filename = [ pathname filename ];
    end

    % Prepare nodes before saving
    LocalPreSaveTasks(this, nodes)

    % Actual saving done here
    try
      this.save(projects, filename);
      LocalCancel(Dlg);
    catch
      util = slcontrol.Utilities;
      dlg = errordlg( util.getLastError, 'Save Error', 'modal' );
      % In case the dialog is closed before uiwait blocks MATLAB.
      if ishandle(dlg)
        uiwait(dlg)
      end
      return
    end
  end
end

% --------------------------------------------------------------------------
function LocalPreSaveTasks(this, projects)
% Process task nodes before saving.
for ct1 = 1:length(projects)
  projects(ct1).preSave(this);
  tasks = projects(ct1).getChildren;
  for ct2 = 1:length(tasks)
    % If the node is not a task node (c.f. MPC) do not call presave
    if isa(tasks(ct2), 'explorer.tasknode')
      tasks(ct2).preSave(this);
    end
  end
end
