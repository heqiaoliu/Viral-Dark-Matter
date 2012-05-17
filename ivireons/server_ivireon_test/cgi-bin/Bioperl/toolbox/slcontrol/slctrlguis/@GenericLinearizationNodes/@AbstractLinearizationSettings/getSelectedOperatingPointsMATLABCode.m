function [op,op_type] = getSelectedOperatingPointsMATLABCode(this)
% GETSELECTEDOPERATINGPOINTSMATLABCODE  

% Author(s): John W. Glass 28-Jul-2008
% Copyright 2008 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2008/10/31 07:36:00 $

% Determine Operating Point Information
op_type = char(this.Dialog.getOpCondSelectPanel.getOperPointType);
switch op_type
    case 'selected_operating_points'
        op = 'op';
    case 'model_initial_condition'
        op = [];
    case 'simulation_snapshots'
        op = char(this.Dialog.getOpCondSelectPanel.getSnapshotTimes);
end