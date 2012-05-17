function h = cheby2alpmin
%CHEBY2ALPMIN   Construct a CHEBY2ALPMIN object.

%   Author(s): R. Losada
%   Copyright 1999-2006 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2007/10/23 18:53:11 $

h = fmethod.cheby2alpmin;

set(h,'DesignAlgorithm','Chebyshev Type II');

% [EOF]
