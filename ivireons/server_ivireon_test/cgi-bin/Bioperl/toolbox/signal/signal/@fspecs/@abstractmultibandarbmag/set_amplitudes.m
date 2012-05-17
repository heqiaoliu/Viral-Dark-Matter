function amplitudes = set_amplitudes(this, amplitudes)
%SET_AMPLITUDES   PreSet function for the 'amplitudes' property.

%   Author(s): V. Pellissier
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2005/08/20 13:27:26 $

if ~any(isreal(amplitudes)),
        error(generatemsgid('InvalidAmplitudes'), ...
            'The ''Amplitudes'' vector must be real.')
end

% Force row vector
amplitudes = amplitudes(:).';

% [EOF]
