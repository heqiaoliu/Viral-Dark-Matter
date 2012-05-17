function this = OperConditionValuePanel(OpPoint,Label)
%   OperConditionValuePanel Constructor for @OperConditionValuePanel class

%   Author(s): John Glass
%   Revised:
%   Copyright 1986-2006 The MathWorks, Inc.
%	$Revision: 1.1.6.10 $  $Date: 2007/04/25 03:20:04 $

%% Create class instance
this = OperatingConditions.OperConditionValuePanel;

if nargin == 0
  % Call when reloading object
  return
end

% Set the version number
this.Version = GenericLinearizationNodes.getVersion;

this.Label = Label;
this.Handles = struct('Panels', [], 'Buttons', [], 'PopupMenuItems', []);
this.AllowsChildren = 0;
this.Status = sprintf('Operating point for a model.');
this.Description = sprintf('Model operating point');

%% Set the icon
this.Icon = fullfile('toolbox', 'shared', ...
                            'slcontrollib','resources', 'plot_op_conditions.gif');

%% Store the linearization operating condition results and settings
this.Model = OpPoint.model;
this.OpPoint = copy(OpPoint);
