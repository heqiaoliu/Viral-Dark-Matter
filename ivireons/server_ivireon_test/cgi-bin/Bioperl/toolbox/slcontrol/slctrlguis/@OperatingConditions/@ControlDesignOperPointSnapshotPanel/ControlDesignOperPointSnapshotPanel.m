function this = ControlDesignOperPointSnapshotPanel(OpPoint,Label)
%  ControlDesignOperPointSnapshotPanel Constructor for @ControlDesignOperPointSnapshotPanel class

%  Author(s): John Glass
%  Revised:
%  Copyright 1986-2005 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $  $Date: 2006/11/17 14:04:24 $

%% Create class instance
this = OperatingConditions.ControlDesignOperPointSnapshotPanel;

if nargin == 0
  % Call when reloading object
  return
end

this.Label = Label;
this.Handles = struct('Panels', [], 'Buttons', [], 'PopupMenuItems', []);
this.AllowsChildren = 0;
this.Status = xlate('Operating point for a model.');
this.Description = xlate('Model operating point');

% Set the icon
this.Icon = fullfile('toolbox', 'shared', ...
                            'slcontrollib','resources', 'plot_op_conditions.gif');

% Store the linearization operating condition results and settings
this.Model = OpPoint.model;
this.OpPoint = copy(OpPoint);