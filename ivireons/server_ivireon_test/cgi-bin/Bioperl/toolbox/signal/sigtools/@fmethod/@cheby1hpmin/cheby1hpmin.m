function h = cheby1hpmin(matchExactly)
%CHEBY1HPMIN   Construct a CHEBY1HPMIN object.

%   Author(s): R. Losada
%   Copyright 1999-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.8 $  $Date: 2007/10/23 18:52:38 $

h = fmethod.cheby1hpmin;
set(h,'DesignAlgorithm','Chebyshev type I');

if nargin,
    h.MatchExactly = matchExactly;
end

% [EOF]
