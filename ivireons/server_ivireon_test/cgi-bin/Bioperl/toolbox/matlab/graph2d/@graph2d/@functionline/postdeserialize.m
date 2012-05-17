function postdeserialize(h)
%POSTDESERIALIZE Enable object after deserializing

% Copyright 2004 The MathWorks, Inc.

% This function is run by hgload after a fig file has been loaded
% or by scribe after the object has been pasted into an axes.

set(h.ListenerAxes, 'enable', 'on');
set(h.ListenerUserArgs, 'enable', 'on');
set(h.ListenerGranularity, 'enable', 'on');

% make sure we get the new values after pasting.
update(h);