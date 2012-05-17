function frequencies = set_frequencies(this, frequencies)
%SET_FREQUENCIES   PreSet function for the 'frequencies' property.

%   Author(s): V. Pellissier
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2005/06/16 08:27:04 $

if isempty(frequencies), 
    return; 
end
f1 = frequencies(1);
f2 = frequencies(end);
if ~this.NormalizedFrequency,
   f1 = f1*2/this.Fs; 
   f2 = f2*2/this.Fs; 
end
if (abs(f1)>eps && abs(f1+1)>eps) || abs(f2 - 1) > eps,
    if this.NormalizedFrequency,
        error(generatemsgid('InvalidFrequencies'), ...
            'The first element of the ''Frequencies'' vector must be 0 or -1 and the last element 1.')
    else
        error(generatemsgid('InvalidFrequencies'), ...
            'The first element of the ''Frequencies'' vector must be 0 or -Fs/2 and the last element Fs/2.')
    end
end

if any(diff(frequencies)<0),
    error(generatemsgid('InvalidFrequencies'), ...
            'The ''Frequencies'' vector must be monotonically increasing.')
end



% [EOF]
