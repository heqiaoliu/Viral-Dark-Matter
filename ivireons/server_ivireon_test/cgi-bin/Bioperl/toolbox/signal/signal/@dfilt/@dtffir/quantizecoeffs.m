function quantizecoeffs(h,eventData)
% Quantize coefficients


%   Author(s): R. Losada
%   Copyright 1988-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.7 $  $Date: 2005/06/16 08:18:46 $

if isempty(h.refnum)
    return;
end

% Quantize the coefficients
h.privnum = quantizecoeffs(h.filterquantizer,h.refnum);

setmaxprod(h.filterquantizer, h);
setmaxsum(h.filterquantizer, h);

% [EOF]
