function state = getState(this)
%GETSTATE   Get the state.

%   Author(s): J. Schickler
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2006/10/18 03:16:32 $

state = get(this);
state = rmfield(state, {'Path', 'ActiveTab', 'FixedPoint'});

for indx = 1:10
    bandProp = sprintf('Band%d', indx);
    if isempty(this.(bandProp))
        break
    else
        state.(bandProp) = get(this.(bandProp));
    end
end

% [EOF]
