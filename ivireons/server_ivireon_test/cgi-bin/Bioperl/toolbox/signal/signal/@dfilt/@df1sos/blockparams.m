function s = blockparams(Hd, mapstates)
%BLOCKPARAMS Returns the parameters for BLOCK

% This should be a private method

% Author(s): V. Pellissier
% Copyright 1988-2006 The MathWorks, Inc.
% $Revision: 1.1.6.8 $ $Date: 2009/07/14 04:01:11 $

s = super_blockparams(Hd);
s.IIRFiltStruct = 'Direct form I';

% IC
if strcmpi(mapstates, 'on'),
    ic  = getinitialconditions(Hd);    
    s.ICNum = mat2str(ic.Num);
    s.ICDen = mat2str(ic.Den);
end


% [EOF]
