function initdata = initmodel(this)
% INITMODEL Initialize the model for the snapshot

%  Author(s): John Glass
%   Copyright 2003-2010 The MathWorks, Inc.
% $Revision: 1.1.8.5 $ $Date: 2010/04/30 00:43:46 $

model = this.ModelParameterMgr.Model;
want = struct('OutputOption','RefineOutputTimes','SimulationMode','normal');
this.ModelParameterMgr.ModelParameters = want;
this.ModelParameterMgr.prepareModels('linearization');

% Store an empty operating point object to be used to copy
this.EmptyOpCond = opcond.OperatingPoint(model);
this.EmptyOpCond.update; %Sync with model

initdata = [];
