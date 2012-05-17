function getsnapshotdata(this,block)
% GETZEROTIMEDATA  Method to gather snapshots

%  Author(s): John Glass
%   Copyright 2004-2008 The MathWorks, Inc.
% $Revision: 1.1.8.8 $ $Date: 2010/05/20 03:25:58 $

% Process the Jacobian
ProcessJacobian(this,block,@LocalJacobianProcessCallback)

function LocalJacobianProcessCallback(J,var)
% Extract data leaving out io specification
this  = var{2};

% Get the handle to the linearization storage;
snapshot_storage = LinearizationObjects.TimeEventStorage;

% Get the default operating point
t = J.time;
op = getopsnapshot(this,t);

% Post process the Jacobian data for linearization
J = postProcessJacobian(linutil,J);

% Find the compensator factors
try
    tunedloop = utComputeLoop(linutil,this.ModelParameterMgr,this.LoopIO,J,this.TunedBlocks,this.LinData);
    Data = struct('OperatingPoint',op,'tunedloop',tunedloop);
catch LoopComputationError
    throwAsCaller(LoopComputationError);
end
snapshot_storage.Data = [snapshot_storage.Data;Data];
