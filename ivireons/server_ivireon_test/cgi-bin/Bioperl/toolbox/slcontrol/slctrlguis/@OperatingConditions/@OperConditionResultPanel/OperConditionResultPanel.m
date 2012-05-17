function this = OperConditionResultPanel(Label)
%  OPERCONDITIONRESULT Constructor for @OperConditionResultPanel class

%  Author(s): John Glass
%  Revised:
%  Copyright 2004-2006 The MathWorks, Inc.
%	$Revision: 1.1.6.8 $  $Date: 2007/04/25 03:20:01 $

% Create class instance
this = OperatingConditions.OperConditionResultPanel;

if nargin == 0
  % Call when reloading object
  return
end

% Set the version number
this.Version = GenericLinearizationNodes.getVersion;

this.Label = Label;
this.Handles = struct('Panels', [], 'Buttons', [], 'PopupMenuItems', []);
this.AllowsChildren = 0;
this.Status = xlate('Operating points for a model.');

% Set the icon
this.Icon = fullfile('toolbox', 'shared', ...
                            'slcontrollib','resources', 'plot_op_conditions.gif');
