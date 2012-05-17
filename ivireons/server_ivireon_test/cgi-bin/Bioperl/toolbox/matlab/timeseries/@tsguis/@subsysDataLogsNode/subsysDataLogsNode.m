function this = subsysDataLogsNode(varargin)
% subsysDataLogsNode (for Simulink.SubsysDataLogs objects) constructor
%
% VARARGIN{1}: Node name
% VARARGIN{2}: Parent handle used for creating a unique node name
%
%   Copyright 2005-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $ $Date: 2008/08/20 23:00:08 $

% Create class instance
this = tsguis.subsysDataLogsNode;
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
    error('subsysDataLogsNode:subsysDataLogsNode:noNode',...
        'Node name and an optional parent node handle should be provided')
end

this.AllowsChildren = true;
this.Editable  = true;
this.Icon      = fullfile(matlabroot, 'toolbox', 'matlab','timeseries', ...
    'SubSystemIcon.gif');

% Build tree node. Note in the CETM there is no need to do this because the
% Explorer calls it when building the tree
this.getTreeNodeInterface;
