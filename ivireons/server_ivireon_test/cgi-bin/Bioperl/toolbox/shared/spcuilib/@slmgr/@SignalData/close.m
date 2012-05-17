function close(this)
%CLOSE Close the SLSignalData connection

%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2006/11/19 21:42:52 $

this.TargetObject = [];
UninstallRTO(this);       % shut down RTO listeners

% [EOF]
