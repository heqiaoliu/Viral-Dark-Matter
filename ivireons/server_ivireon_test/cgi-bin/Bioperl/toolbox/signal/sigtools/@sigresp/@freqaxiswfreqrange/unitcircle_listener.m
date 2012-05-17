function unitcircle_listener(this, eventData)
%UNITCIRCLE_LISTENER Listener for the unitcircle parameter.

%   Author(s): P. Pacheco
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision $  $Date: 2004/04/13 00:29:11 $

rangeopts = getfreqrangeopts(this); 

switch getsettings(getparameter(this, getfreqrangetag(this)), eventData),
    case rangeopts{3},
        disableparameter(this, 'freqscale');
    otherwise
        enableparameter(this, 'freqscale');
end

% [EOF]
