function s = fir_blockparams(Hd, mapstates)
%FIR_BLOCKPARAMS   Return the fir specific block parameters.

%   Author(s): J. Schickler
%   Copyright 1988-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2009/07/14 04:01:57 $

   
s = blockparams(Hd.filterquantizer);

% Parameters of the block
s.TypePopup = 'FIR (all zeros)';

s.NumCoeffs = mat2str(get(reffilter(Hd), 'Numerator'));

% IC
if strcmpi(mapstates, 'on'),
    s.IC = mat2str(getinitialconditions(Hd));
end


% [EOF]
