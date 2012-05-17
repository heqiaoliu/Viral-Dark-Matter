function h = cheby1bp
%CHEBY1BP   Construct a CHEBY1BP object.

%   Author(s): R. Losada
%   Copyright 1999-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.7 $  $Date: 2007/10/23 18:51:49 $

h = fmethod.cheby1bp;

set(h,'DesignAlgorithm','Chebyshev type I');

% [EOF]
