function xparams = getxparams(this)
%GETXPARAMS   Returns the param tags that force an x unzoom.

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/13 00:29:09 $

xparams = {'freqmode', getfreqrangetag(this)};

% [EOF]
