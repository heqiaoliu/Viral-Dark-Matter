function this = simulinkTsParentNode(varargin)
% Simulink Ts Parent Node Constructor
%
% VARARGIN{1}: Node name
% VARARGIN{2}: Parent handle used for creating a unique node name

%   Copyright 2005-2007 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $ $Date: 2007/12/14 14:55:53 $
%

% Create class instance
this = tsguis.simulinkTsParentNode;
this.HelpFile = 'sim_data_logs_cpanel';

this.isRoot = true;
                     
% Check input arguments
if nargin == 0 
  this.Label = 'New Child Node';
elseif nargin == 1
  this.Label = varargin{1};
elseif nargin == 2
  this.Label = this.createDefaultName( varargin{1}, varargin{2} );
else
  error('simulinkTsParentNode:simulinkTsParentNode:noNode',...
      'Node name and an optional parent node handle should be provided')
end

this.AllowsChildren = true;
this.Editable  = true;
this.Icon      = fullfile(matlabroot, 'toolbox', 'matlab','timeseries', ...
                          'SimulinkWorkspaceIcon.gif');
% this.Resources = 'com.mathworks.toolbox.control.resources.Explorer_Menus_Toolbars';
% this.Status    = 'Default explorer node.';

% Build tree node. Note in the CETM there is no need to do this because the
% Explorer calls it when building the tree
this.getTreeNodeInterface;
