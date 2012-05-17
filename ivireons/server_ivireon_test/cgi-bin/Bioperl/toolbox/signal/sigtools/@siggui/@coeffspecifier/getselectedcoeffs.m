function coeffs = getselectedcoeffs(hCoeff)
%GETSELECTEDCOEFFS Returns the coefficients for the selected structure
%   GETSELECTEDCOEFFS Returns the coefficients for the currently selected
%   filter structure.

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.3 $  $Date: 2002/04/14 23:19:10 $

shortstruct = getshortstruct(hCoeff,'struct');
all_coeffs  = get(hCoeff,'Coefficients');
coeffs      = getfield(all_coeffs,shortstruct);

% [EOF]
