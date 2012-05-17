function h = cheby1bsmin(matchExactly)
%CHEBY1BSMIN   Construct a CHEBY1BSMIN object.

%   Author(s): R. Losada
%   Copyright 1999-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.8 $  $Date: 2007/10/23 18:52:19 $

h = fmethod.cheby1bsmin;

set(h,'DesignAlgorithm','Chebyshev type I');

if nargin,
    h.MatchExactly = matchExactly;
end

% [EOF]
