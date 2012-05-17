function this = LinearAnalysisResultNode(Label)
%  ANALYSIS Constructor for @Analysis class

%  Author(s): John Glass
%  Revised:
%  Copyright 1986-2005 The MathWorks, Inc.
%	$Revision: 1.1.6.8 $  $Date: 2006/11/17 14:04:09 $

%% Create class instance
this = GenericLinearizationNodes.LinearAnalysisResultNode;

if nargin == 0
  % Call when reloading object
  return
end

%% Set properties
this.AllowsChildren = 1;
this.Label = Label;
this.Handles = struct('Panels', [], 'Buttons', [], 'PopupMenuItems', []);
this.Status = xlate('Linearization analysis result.');

%% Set the icon
this.Icon = fullfile('toolbox', 'shared', ...
                            'slcontrollib','resources', 'plot_op_conditions_results.gif');
                        
% Add required components
nodes = this.getDefaultNodes;
for i = 1:size(nodes,1)
  this.addNode(nodes(i));
end
