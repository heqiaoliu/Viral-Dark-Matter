function enable_listener(hSct, eventData)
%ENABLE_LISTENER Listener to the enable property of the Selector

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.5 $  $Date: 2002/04/14 23:30:04 $

update(hSct, 'update_enablestates');

% [EOF]
