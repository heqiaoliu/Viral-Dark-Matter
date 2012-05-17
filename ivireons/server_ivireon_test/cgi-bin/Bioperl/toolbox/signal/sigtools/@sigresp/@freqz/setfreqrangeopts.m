function setfreqrangeopts(this,eventData)
%SETFREQRANGEOPTS   Sets the valid frequency range options.

%   Author(s): P. Pacheco
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/13 00:29:41 $

hprm_freqmode = getparameter(this, 'freqmode');
normalizedStatus = getsettings(hprm_freqmode, eventData);

rangeopts = getfreqrangeopts(this,normalizedStatus);

hprm = getparameter(this, getfreqrangetag(this));
if ~isempty(hprm),
    setvalidvalues(hprm, rangeopts);
end


% [EOF]
