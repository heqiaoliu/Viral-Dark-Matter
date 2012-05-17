function frequencies = set_frequencies(this, frequencies)
%SET_FREQUENCIES   PreSet function for the 'frequencies' property.

%   Author(s): V. Pellissier
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2005/08/20 13:27:21 $

if isempty(frequencies), 
    return; 
end

if any(diff(frequencies)<0),
    error(generatemsgid('InvalidFrequencies'), ...
            'The ''Frequencies'' vector must be monotonically increasing.')
end

% Force row vector
frequencies = frequencies(:).';


% [EOF]
