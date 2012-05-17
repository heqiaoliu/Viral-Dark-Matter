function current = set_current(this, current)
%SET_CURRENT   PreSet function for the 'current' property.

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/01/25 23:10:25 $

% Set the private property
set(this, 'privCurrentFilter', current);

% Send the event letting other objects know that a newfilter was selected.
send(this, 'NewFilter', handle.EventData(this, 'NewFilter'));

% [EOF]
