function this = FrameRate(hApp)
%FrameRate Constructor for FrameRate
% Manages updates to Frame Rate dialog when property values change
% Only instantiated for PlaybackControlsTimer object (i.e., 
% timer-based playback)

% Copyright 2004-2005 The MathWorks, Inc.
% $Revision: 1.1.6.4 $ $Date: 2009/03/09 19:33:03 $

this = scopeextensions.FrameRate;

% Initialize DialogBase properties
this.initExt('Frame Rate', hApp);

this.setHelpArgs(hApp.ScopeCfg.getHelpArgs('Framerate'));

% Set up a listener on DesiredFPS, SchedRateMin, SchedRateMax, SchedEnable
% to send a single 'FrameRateChanged' event when the SendEvent property is
% set to true.
this.PropertyListener = handle.listener(this, [this.findprop('DesiredFPS') ...
    this.findprop('SchedRateMin') this.findprop('SchedRateMax') ...
    this.findprop('SchedEnable')], 'PropertyPostSet', @(h,ev) propertyChanged(this));

%% ------------------------------------------------------------------------
function propertyChanged(this)

if this.SendEvent
    send(this, 'FrameRateChanged');
end

% [EOF]
