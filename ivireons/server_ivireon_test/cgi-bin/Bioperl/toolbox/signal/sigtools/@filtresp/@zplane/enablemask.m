function b = enablemask(hObj)
%ENABLEMASK Returns true if the object supports masks.

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/13 00:20:59 $

% abstractresp does not support masks.  Only magresp and groupdelay.

b = false;

% [EOF]
