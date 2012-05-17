function freqz_freqmode_listener(this, eventData)
%FREQZ_FREQMODE_LISTENER   "Super" class freqmode_listener.

%   Author(s): P. Pacheco
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/13 00:29:30 $

% Call "super listener"
freqaxis_freqmode_listener(this,eventData);

% Set the correct frequency range options.
setfreqrangeopts(this,eventData);

% [EOF]
