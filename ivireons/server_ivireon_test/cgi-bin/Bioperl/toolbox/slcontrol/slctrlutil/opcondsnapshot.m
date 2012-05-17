function opcondsnapshot(block) 
%LINSNAPSHOT  S-function for the simulation snapshot block

%  Author(s): John Glass
%  Revised:
%   Copyright 1986-2008 The MathWorks, Inc.
% $Revision: 1.1.6.19 $ $Date: 2008/06/20 08:55:21 $
setup(block);

function setup(block)

block.NumInputPorts = 0;
block.NumOutputPorts = 0;

block.NumDialogPrms = 0;
block.DialogPrmsTunable = {};
block.SampleTimes = [-1 0];
block.RegBlockMethod('Outputs', @Output);

function Output(block)

% Get the handle to the linearization storage;
snapshot_storage = LinearizationObjects.TimeEventStorage;

if ~isempty(snapshot_storage.TimeEventObj)
    % Call 'all' to force sample hits
    model = snapshot_storage.TimeEventObj.ModelParameterMgr.Model;
    
    % Get the snapshot.  For the cases where the Jacobian is needed the
    % RequestLinearization method will be called.
    snapshot_storage.TimeEventObj.getsnapshotdata(block);
end
