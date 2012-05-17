function state = getState(this)
%GETSTATE   Get the state.

%   Author(s): J. Schickler
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2006/06/11 17:20:26 $

state = get(this);
state = rmfield(state, {'Path', 'ActiveTab', 'FixedPoint'});

% [EOF]
