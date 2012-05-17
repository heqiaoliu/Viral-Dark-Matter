function this = LinearizationSnapShotEvent(ModelParameterMgr,LinData,snapshottimes,iostructfcn)
% OPSNAPSHOT  Constructor for the @LinearizationSnapShotEvent class

%  Author(s): John Glass
%   Copyright 2003-2008 The MathWorks, Inc.
% $Revision: 1.1.8.4 $ $Date: 2010/05/20 03:26:00 $

this = LinearizationObjects.LinearizationSnapShotEvent;
this.ModelParameterMgr = ModelParameterMgr;
this.SnapShotTimes = snapshottimes;
this.LinData = LinData;
this.iostructfcn = iostructfcn;
this.IOSpec = LinData.iospec;