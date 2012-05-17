function f = thisisfir(this)
%THISISFIR   Dispatch and call the method.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/12/26 22:04:03 $

[b,a] = tf(this);  
f = signalpolyutils('isfir',b,a);

% [EOF]
