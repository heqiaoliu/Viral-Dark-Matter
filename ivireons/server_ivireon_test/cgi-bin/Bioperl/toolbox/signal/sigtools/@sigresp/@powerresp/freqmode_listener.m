function freqmode_listener(this, eventData)
%FREQMODE_LISTENER   Listener for the freqmode (Frequency Units) parameter.

%   Author(s): P. Pacheco
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision $  $Date: 2004/04/13 00:29:53 $

freqz_freqmode_listener(this,eventData);

% Set the ylabel to match frequency units.
updateylabel(this,eventData);

% [EOF]