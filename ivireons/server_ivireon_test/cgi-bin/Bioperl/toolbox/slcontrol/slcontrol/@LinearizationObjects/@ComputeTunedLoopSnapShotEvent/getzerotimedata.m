function Data = getzerotimedata(this)
% GETZEROTIMEDATA  Method to gather snapshots

%  Author(s): John Glass
%   Copyright 2004-2008 The MathWorks, Inc.
% $Revision: 1.1.8.5 $ $Date: 2010/05/20 03:25:59 $

% Get the zero operating point
op = getopsnapshot(this,0);

% Get the Jacobian to find the blocks in the linearization
J = getJacobian(linutil,this.ModelParameterMgr.Model,this.IOSpec);

% Perform a first pass block reduction
J = minjacobian_firstpass(linutil,J);

% Find the compensator factors
tunedloop = utComputeLoop(linutil,ModelParameterMgr,this.LoopIO,J,this.TunedBlocks,this.LinData);
Data = struct('OperatingPoint',op,'tunedloop',tunedloop);