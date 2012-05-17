function s = blockparams(Hd, mapstates)
%BLOCKPARAMS Returns the parameters for BLOCK

% This should be a private method

% Author(s): V. Pellissier
% Copyright 1988-2006 The MathWorks, Inc.
% $Revision: 1.1.4.5 $ $Date: 2009/07/14 04:03:07 $

s = blockparams(Hd.filterquantizer);

% Parameters of the block
s.TypePopup = 'FIR (all zeros)';
s.FIRFiltStruct = 'Lattice MA';

s.LatticeCoeffs = mat2str(get(reffilter(Hd), 'Lattice'));

% IC
if strcmpi(mapstates, 'on'),
    s.IC = mat2str(getinitialconditions(Hd));
end

% [EOF]
