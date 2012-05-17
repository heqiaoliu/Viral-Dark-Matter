function s = blockparams(Hd, mapstates)
%BLOCKPARAMS Returns the parameters for BLOCK

% This should be a private method

% Author(s): V. Pellissier
% Copyright 1988-2006 The MathWorks, Inc.
% $Revision: 1.1.4.5 $ $Date: 2006/06/27 23:34:17 $

s = fir_blockparams(Hd, mapstates);

s.FIRFiltStruct = 'Direct form transposed';

% [EOF]
