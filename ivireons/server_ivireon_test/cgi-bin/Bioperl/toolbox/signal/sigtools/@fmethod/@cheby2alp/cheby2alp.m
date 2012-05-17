function h = cheby2alp
%CHEBY2ALP   Construct a CHEBY2ALP object.

%   Author(s): R. Losada
%   Copyright 1999-2006 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2007/10/23 18:53:08 $

h = fmethod.cheby2alp;

set(h,'DesignAlgorithm','Chebyshev Type II');

% [EOF]
