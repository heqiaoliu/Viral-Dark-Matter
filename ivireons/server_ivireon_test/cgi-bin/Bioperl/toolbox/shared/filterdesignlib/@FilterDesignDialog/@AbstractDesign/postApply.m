function [b, str] = postApply(this)
%POSTAPPLY   Send the DialogApplied event.

%   Author(s): J. Schickler
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2006/06/11 17:20:41 $

b = true;
str = '';

if ~strcmpi(this.OperatingMode, 'matlab')
    % Capture the state so we can design the filter based on the last applied
    % settings as opposed to the current settings which may not be applied.
    captureState(this);

    % Clear out the last applied filter.  We will need to redesign, but only
    % when necessary.
    set(this, 'LastAppliedFilter', []);
end

send(this, 'DialogApplied', handle.EventData(this, 'DialogApplied'));

% [EOF]
