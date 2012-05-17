function schema
% SCHEMA Defines class attributes for Workspace class

% Author(s): John Glass
% Revised:
% Copyright 1986-2005 The MathWorks, Inc.
% $Revision: 1.1.6.4 $ $Date: 2006/11/29 21:52:34 $


% Construct class
p = findpackage('tsexplorer');
c = schema.class(p, 'Workspace', findclass(p,'node'));

schema.prop(c,'Dialog','MATLAB array');
schema.prop(c,'TsViewer','MATLAB array');
schema.prop(c,'TSPathCache','MATLAB array');

% % Tree  = this.ExplorerPanel.getSelector.getTree; is used in the workspace
% % node listeners to get the Tree handle in the CETM. To get this behavior
% % here we need to store the tree in the @Workspace node

%% Event indicating that a datachange event has occurred in one 
%% of the time series children
schema.event(c,'timeserieschange');

%% Event indicating that the structure of @timeseries nodes have channged
schema.event(c,'tsstructurechange');