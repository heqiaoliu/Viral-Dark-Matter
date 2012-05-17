function pPostConfigurablePropertySet(eventSrc, eventData) %#ok<INUSD> - event data not interesting
; %#ok Undocumented
%pPostConfigurablePropertySet Set the Configuration to be empty.
%
% pPostConfigurablePropertySet(eventSrc, eventData, varargin)

%  Copyright 2005-2006 The MathWorks, Inc.

% If we have been told to ignore the next set then lets ignore it, but NOT
% the one after
if eventSrc.IgnoreNextSet
    eventSrc.IgnoreNextSet = false;
    return
end

set(eventSrc, 'Configuration', '');
