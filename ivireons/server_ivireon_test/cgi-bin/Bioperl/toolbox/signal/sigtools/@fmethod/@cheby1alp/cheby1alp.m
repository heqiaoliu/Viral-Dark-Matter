function h = cheby1alp
%CHEBY1ALP   Construct a CHEBY1ALP object.

%   Author(s): R. Losada
%   Copyright 1999-2006 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2007/10/23 18:51:41 $

h = fmethod.cheby1alp;

set(h,'DesignAlgorithm','Chebyshev Type I');

% [EOF]
