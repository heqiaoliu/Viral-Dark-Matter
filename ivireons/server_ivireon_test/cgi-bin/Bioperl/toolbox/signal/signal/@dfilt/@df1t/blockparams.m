function s = blockparams(Hd, mapstates)
%BLOCKPARAMS Returns the parameters for BLOCK

% This should be a private method

% Author(s): V. Pellissier
% Copyright 1988-2006 The MathWorks, Inc.
% $Revision: 1.1.4.9 $ $Date: 2009/07/14 04:01:17 $

s = iir_blockparams(Hd);
s.IIRFiltStruct = 'Direct Form I transposed';

% IC
if strcmpi(mapstates, 'on'),
  ic = getinitialconditions(Hd);

  s.ICDen = mat2str(ic.Den);
  s.ICNum = mat2str(ic.Num);
end

% [EOF]
