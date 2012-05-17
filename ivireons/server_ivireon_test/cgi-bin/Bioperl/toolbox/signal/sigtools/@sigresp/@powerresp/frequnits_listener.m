function frequnits_listener(this, eventData)
%FREQUNITS_LISTENER   Listener to the frequnits parameter.

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/13 00:29:54 $

setvalidvalues(getparameter(this, getmagdisplaytag(this)), getylabels(this));

% [EOF]
