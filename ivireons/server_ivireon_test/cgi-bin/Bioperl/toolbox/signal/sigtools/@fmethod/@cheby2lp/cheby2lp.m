function h = cheby2lp
%CHEBY2LP   Construct a CHEBY2LP object.

%   Author(s): R. Losada
%   Copyright 1999-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.7 $  $Date: 2007/10/23 18:54:18 $

h = fmethod.cheby2lp;
set(h,'DesignAlgorithm','Chebyshev type II');

% [EOF]
