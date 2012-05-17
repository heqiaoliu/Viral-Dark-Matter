function this = Workspace(varargin)
% WORKSPACE Constructor for @Workspace object

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 1986-2005 The MathWorks, Inc.
% $Revision: 1.1.6.4 $ $Date: 2005/12/22 18:52:44 $

% Create class instance
this = explorer.Workspace;
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
