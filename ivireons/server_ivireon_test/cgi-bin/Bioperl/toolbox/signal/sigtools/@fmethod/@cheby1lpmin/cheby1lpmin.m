function h = cheby1lpmin(matchExactly)
%CHEBY1LPMIN   Construct a CHEBY1LPMIN object.

%   Author(s): R. Losada
%   Copyright 1999-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.8 $  $Date: 2007/10/23 18:52:58 $

h = fmethod.cheby1lpmin;

set(h,'DesignAlgorithm','Chebyshev type I');

if nargin,
    h.MatchExactly = matchExactly;
end

% [EOF]
