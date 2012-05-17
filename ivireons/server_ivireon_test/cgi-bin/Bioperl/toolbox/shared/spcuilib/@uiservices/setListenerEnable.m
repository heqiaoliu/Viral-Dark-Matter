function setListenerEnable(listener, enable)
%SETLISTENERENABLE Set the Listener's enabled property.

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2010/01/25 22:47:59 $

if isa(listener, 'handle.listener')
    
    % If the passed listener is an old style handle.listener object, its
    % Enabled field takes on/off.  Do this conversion before the set.
    if enable
        enable = 'on';
    else
        enable = 'off';
    end
    set(listener, 'Enabled', enable);
else
    
    % If we are dealing with a new event.listener object, we can use the
    % passed value directly.  If the listener is a vector, we must loop
    % over each element.
    for indx = 1:numel(listener)
        listener(indx).Enabled = enable;
    end
end

% [EOF]
