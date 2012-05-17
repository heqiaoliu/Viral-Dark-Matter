function state = getstate(this)
%GETSTATE   Get the state.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/06/06 17:05:59 $

state = get(this);

state.Parameters = get(this, 'Parameters');

% [EOF]
