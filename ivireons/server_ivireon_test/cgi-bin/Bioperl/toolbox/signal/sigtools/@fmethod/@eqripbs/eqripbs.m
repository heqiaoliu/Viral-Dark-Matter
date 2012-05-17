function this = eqripbs(DensityFactor)
%EQRIPBS   Construct an EQRIPBS object.

%   Author(s): J. Schickler
%   Copyright 1999-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2006/06/27 23:39:49 $

this = fmethod.eqripbs;

set(this, 'DesignAlgorithm', 'Equiripple');

if nargin
    set(this, 'DensityFactor', DensityFactor);
end

% [EOF]
