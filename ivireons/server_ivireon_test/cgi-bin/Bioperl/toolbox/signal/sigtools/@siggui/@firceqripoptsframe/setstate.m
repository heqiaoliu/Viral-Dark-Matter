function setstate(this, state)
%SETSTATE   Set the state.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.4.2 $  $Date: 2004/03/15 22:30:18 $

set(this, 'isMinPhase', state.isMinPhase, ...
    'StopbandSlope', state.StopbandSlope);

% [EOF]
