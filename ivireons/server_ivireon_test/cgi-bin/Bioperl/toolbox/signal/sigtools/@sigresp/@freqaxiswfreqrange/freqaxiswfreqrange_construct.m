function allPrm = freqaxiswfreqrange_construct(this,varargin)
%FREQAXISWFREQRANGE_CONSTRUCT Constructor for the freqaxiswfreqrange class.

%   Author(s): P. Pacheco
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision $  $Date: 2007/12/14 15:20:56 $

allPrm = this.freqaxis_construct(varargin{:});

% Create parameters for the frequency response object.
createparameter(this, allPrm, 'Frequency Range',getfreqrangetag(this), ...
    getfreqrangeopts(this));

hPrm = getparameter(this, getfreqrangetag(this));
l = [ ...
        handle.listener(hPrm, 'NewValue', @unitcircle_listener); ...
        handle.listener(hPrm, 'UserModified', @unitcircle_listener); ...
    ];
set(l, 'CallbackTarget', this);
set(this, 'Listeners', [this.Listeners; l]);

freqmode_listener(this, []);
unitcircle_listener(this, []);

% ---------------------------------------------------------------------------
function checkfreqvec(freqvec)

if any(freqvec < 0)
    error(generatemsgid('MustBePositive'),'The Number of points cannot be negative.');
end



% [EOF]
