function this = eqriplpmin(DensityFactor)
%EQRIPLPMIN   Construct an EQRIPLPMIN object.

%   Author(s): J. Schickler
%   Copyright 1999-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2006/06/27 23:39:57 $

this = fmethod.eqriplpmin;

set(this, 'DesignAlgorithm', 'Equiripple');

if nargin
    set(this, 'DensityFactor', DensityFactor);
end

% [EOF]
