function this = TunedBlockSnapshot(Label)
%  SISODESIGNRESULT

%  Author(s): John Glass
%  Revised:
%  Copyright 1986-2005 The MathWorks, Inc.
%	$Revision: 1.1.8.2 $  $Date: 2005/12/22 17:38:20 $

%% Create class instance
this = controlnodes.DesignSnapshot;

if nargin == 0
  % Call when reloading object
  return
end

%% Set properties
this.AllowsChildren = 1;
this.Label = Label;
this.Handles = struct('Panels', [], 'Buttons', [], 'PopupMenuItems', []);
this.Status = xlate('Design Snapshot.');

%% Set the icon
this.Icon = fullfile('toolbox', 'shared', ...
                            'slcontrollib','resources', 'data.gif');
                        
% Add required components
nodes = this.getDefaultNodes;
for i = 1:size(nodes,1)
  this.addNode(nodes(i));
end
