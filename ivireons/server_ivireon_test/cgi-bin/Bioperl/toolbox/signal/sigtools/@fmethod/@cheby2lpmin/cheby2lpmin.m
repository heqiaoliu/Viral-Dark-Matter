function h = cheby2lpmin(matchExactly)
%CHEBY2LPMIN   Construct a CHEBY2LPMIN object.

%   Author(s): R. Losada
%   Copyright 1999-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.8 $  $Date: 2007/10/23 18:54:27 $

h = fmethod.cheby2lpmin;

set(h,'DesignAlgorithm','Chebyshev type II');

if nargin,
    h.MatchExactly = matchExactly;
end

% [EOF]
