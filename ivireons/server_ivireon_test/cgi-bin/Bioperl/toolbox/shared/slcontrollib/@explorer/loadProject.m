function varargout = loadProject(filename,varargin)
% LOADPROJECT Loads project objects from the selected file.

% Author(s): Bora Eryilmaz
% Revised: C. Buhr
% Copyright 1986-2007 The MathWorks, Inc.
% $Revision: 1.1.6.5 $ $Date: 2007/12/14 15:01:12 $

if length(filename) < 4 || ~strcmp('.mat',filename(end-3:end))
  % Append .mat to file name
  filename = [filename, '.mat'];
end

if exist(filename, 'file') == 0
  ctrlMsgUtils.error( 'SLControllib:explorer:FileNotFound', filename );
end

% Get handles to explorer
[projectframe,workspace,manager] = slctrlexplorer;

% Load projects from file & pre-load initialization
projects = LocalPreLoadTasks( manager, manager.load(filename) );

% Add nodes
newProjNodes = [];
for ct = 1:length(projects)
  newProjNodes = [ newProjNodes; manager.Root.addNode( projects(ct) ) ];
end

% Post load initialization
LocalPostLoadTasks(manager, newProjNodes)

% Show CETM
projectframe.toFront;
projectframe.setVisible(true);

% Set selected node
if length(varargin)==2
  p = find(projects, 'Label', varargin{1});
  h = find(p, 'Label', varargin{2});

  if ~isempty(h)
    projectframe.setSelected( h.getTreeNodeInterface );
  end
elseif length(varargin)==1
  p = find(projects, 'Label', varargin{1});
  if ~isempty(p)
    projectframe.setSelected( p.getTreeNodeInterface );
  end
else
  % Select the first loaded project by default
  if ~isempty( newProjNodes )
    projectframe.setSelected( newProjNodes(1).getTreeNodeInterface );
  end
end

% Return project handles if requested.
if nargout > 0
  varargout{1} = projects;
end

% --------------------------------------------------------------------------
function projects = LocalPreLoadTasks(manager, projects)
util = slcontrol.Utilities;

% Prepare before loading
for ct1 = length(projects):-1:1
  try
    projects(ct1).preLoad(manager);
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
        tasks(ct2).preLoad(manager);
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
function LocalPostLoadTasks(manager, projects)
% Process task nodes after loading projects and adding them to the tree.
for ct1 = 1:length(projects)
  projects(ct1).postLoad(manager);
  tasks = projects(ct1).getChildren;
  for ct2 = 1:length(tasks)
    % If the node is not a task node (c.f. MPC) do not call postLoad
    if isa(tasks(ct2), 'explorer.tasknode')
      tasks(ct2).postLoad(manager);
    end
  end
end
