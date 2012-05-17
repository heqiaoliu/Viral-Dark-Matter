function resetThresholds(ntx)
% Establish initial overflow and underflow thresholds, based on
% .BAILMagInteractive and .BAFLMagInteractive.
%
% LastUnder and LastOver are the exponents N of the magnitude value 2^N.
% If the initial values 2^N (given by BAILMagInteractive, etc) are not
% powers of 2, meaning N is not an integer, N is rounded up for overflow
% and down for underflow, in order to be conservative.
%
% BAILMagInteractive and BAFLMagInteractive must be integers > 0,
% otherwise a warning is produced.

% Establish underflow and overflow vertical cursor x-coords
%  - Assumed to be positive integer values

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $     $Date: 2010/03/31 18:21:45 $

% Rounding up implies the next-higher power-of-2
v = ntx.hBitAllocationDialog.BAILMagInteractive;
if v<=0
    warning(generatemsgid('InvalidPropertyValue'), ...
        'Property "BAILMagInteractive" must be > 0.');
    v = 2^3; % 8
end
ntx.LastOver = ceil(log2(v));

v = ntx.hBitAllocationDialog.BAFLMagInteractive;
if v<=0
    warning(generatemsgid('InvalidPropertyValue'), ...
        'Property "BAFLMagInteractive" must be > 0.');
    v = 2^-3; % 1/8
end
ntx.LastUnder = floor(log2(v));
