function this = ArbMagBand(freqValues, amplitudeValues, magValues, ...
    phaseValues, freqrespValues)
%ARBMAGBAND   Construct an ARBMAGBAND object.

%   Author(s): J. Schickler
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2006/10/18 03:16:22 $

this = FilterDesignDialog.ArbMagBand;

if nargin > 0
    set(this, 'Frequencies', freqValues);
    if nargin > 1
        set(this, 'Amplitudes', amplitudeValues);
        if nargin > 2
            set(this, 'Magnitudes', magValues);
            if nargin > 3
                set(this, 'Phases', phaseValues);
                if nargin > 4
                    set(this, 'FreqResp', freqrespValues);
                end
            end
        end
    end
end

% [EOF]
