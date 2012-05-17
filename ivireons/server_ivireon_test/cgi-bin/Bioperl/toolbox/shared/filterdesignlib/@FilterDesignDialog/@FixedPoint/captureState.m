function captureState(this)
%CAPTURESTATE   Capture the current state of the object.

%   Author(s): J. Schickler
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2006/06/11 17:22:47 $

set(this, 'LastAppliedState', get(this));

% [EOF]
