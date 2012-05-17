function h = cheby1bpmin(matchExactly)
%CHEBY1BPMIN   Construct a CHEBY1BPMIN object.

%   Author(s): R. Losada
%   Copyright 1999-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.8 $  $Date: 2007/10/23 18:51:58 $

h = fmethod.cheby1bpmin;

set(h,'DesignAlgorithm','Chebyshev type I');

if nargin,
    h.MatchExactly = matchExactly;
end

% [EOF]
