function this = ControlDesignOperConditionValuePanel(OpPoint,Label,SourceOpPointDescription)
%  OperConditionValuePanel Constructor for @OperConditionValuePanel class

%  Author(s): John Glass
%  Revised:
%  Copyright 1986-2005 The MathWorks, Inc.
%  $Revision: 1.1.8.4 $  $Date: 2009/08/08 01:19:18 $

%% Create class instance
this = OperatingConditions.ControlDesignOperConditionValuePanel;

if nargin == 0
  % Call when reloading object
  return
end

this.Label = Label;
this.Handles = struct('Panels', [], 'Buttons', [], 'PopupMenuItems', []);
this.AllowsChildren = 0;
str = ctrlMsgUtils.message('Slcontrol:operpointtask:OperatingPointCETMStatus');
this.Status = str;
this.Description = str;
this.SourceOpPointDescription = SourceOpPointDescription;

% Set the icon
this.Icon = fullfile('toolbox', 'shared', ...
                            'slcontrollib','resources', 'plot_op_conditions.gif');

% Store the linearization operating condition results and settings
this.Model = OpPoint.model;
this.OpPoint = copy(OpPoint);