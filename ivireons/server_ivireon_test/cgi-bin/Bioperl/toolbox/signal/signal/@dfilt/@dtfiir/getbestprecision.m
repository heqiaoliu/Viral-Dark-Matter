function s = getbestprecision(h)
%GETBESTPRECISION Return best precision for Product and Accumulator

%   Author(s): V. Pellissier
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/12 23:56:52 $

s = getbestprecision(h.filterquantizer);

% [EOF]
