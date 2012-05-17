function h = cheby1ahp
%CHEBY1AHP   Construct a CHEBY1AHP object.

%   Author(s): R. Losada
%   Copyright 1999-2006 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2007/10/23 18:51:38 $

h = fmethod.cheby1ahp;

set(h,'DesignAlgorithm','Chebyshev type I');

% [EOF]
