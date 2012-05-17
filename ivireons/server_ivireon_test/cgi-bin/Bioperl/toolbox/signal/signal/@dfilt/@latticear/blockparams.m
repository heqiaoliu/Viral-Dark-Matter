function s = blockparams(Hd, mapstates)
%BLOCKPARAMS Returns the parameters for BLOCK

% This should be a private method

% Author(s): V. Pellissier
% Copyright 1988-2006 The MathWorks, Inc.
% $Revision: 1.1.4.5 $ $Date: 2009/07/14 04:02:56 $


s = blockparams(Hd.filterquantizer);

% Parameters of the block
s.TypePopup = 'IIR (all poles)';
s.AllPoleFiltStruct = 'Lattice AR';

s.LatticeCoeffs = mat2str(Hd.Lattice);

% IC
if strcmpi(mapstates, 'on'),
    s.IC = mat2str(getinitialconditions(Hd));
end

% [EOF]
