function pause(this, pauseFcn)
%PAUSE    Stop video playback; does not stop data source.
% Sends PauseEvent when pause completes.  If already in
% pause state, event fires immediately.

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2008/08/01 12:25:16 $

if nargin > 1
    this.Listeners.Pause.Callback = @(h, ev) onPause(this, ev, pauseFcn);
    this.Listeners.Pause.Enabled  = 'on';
end

hSrc = this.DataSource;
if isempty(hSrc)
    send(this,'PauseEvent');  % Must send event
else
    hControls = hSrc.getControls;
    if isempty(hControls)
        send(this,'PauseEvent');  % Must send event
    else
        pause(hControls);
    end
end

% -------------------------------------------------------------------------
function onPause(this, ev, pauseFcn)

this.Listeners.Pause.Enabled = 'off';

pauseFcn(this, ev);

% [EOF]
