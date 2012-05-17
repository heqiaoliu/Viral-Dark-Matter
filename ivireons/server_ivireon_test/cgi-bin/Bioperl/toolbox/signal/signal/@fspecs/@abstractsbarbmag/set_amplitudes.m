function amplitudes = set_amplitudes(this, amplitudes)
%SET_AMPLITUDES   PreSet function for the 'amplitudes' property.

%   Author(s): V. Pellissier
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2005/06/16 08:27:03 $

if ~any(isreal(amplitudes)),
        error(generatemsgid('InvalidAmplitudes'), ...
            'The ''Amplitudes'' vector must be real.')
end

% [EOF]
