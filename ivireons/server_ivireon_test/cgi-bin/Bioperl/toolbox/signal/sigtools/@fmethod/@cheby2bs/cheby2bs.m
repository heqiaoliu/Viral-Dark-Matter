function h = cheby2bs
%CHEBY2BS   Construct a CHEBY2BS object.

%   Author(s): R. Losada
%   Copyright 1999-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.7 $  $Date: 2007/10/23 18:53:38 $

h = fmethod.cheby2bs;

set(h,'DesignAlgorithm','Chebyshev type II');

% [EOF]
