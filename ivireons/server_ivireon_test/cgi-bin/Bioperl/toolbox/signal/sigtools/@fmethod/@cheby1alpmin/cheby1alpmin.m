function h = cheby1alpmin
%CHEBY1ALPMIN   Construct a CHEBY1ALPMIN object.

%   Author(s): R. Losada
%   Copyright 1999-2006 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2007/10/23 18:51:44 $

h = fmethod.cheby1alpmin;

set(h,'DesignAlgorithm','Chebyshev type I');

% [EOF]
