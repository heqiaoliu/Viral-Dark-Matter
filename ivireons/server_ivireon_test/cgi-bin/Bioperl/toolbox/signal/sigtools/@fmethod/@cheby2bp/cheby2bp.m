function h = cheby2bp
%CHEBY2BP   Construct a CHEBY2BP object.

%   Author(s): R. Losada
%   Copyright 1999-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.7 $  $Date: 2007/10/23 18:53:16 $

h = fmethod.cheby2bp;

set(h,'DesignAlgorithm','Chebyshev type II');
% [EOF]
