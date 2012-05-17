function createLinAnalysisTask(model)
% CREATELINANALYSISTASK  Create a linear analysis task given a model.
%
 
% Author(s): John W. Glass 02-May-2007
%   Copyright 2007-2008 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2008/10/31 07:36:10 $

% Create a project if needed.  Otherwise add task to the top project
[names projectnodes] = CEDUtils.getProjectNames;
if isempty(names) 
    projectnode = controldesktop.getDesktopManager.addProject('New Project');
else
    projectnode = projectnodes(1);
end

% Create the task specification object
TaskSpec = LinAnalysisTask.TaskSpec;

% Set the model field
TaskSpec.Model = model;

% Add the task to the current project
TaskSpec.createTask(projectnode)

