function stop(this, stopFcn)
%STOP     Stop movie playback; does not close/shutdown data source
% Sends StopEvent when stop completes.  If already in
% stop state, event fires immediately.

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2008/08/01 12:25:18 $

if nargin > 1
    this.Listeners.Stop.Callback = @(h, ev) onStop(this, ev, stopFcn);
    this.Listeners.Stop.Enabled = 'on';
end

if isempty(this.DataSource)
    send(this,'StopEvent');
else
    stop(this.DataSource);
end

% -------------------------------------------------------------------------
function onStop(this, ev, stopFcn)

this.Listeners.Stop.Enabled = 'off';

stopFcn(this, ev)

% [EOF]
