function freqmode_listener(this, eventData)
%FREQMODE_LISTENER   Listener for the freqmode parameter (Frequency Units).

%   Author(s): P. Pacheco
%   Copyright 2003 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2004/04/13 00:29:05 $

freqaxis_freqmode_listener(this, eventData);

hPrm = getparameter(this, getfreqrangetag(this));

if ~isempty(hPrm),

    opts.normalizedstatus = getsettings(getparameter(this, 'freqmode'), eventData);

    rangeopts = getfreqrangeopts(this,opts);

    setvalidvalues(hPrm, rangeopts);
end

% [EOF]
