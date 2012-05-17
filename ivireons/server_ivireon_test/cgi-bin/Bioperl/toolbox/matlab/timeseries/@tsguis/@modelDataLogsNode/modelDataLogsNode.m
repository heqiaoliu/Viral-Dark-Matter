function this = modelDataLogsNode(varargin)
% modelDataLogsNode (for Simulink.ModelDataLogs objects) constructor

%   Copyright 2005-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $ $Date: 2008/08/20 22:59:51 $

% Create class instance
this = tsguis.modelDataLogsNode;
this.HelpFile = 'sim_data_log_cpanel';

% Check input arguments
if nargin == 0 
  this.Label = 'New Child Node';
elseif nargin == 1
  this.Label = varargin{1};
elseif nargin == 2
  this.Label = varargin{1};
  this.SimModelhandle = varargin{2};
else
  error('modelDataLogsNode:modelDataLogsNode:noNode',...
      'Node name and an optional data object handle should be provided')
end

this.AllowsChildren = true;
this.Editable  = true;
this.Icon      = fullfile(matlabroot, 'toolbox', 'matlab','timeseries', ...
                          'SimulinkModelIcon.gif');

% Build tree node. Note in the CETM there is no need to do this because the
% Explorer calls it when building the tree
this.getTreeNodeInterface;
