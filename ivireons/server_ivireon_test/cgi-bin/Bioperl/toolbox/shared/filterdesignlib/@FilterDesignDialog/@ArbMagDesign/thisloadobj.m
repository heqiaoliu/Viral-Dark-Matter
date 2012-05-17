function thisloadobj(this, s)
%THISLOADOBJ   Load this object.

%   Author(s): J. Schickler
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2006/10/18 03:16:43 $

set(this, ...
    'SpecifyDenominator', s.SpecifyDenominator, ...
    'DenominatorOrder',   s.DenominatorOrder, ...
    'NumberOfBands',      s.NumberOfBands, ...
    'ResponseType',       s.ResponseType);

indx = 1;
bandprop = sprintf('Band%d', indx);
while ~isempty(s.(bandprop))
    this.(bandprop) = s.(bandprop);
    indx = indx + 1;
    bandprop = sprintf('Band%d', indx);
end

% [EOF]
