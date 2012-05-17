function UninstallRTO(this)
%UNISTALLRTO % Uninstall RTO by resetting listeners and UserData
% as setup in InstallRTO.

%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2006/11/19 21:42:51 $

delete(this.rtoListeners);
this.rtoListeners = [];

% [EOF]
