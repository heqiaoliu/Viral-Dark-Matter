function s = thissaveobj(this, s)
%THISSAVEOBJ   Save this object.

%   Author(s): J. Schickler
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2006/10/18 03:16:44 $

s.SpecifyDenominator = get(this, 'SpecifyDenominator');
s.DenominatorOrder   = get(this, 'DenominatorOrder');
s.NumberOfBands      = get(this, 'NumberOfBands');
s.ResponseType       = get(this, 'ResponseType');

for indx = 1:10
    bandprop = sprintf('Band%d', indx);
    s.(bandprop) = get(this, bandprop);
end

% [EOF]
