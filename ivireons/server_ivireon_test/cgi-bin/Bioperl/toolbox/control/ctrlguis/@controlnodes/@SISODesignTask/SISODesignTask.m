function this = SISODesignTask(Label,sisodb)
%  SISODesignConfiguration

%  Author(s): John Glass
%  Revised:
%  Copyright 2004-2005 The MathWorks, Inc.
%	$Revision: 1.1.8.2 $  $Date: 2005/12/22 17:38:31 $

%% Create class instance
this = controlnodes.SISODesignTask;

if nargin == 0
    % Call when reloading object
    return
end

%% Store the sisodb
this.sisodb = sisodb;

%% Set properties
this.AllowsChildren = 1;
this.Label = Label;
this.Handles = struct('Panels', [], 'Buttons', [], 'PopupMenuItems', []);
this.Status = xlate('SISO Design Task Node.');

%% Set the resources for the menu and toolbar items
this.Resources = 'com.mathworks.toolbox.control.resources.SISOTool_Menus_Toolbars';

%% Set the icon
this.Icon = fullfile('toolbox', 'shared', ...
    'slcontrollib','resources', 'm.gif');

%% Add required components
nodes = this.getDefaultNodes;
for i = 1:size(nodes,1)
    this.addNode(nodes(i));
end