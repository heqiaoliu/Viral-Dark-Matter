function freqmode_listener(this, eventData)
%FREQMODE_LISTENER Listener for the freqmode parameter

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.2.4.2 $  $Date: 2004/04/13 00:20:30 $

freqaxis_freqmode_listener(this, eventData);

hPrm = getparameter(this, getfreqrangetag(this));
if isempty(hPrm), return; end

units = getsettings(getparameter(this, 'freqmode'), eventData);

if strcmpi(units, 'on'),
    opts = {'[0, pi)', '[0, 2pi)', '[-pi, pi)'};
else
    opts = {'[0, Fs/2)', '[0, Fs)', '[-Fs/2, Fs/2)'};
end

setvalidvalues(hPrm, opts);

% [EOF]
