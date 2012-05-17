function this = InspectorRoot(varargin)
%  InspectorRoot Constructor for @InspectorRoot class

%  Author(s): John Glass
%  Revised:
%  Copyright 2006 The MathWorks, Inc.
%	$Revision: 1.1.10.1 $  $Date: 2007/02/06 20:02:32 $

% Create class instance
this = GenericLinearizationNodes.InspectorRoot;
this.generic_listeners;

% Check input arguments
if nargin > 1
  this.Label = varargin{1};
else
  this.Label = sprintf('Workspace');
end

this.AllowsChildren = true;
this.Editable  = false;
this.Icon      = fullfile( 'toolbox', 'shared', ...
                           'slcontrollib', 'resources', 'MatlabWorkspace.gif' );
this.Resources = 'com.mathworks.toolbox.control.resources.Explorer_Menus_Toolbars';
this.Status    = xlate('Workspace node.');
