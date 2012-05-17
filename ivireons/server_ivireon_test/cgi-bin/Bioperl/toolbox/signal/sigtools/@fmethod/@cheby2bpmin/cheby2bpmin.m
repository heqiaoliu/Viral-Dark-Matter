function h = cheby2bpmin(matchExactly)
%CHEBY2BPMIN   Construct a CHEBY2BPMIN object.

%   Author(s): R. Losada
%   Copyright 1999-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.8 $  $Date: 2007/10/23 18:53:25 $

h = fmethod.cheby2bpmin;

set(h,'DesignAlgorithm','Chebyshev type II');

if nargin,
    h.MatchExactly = matchExactly;
end

% [EOF]
