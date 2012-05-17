function this = ModelLinearizationSettings(model,varargin)
%  MODELLINEARIZATIONSETTINGS Constructor for @ModelLinearizationSettings class
%
%  Author(s): John Glass
%  Revised:
%  Copyright 1986-2005 The MathWorks, Inc.
% $Revision: 1.1.6.12 $ $Date: 2009/11/09 16:35:53 $

% Create class instance
this = ModelLinearizationNodes.ModelLinearizationSettings;

if nargin == 0
  % Call when reloading object
  return
end

% Create the node label
this.Label = sprintf('Linearization Task');
% Store the model name
this.Model = model;
% Get the linearization settings
this.IOData = getlinio(model);
% Node name is not editable
this.Editable = 0;
this.AllowsChildren = 1;
% Set the resources
this.Resources = 'com.mathworks.toolbox.slcontrol.resources.SimulinkControlDesignerExplorer';
% Set the icon
this.Icon = fullfile('toolbox', 'shared', 'slcontrollib','resources', 'simulink_doc.gif');
% Set the default plot
this.LTIPlotType = scdgetpref('DefaultLinearizationPlot');

% Set custom operating conditions and io objects
for ct = 1:(nargin-1)
    if isa(varargin{ct},'linearize.IOPoint')
        setlinio(this.Model,varargin{ct});
        this.IOData = varargin{ct};
    end
end

% Set the status property
this.Status = xlate('Model linearization task settings.');
this.Handles = struct('Panels', [], 'Buttons', [], 'PopupMenuItems', []);

% Add required nodes
nodes = this.getDefaultNodes;
for i = 1:size(nodes,1)
  this.addNode(nodes(i));
end
