function s = blockparams(Hd, mapstates)
%BLOCKPARAMS Returns the parameters for BLOCK

% This should be a private method

% Author(s): V. Pellissier
% Copyright 1988-2006 The MathWorks, Inc.
% $Revision: 1.1.4.7 $ $Date: 2009/07/14 04:01:34 $

s = iir_blockparams(Hd);
s.IIRFiltStruct = 'Direct Form II transposed';

% IC
if strcmpi(mapstates, 'on'),
    s.IC = mat2str(getinitialconditions(Hd));
end

% [EOF]
