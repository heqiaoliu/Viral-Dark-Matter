function quantizecoeffs(h,eventData)
% Quantize coefficients


%   Author(s): R. Losada
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2004/06/06 16:55:17 $

if isempty(h.refgain)
    return;
end

% Quantize the coefficients
h.privgain = quantizecoeffs(h.filterquantizer,h.refgain);

% [EOF]
