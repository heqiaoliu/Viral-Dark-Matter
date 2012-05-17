function this = BlockExploreSubsystemMarker(varargin)
%  SubsystemMarker Constructor for @SubsystemMarker class

%  Author(s): John Glass
%  Revised:
%   Copyright 1986-2007 The MathWorks, Inc.
%	$Revision: 1.1.8.2 $  $Date: 2007/05/18 05:59:45 $

% Create class instance
this = ControlDesignNodes.BlockExploreSubsystemMarker;

if nargin == 0
  % Call when reloading object
  return
end

this.Handles = struct('Panels', [], 'Buttons', [], 'PopupMenuItems', []);
this.AllowsChildren = 1;

%% Node name is not editable
this.Editable = 0;
this.Resources = 'com.mathworks.toolbox.slcontrol.resources.SimulinkControlDesignerExplorer';

if strcmp(varargin{1},'root')
    this.Icon = fullfile('toolbox', 'slcontrol', ...
        'slctrlutil','resources', 'SimulinkModelIcon.gif');
elseif strcmp(varargin{1},'mdlref')
    this.Icon = fullfile('toolbox', 'slcontrol', ...
        'slctrlutil','resources', 'MdlRefBlockIcon.gif');
else
    this.Icon = fullfile('toolbox', 'slcontrol', ...
        'slctrlutil','resources', 'SubSystemIcon.gif');
end
