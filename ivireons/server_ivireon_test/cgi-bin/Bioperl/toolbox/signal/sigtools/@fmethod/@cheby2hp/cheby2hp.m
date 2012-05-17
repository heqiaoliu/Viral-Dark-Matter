function h = cheby2hp
%CHEBY2HP   Construct a CHEBY2HP object.

%   Author(s): R. Losada
%   Copyright 1999-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.7 $  $Date: 2007/10/23 18:53:58 $

h = fmethod.cheby2hp;

set(h,'DesignAlgorithm','Chebyshev type II');

% [EOF]
