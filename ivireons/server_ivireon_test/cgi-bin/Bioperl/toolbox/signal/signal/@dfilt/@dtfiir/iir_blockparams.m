function s = iir_blockparams(Hd)
%IIR_BLOCKPARAMS   Get the IIR-specific block parameters.

%   Author(s): J. Schickler
%   Copyright 1988-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2006/06/27 23:34:27 $

s = blockparams(Hd.filterquantizer);

% Parameters of the block
s.TypePopup = 'IIR (poles & zeros)';

refHd = reffilter(Hd);

s.NumCoeffs = mat2str(refHd.Numerator);
s.DenCoeffs = mat2str(refHd.Denominator);

% [EOF]
