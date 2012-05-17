function this = SISODesignConfiguration(Label)
%  SISODesignConfiguration

%  Author(s): John Glass
%  Revised:
%  Copyright 2004-2005 The MathWorks, Inc.
%	$Revision: 1.1.8.3 $  $Date: 2008/04/28 03:28:51 $

%% Create class instance
this = ControlDesignNodes.SISODesignConfiguration;

if nargin == 0
  % Call when reloading object
  return
end

%% Set properties
this.AllowsChildren = 1;
this.Label = Label;
this.Handles = struct('Panels', [], 'Buttons', [], 'PopupMenuItems', []);
this.Status = xlate('SISO Design Task Node.');

%% Set the resources
this.Resources = 'com.mathworks.toolbox.slcontrol.resources.SimulinkControlDesignSISOTOOLTask';

%% Set the icon
this.Icon = 'FileTypeIcon.M';