function quantizecoeffs(h,eventData)
% Quantize coefficients

%   Author(s): R. Losada
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2004/06/06 16:54:57 $

% Quantize the coefficients

if isempty(h.refnum) || isempty(h.refden)
    return;
end

% Add check for a0 ~= 1
if ~strcmpi(class(h.filterquantizer), 'dfilt.filterquantizer'),
    if any(h.refden(1,1)~=1),
        error(generatemsgid('invalidA0'), ...
            ['The leading coefficient of the denominator a(1) must be 1.']);
    end
end

[h.privnum,h.privden] = quantizecoeffs(h.filterquantizer,h.refnum,h.refden);

% [EOF]
