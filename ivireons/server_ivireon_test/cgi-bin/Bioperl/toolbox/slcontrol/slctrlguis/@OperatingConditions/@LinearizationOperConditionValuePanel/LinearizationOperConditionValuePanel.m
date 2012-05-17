function this = LinearizationOperConditionValuePanel(OpPoint,Label)
%%  LinearizationOperConditionValuePanel Constructor for @LinearizationOperConditionValuePanel class

%%  Author(s): John Glass
%%  Revised:
%   Copyright 1986-2005 The MathWorks, Inc.
%	$Revision: 1.1.8.2 $  $Date: 2005/12/22 19:09:05 $

%% Create class instance
this = OperatingConditions.LinearizationOperConditionValuePanel;

if nargin == 0
  % Call when reloading object
  return
end

this.Label = Label;
this.Handles = struct('Panels', [], 'Buttons', [], 'PopupMenuItems', []);
this.AllowsChildren = 0;
this.Status = xlate('Operating point for a model.');
this.Description = 'Model operating point';
%% Set the icon
this.Icon = fullfile('toolbox', 'shared', ...
                            'slcontrollib','resources', 'plot_op_conditions.gif');

%% Store the linearization operating condition results and settings
this.Model = OpPoint.model;
this.OpPoint = copy(OpPoint);
