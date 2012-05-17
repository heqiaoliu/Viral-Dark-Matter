function this = ViewSettings(number)
%  Views Constructor for @Views class

%  Author(s): John Glass
%  Revised:
%  Copyright 1986-2005 The MathWorks, Inc.
%	$Revision: 1.1.6.6 $  $Date: 2005/12/22 19:08:47 $

% Create class instance
this = GenericLinearizationNodes.ViewSettings;

if nargin == 0
    % Call when reloading object
    return
end

% Set the properties
this.Label = sprintf('View %d',number);
this.Handles = struct('Panels', [], 'Buttons', [], 'PopupMenuItems', []);
this.Status = xlate('Configuration for analysis views.');
%% Set the icon
this.Icon = fullfile('toolbox', 'shared', ...
                            'slcontrollib','resources', 'plot_views.gif');

% Add required components
nodes = this.getDefaultNodes;
for i = 1:size(nodes,1)
  this.addNode(nodes(i));
end
