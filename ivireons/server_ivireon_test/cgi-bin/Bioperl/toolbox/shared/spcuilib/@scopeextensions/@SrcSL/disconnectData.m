function disconnectData(this)
%disconnectData Closes the data stream connection,
%   but does not remove main widgets/controls

% Copyright 2004-2009 The MathWorks, Inc.
% $Revision: 1.1.6.4 $ $Date: 2010/02/17 18:59:18 $

% disconnectState manages toggle button, icon, etc
% Also resets this.eventListeners to flush

disconnectState(this);
this.State.detach();

% Delete the signal data object
%
close(this.SLConnectMgr); % lose ability to quickly reconnect
this.SLConnectMgr = [];

this.Application.screenMsg(false);

% [EOF]
