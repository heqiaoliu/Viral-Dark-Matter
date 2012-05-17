function calcAndSetConstellation(h, M, phaseOffset)
%CALCANDSETCONSTELLATION Calculate and set signal constellation
% (Constellation property) for MODEM.PSKMOD object H.

%   @modem/@pskmod

%   Copyright 2006 - 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2007/05/06 15:48:36 $

angleVector = mod(((0:M-1)*2*pi/M) + phaseOffset, 2*pi);
constellation = exp(i*angleVector);

% Constellation should be complex
if isreal(constellation)
    constellation = complex(constellation, 0);
end

h.Constellation = constellation;
%-------------------------------------------------------------------------------
% [EOF]
    