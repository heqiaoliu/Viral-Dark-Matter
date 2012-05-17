function nodes = getDefaultNodes(this)
% GETDEFAULTNODES  Return list of required component names.

% Author(s): John Glass
% Revised: 
% Copyright 2005 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2005/12/22 17:38:33 $

%% Create a folder node for each design snapshot
folder = controlnodes.DesignSnapshotFolder(xlate('Design History'));


nodes = folder;