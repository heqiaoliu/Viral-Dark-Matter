function sglstates = single(h)
%SINGLE   Convert a FILTSTATES.DFIIR object to a single vector.

%   Author(s): P. Costa
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/01/25 23:08:19 $

sglstates = [single(h.Numerator); single(h.Denominator)];

% [EOF]
