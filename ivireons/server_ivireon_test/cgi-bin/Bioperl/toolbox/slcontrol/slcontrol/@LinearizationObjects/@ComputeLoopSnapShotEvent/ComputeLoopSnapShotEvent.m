function this = ComputeLoopSnapShotEvent(ModelParameterMgr,snapshottimes)
% OPSNAPSHOT  Constructor for the @ComputeLoopSnapShotEvent class

%  Author(s): John Glass
%   Copyright 2003-2008 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2008/02/20 01:31:49 $

this = LinearizationObjects.ComputeLoopSnapShotEvent;
this.ModelParameterMgr = ModelParameterMgr;
this.SnapShotTimes = snapshottimes(:);
