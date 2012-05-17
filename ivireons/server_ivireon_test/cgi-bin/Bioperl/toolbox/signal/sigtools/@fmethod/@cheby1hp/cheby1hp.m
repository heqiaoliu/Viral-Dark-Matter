function h = cheby1hp
%CHEBY1HP   Construct a CHEBY1HP object.

%   Author(s): R. Losada
%   Copyright 1999-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.7 $  $Date: 2007/10/23 18:52:31 $

h = fmethod.cheby1hp;

set(h,'DesignAlgorithm','Chebyshev Type I');
% [EOF]
