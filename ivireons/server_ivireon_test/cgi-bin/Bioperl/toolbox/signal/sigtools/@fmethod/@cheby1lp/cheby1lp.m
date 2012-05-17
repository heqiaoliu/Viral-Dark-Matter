function h = cheby1lp
%CHEBY1LP   Construct a CHEBY1LP object.

%   Author(s): R. Losada
%   Copyright 1999-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.7 $  $Date: 2007/10/23 18:52:50 $

h = fmethod.cheby1lp;

set(h,'DesignAlgorithm','Chebyshev type I');

% [EOF]
