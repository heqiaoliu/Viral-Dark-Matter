function this = OperatingConditionTask(model,opspec)
%  OperatingConditionTask Constructor for @OperatingConditionTask class

%  Author(s): John Glass
%  Revised:
%   Copyright 1986-2008 The MathWorks, Inc.
% $Revision: 1.1.6.12 $ $Date: 2008/12/04 23:27:35 $

% Create class instance
this = OperatingConditions.OperatingConditionTask;

if nargin == 0
  % Call when reloading object
  return
end

% Set the version number
this.Version = GenericLinearizationNodes.getVersion;

% Set the label
this.Label = sprintf('Operating Points');
this.Handles = struct('Panels', [], 'Buttons', [], 'PopupMenuItems', []);
this.AllowsChildren = 1;
this.Status = sprintf('Compute operating points.');

% Node name is not editable
this.Editable = 0;

% Set the resources
this.Resources = 'com.mathworks.toolbox.slcontrol.resources.SimulinkControlDesignerExplorer';

% Set the icon
this.Icon = fullfile('toolbox', 'shared', ...
                            'slcontrollib','resources', 'plot_op_conditions_folder.gif');
                        
% Initialize the model
this.Model = model;

% Set the initial operating condition constraint data
this.OpSpecData = opspec;

% Get the options
this.Options = linoptions('DisplayReport','iter');
this.StoreDiagnosticsInspectorInfo = scdgetpref('StoreDiagnosticsInspectorInfo');

% Store the optimization option strings for the dialog
this.OptimChars = struct(...
            'DiffMaxChange',num2str(this.Options.OptimizationOptions.DiffMaxChange),...
            'DiffMinChange',num2str(this.Options.OptimizationOptions.DiffMinChange),...
            'MaxFunEvals',num2str(this.Options.OptimizationOptions.MaxFunEvals),...
            'MaxIter',num2str(this.Options.OptimizationOptions.MaxIter),...
            'TolFun',num2str(this.Options.OptimizationOptions.TolFun),...
            'TolX',num2str(this.Options.OptimizationOptions.TolX));

% Set the state ordering cell array
this.StateOrderList = OperatingConditions.updateStateOrder(this.OpSpecData,this.StateOrderList);

% Add required components
nodes = this.getDefaultNodes;
for i = 1:size(nodes,1)
  this.addNode(nodes(i));
end
