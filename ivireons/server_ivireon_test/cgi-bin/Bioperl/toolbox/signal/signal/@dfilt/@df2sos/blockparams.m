function s = blockparams(Hd, mapstates)
%BLOCKPARAMS   Return the block parameters.

%   Author(s): J. Schickler
%   Copyright 1988-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.8 $  $Date: 2009/07/14 04:01:30 $

s = super_blockparams(Hd);
s.IIRFiltStruct = 'Direct form II';

% IC
if strcmpi(mapstates, 'on'),
    ic = getinitialconditions(Hd);
    s.IC  = mat2str(ic);
end


% [EOF]
