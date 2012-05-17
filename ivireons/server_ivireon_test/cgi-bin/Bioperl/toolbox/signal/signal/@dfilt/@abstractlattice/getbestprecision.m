function s = getbestprecision(h)
%GETBESTPRECISION Return best precision for Product and Accumulator

%   Author(s): V. Pellissier
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2003/12/06 16:00:01 $

s = getbestprecision(h.filterquantizer);

% [EOF]
