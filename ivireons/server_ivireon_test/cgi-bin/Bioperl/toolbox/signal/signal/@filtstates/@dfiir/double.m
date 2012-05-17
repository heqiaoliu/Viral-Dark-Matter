function dblstates = double(h)
%DOUBLE   Convert a DFILT.DFIIRSTATES object to a double vector.

%   Author(s): P. Costa
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/01/25 23:08:11 $

dblstates = [double(h.Numerator); double(h.Denominator)];

% [EOF]
