function s = blockparams(Hd, mapstates)
%BLOCKPARAMS Returns the parameters for BLOCK

% This should be a private method

% Author(s): V. Pellissier
% Copyright 1988-2006 The MathWorks, Inc.
% $Revision: 1.1.4.9 $ $Date: 2009/07/14 04:01:43 $

s = super_blockparams(Hd);
s.IIRFiltStruct = 'Direct form II transposed';

% IC
if strcmpi(mapstates, 'on'),
    ic    = getinitialconditions(Hd);
    s.IC  = mat2str(ic);
end

% [EOF]
