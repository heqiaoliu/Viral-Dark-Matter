function enable_listener(this, eventData)
%ENABLE_LISTENER Listener to the enable property of the Selector

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/13 00:25:34 $

update(this, 'update_enablestates');

set(allchild(this), 'Enable', this.Enable);

% [EOF]
