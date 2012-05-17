function b = thisisquantized(this)
%THISISQUANTIZED   Returns true if any section of the filter is quantized.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/12/26 22:08:54 $

b = any(isquantized(this.Stage));

% [EOF]
