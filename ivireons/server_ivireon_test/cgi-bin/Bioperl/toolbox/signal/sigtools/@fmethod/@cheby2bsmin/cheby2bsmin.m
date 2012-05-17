function h = cheby2bsmin(matchExactly)
%CHEBY2BSMIN   Construct a CHEBY2BSMIN object.

%   Author(s): R. Losada
%   Copyright 1999-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.8 $  $Date: 2007/10/23 18:53:46 $

h = fmethod.cheby2bsmin;

set(h,'DesignAlgorithm','Chebyshev Type II');

if nargin,
    h.MatchExactly = matchExactly;
end

% [EOF]
