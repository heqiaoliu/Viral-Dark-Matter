function frequencies = set_frequencies(this, frequencies)
%SET_FREQUENCIES   PreSet function for the 'frequencies' property.

%   Author(s): V. Pellissier
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2005/06/16 08:35:08 $

if isempty(frequencies), 
    return; 
end

if any(frequencies<0),
    error(generatemsgid('InvalidFrequencies'), ...
            'The values of the ''Frequencies'' vector must be positive.')
end

if any(diff(frequencies)<0),
    error(generatemsgid('InvalidFrequencies'), ...
            'The ''Frequencies'' vector must be monotonically increasing.')
end



% [EOF]
