function s = blockparams(Hd, mapstates)
%BLOCKPARAMS Returns the parameters for BLOCK

% This should be a private method

% Author(s): V. Pellissier
% Copyright 1988-2006 The MathWorks, Inc.
% $Revision: 1.2.4.4 $ $Date: 2006/06/27 23:34:29 $


% Parameters of the block
Nfft = Hd.BlockLength+Hd.ncoeffs-1;
B_Nfft = 2^nextpow2(Nfft);
if B_Nfft==Nfft,
    s.Nfft = num2str(Nfft);
else
    suggested_BlockLength = B_Nfft-Hd.ncoeffs+1;
    error(generatemsgid('InvalidNFFT'), ['NFFT = BlockLength + length(Numerator) ', ...
        '-1 must be a power of 2 in the block. Change the ', ...
        'BlockLength to ', num2str(suggested_BlockLength),'.']);
end
s.h = mat2str(Hd.Numerator);

if ~isreal(Hd.Numerator),
    s.output_complexity = 'Complex';
end

% IC
if strcmpi(mapstates, 'on'),
    warning(generatemsgid('mappingstates'), ['Can''t specify initial conditions for the ', srcblk, ' block.']);
end
% [EOF]
