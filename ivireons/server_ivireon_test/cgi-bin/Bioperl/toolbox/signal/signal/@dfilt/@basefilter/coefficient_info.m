function [p, v] = coefficient_info(this)
%COEFFICIENT_INFO   Get the coefficient information for this filter.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/10/18 21:00:29 $

coeffs = coefficients(this);
if length(coeffs) == 1
    p = {'Filter Length'};
    v = {sprintf('%d', length(coeffs{1}))};
else
    coeffnames = coefficientnames(this);
    for indx = 1:length(coeffs)
        p{indx} = sprintf('%s Length', coeffnames{indx});
        v{indx} = sprintf('%d', length(coeffs{indx}));
    end
end

% [EOF]
