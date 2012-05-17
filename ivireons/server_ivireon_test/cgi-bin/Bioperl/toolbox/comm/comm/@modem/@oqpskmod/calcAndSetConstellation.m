function calcAndSetConstellation(h, phaseOffset)
%CALCANDSETCONSTELLATION Calculate and set signal constellation
% (Constellation property) for MODEM.OQPSKMOD object H.

%   @modem/@oqpskmod

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/05/14 15:03:32 $

h.Constellation = [1 j -1 -j]*exp(j*(pi/4+phaseOffset));

%-------------------------------------------------------------------------------
% [EOF]
    