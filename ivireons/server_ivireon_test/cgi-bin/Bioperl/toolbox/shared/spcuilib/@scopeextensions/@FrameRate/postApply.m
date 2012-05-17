function [b, str] = postApply(this)
%POSTAPPLY Called after the dialog has been applied.

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/12/14 15:02:37 $

b = true;
str = '';

% Set the SendEvent property back to true so that individual property
% changes will send the event.
this.SendEvent = true;

% Send the FrameRateChanged event to notify listeners that a framerate
% property has changed.  Do this via a single event so that the order of
% operation does not matter.  g410866
send(this, 'FrameRateChanged');

% [EOF]
