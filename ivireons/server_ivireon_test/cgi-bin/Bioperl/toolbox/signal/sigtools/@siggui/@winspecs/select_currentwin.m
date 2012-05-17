function select_currentwin(hSpecs, val)
%SELECT_CURRENTWIN Send an NewCurrentwinIndex

%   Author(s): V.Pellissier
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.4 $  $Date: 2002/04/14 23:34:54 $

% Send an event
hEventData = sigdatatypes.sigeventdata(hSpecs, 'NewCurrentwinIndex', val);
send(hSpecs, 'NewCurrentwinIndex', hEventData);


% [EOF]
