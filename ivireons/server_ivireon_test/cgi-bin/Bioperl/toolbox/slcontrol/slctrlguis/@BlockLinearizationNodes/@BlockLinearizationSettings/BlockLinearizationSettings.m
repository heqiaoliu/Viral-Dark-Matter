function this = BlockLinearizationSettings(model,block)
%  BLOCKLINEARIZATIONSETTINGS Constructor for @BlockLinearizationSettings class
%
%  Author(s): John Glass
%  Revised:
%  Copyright 1986-2005 The MathWorks, Inc.
%	$Revision: 1.1.6.11 $  $Date: 2009/04/21 04:49:24 $

% Create class instance
this = BlockLinearizationNodes.BlockLinearizationSettings;

if nargin == 0
    % Call when reloading object
    return
end

% Create the node label
this.Label = sprintf('Block Linearization Task - %s',get_param(block,'Name'));
% Store the model name
this.Model = model;
% Store the block handle
this.Block = block;
% Node name is not editable
this.Editable = 0;
this.AllowsChildren = 1;
% Set the resources
this.Resources = 'com.mathworks.toolbox.slcontrol.resources.SimulinkControlDesignerExplorer';
% Set the default plot
this.LTIPlotType = scdgetpref('DefaultLinearizationPlot');

% Set the icon
this.Icon = fullfile('toolbox', 'shared', ...
    'slcontrollib','resources', 'simulink_doc.gif');

% Set the status property
this.Status = xlate('Block linearization task settings.');
this.Handles = struct('Panels', [], 'Buttons', [], 'PopupMenuItems', []);

% Add required nodes
nodes = this.getDefaultNodes;
for i = 1:size(nodes,1)
    this.addNode(nodes(i));
end