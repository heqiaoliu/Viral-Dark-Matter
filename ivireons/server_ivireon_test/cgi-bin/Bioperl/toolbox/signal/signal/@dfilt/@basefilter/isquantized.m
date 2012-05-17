function b = isquantized(this)
%ISQUANTIZED   Returns true if it is a quantized DFILT.

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2009/07/27 20:28:48 $

% Use BASE_IS to add vector support.
b = base_is(this, 'thisisquantized');

% [EOF]
