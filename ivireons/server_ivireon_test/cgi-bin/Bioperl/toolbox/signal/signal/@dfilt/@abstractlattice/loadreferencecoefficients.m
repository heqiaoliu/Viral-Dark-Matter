function loadreferencecoefficients(this, s)
%LOADREFERENCECOEFFICIENTS   Load the reference coefficients.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/12/26 22:03:00 $

if s.version.number < 2
    set(this, 'Lattice', s.Lattice);
else
    set(this, 'Lattice', s.reflattice);
end

% [EOF]
