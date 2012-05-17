function this = Views(varargin)
%  Views Constructor for @Views class

%  Author(s): John Glass
%  Revised:
%  Copyright 1986-2005 The MathWorks, Inc.
%	$Revision: 1.1.6.7 $  $Date: 2005/12/22 19:08:56 $

%% Create class instance
this = GenericLinearizationNodes.Views;

if nargin == 0
    % Call when reloading object
    return
end

% Set the properties
this.Label = sprintf('Custom Views');
this.Handles = struct('Panels', [], 'Buttons', [], 'PopupMenuItems', []);
this.AllowsChildren = 1;
this.Status = xlate('All analysis views.');
%% Set the icon
this.Icon = fullfile('toolbox', 'shared', ...
                            'slcontrollib','resources', 'plot_views_folder.gif');

%% Node name is not editable
this.Editable = 0;

% Add required components
nodes = this.getDefaultNodes;
for i = 1:size(nodes,1)
  this.addNode(nodes(i));
end
