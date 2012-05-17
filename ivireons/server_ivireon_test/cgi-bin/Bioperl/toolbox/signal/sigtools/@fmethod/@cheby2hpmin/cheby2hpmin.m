function h = cheby2hpmin(matchExactly)
%CHEBY2HPMIN   Construct a CHEBY2HPMIN object.

%   Author(s): R. Losada
%   Copyright 1999-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.8 $  $Date: 2007/10/23 18:54:06 $

h = fmethod.cheby2hpmin;

set(h,'DesignAlgorithm','Chebyshev type II');

if nargin,
    h.MatchExactly = matchExactly;
end

% [EOF]
