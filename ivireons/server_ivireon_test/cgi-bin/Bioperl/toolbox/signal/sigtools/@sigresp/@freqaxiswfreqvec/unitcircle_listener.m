function unitcircle_listener(this, eventData)
%UNITCIRCLE_LISTENER Listener for the unitcircle parameter

%   Author(s): P. Pacheco
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2004/04/13 00:29:21 $
    
rangeopts = getfreqrangeopts(this); 

switch getsettings(getparameter(this, getfreqrangetag(this)), eventData),
    case rangeopts{4},
        disableparameter(this, 'nfft');
        enableparameter(this, 'freqscale');
        enableparameter(this, 'freqvec');
    case rangeopts{3},
        enableparameter(this, 'nfft');
        disableparameter(this, 'freqscale');
        disableparameter(this, 'freqvec');
    otherwise
        enableparameter(this, 'nfft');
        enableparameter(this, 'freqscale');
        disableparameter(this, 'freqvec');
end


% [EOF]
