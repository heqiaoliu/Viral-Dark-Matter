function getsnapshotdata(this,block)
% GETZEROTIMEDATA  Method to gather snapshots

%  Author(s): John Glass
%   Copyright 2004-2008 The MathWorks, Inc.
% $Revision: 1.1.8.6 $ $Date: 2010/05/20 03:25:56 $

% Process the Jacobian
ProcessJacobian(this,block,@LocalJacobianProcessCallback)

function LocalJacobianProcessCallback(J,var)
% Extract data leaving out io specification
this = var{2};

% Get the handle to the linearization storage;
snapshot_storage = LinearizationObjects.TimeEventStorage;

% Post process the Jacobian data for linearization
J = postProcessJacobian(linutil,J);

% Get the default operating point
t = J.time;
op = getopsnapshot(this,t);

% Compute the loop data
loopdata = utJacobian2LoopData(linutil,this.ModelParameterMgr,J,this.IOSettings,this.TunedBlocks,this.linopts);
Data = struct('OperatingPoint',op,'loopdata',loopdata);
snapshot_storage.Data = [snapshot_storage.Data;Data];