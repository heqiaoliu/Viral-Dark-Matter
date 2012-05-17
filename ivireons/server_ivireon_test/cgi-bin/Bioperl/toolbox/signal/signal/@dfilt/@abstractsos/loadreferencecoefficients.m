function loadreferencecoefficients(this, s)
%LOADREFERENCECOEFFICIENTS   Load the reference coefficients.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/12/26 22:03:20 $

if s.version.number < 2
    set(this, 'sosMatrix', s.SOSMatrix, ...
        'ScaleValues', s.ScaleValues);
else
    set(this, 'sosMatrix', s.refsosMatrix, ...
        'ScaleValues', s.refScaleValues);
end

% [EOF]
