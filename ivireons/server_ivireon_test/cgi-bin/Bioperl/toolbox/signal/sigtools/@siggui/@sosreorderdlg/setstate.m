function setstate(this, state)
%SETSTATE   Set the state.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/07/14 06:47:19 $

if isfield(state, 'DontScale')
    if strcmpi(state.DontScale, 'on')
        state.Scale = 'off';
    else
        state.Scale = 'on';
    end
end

sigcontainer_setstate(this, state);

% [EOF]
