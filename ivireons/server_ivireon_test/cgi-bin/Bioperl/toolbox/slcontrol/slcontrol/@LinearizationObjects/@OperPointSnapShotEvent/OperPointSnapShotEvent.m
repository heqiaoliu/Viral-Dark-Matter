function this = OperPointSnapShotEvent(ModelParameterMgr,snapshottimes)
% OPSNAPSHOT  Constructor for the @OperPointSnapShotEvent class

%  Author(s): John Glass
%   Copyright 2003-2008 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2008/02/20 01:32:04 $

this = LinearizationObjects.OperPointSnapShotEvent;
this.ModelParameterMgr = ModelParameterMgr;
this.SnapShotTimes = snapshottimes(:);
