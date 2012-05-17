function c = coeffs(this)
%COEFFS   Returns the coefficients.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/12/26 22:07:50 $

% Add a field for each of the stages with that stage's coefficients.
for indx = 1:nstages(this)
    c.(sprintf('Stage%d', indx)) = coeffs(this.Stage(indx));
end

% [EOF]
