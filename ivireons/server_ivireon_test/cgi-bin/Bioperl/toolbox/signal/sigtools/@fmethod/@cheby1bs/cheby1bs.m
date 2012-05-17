function h = cheby1bs
%CHEBY1BS   Construct a CHEBY1BS object.

%   Author(s): R. Losada
%   Copyright 1999-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.7 $  $Date: 2007/10/23 18:52:11 $

h = fmethod.cheby1bs;

set(h,'DesignAlgorithm','Chebyshev Type I');
% [EOF]
