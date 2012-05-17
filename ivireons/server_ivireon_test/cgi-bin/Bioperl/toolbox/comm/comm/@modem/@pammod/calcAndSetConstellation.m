function calcAndSetConstellation(h, M)
%CALCANDSETCONSTELLATION Calculate and set signal constellation
% (Constellation property) for MODEM.PAMMOD object H.

%   @modem/@pammod

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/05/06 15:48:11 $

constellation = (-(M-1):2:(M-1));
% Constellation should be complex
if isreal(constellation)
    constellation = complex(constellation, 0);
end

h.Constellation = constellation;

%-------------------------------------------------------------------------------
% [EOF]
    