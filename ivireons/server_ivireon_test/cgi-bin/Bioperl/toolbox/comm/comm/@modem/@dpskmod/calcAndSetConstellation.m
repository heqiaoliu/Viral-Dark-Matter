function calcAndSetConstellation(h, M)
%CALCANDSETCONSTELLATION Calculate and set signal constellation
% (Constellation property) for MODEM.DPSKMOD object H.

%   @modem/@dpskmod

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/05/06 15:47:12 $

constellation = exp(i*((0:M-1)*2*pi/M));

% Constellation should be complex
if isreal(constellation)
    constellation = complex(constellation, 0);
end

h.Constellation = constellation;

%-------------------------------------------------------------------------------
% [EOF]
    