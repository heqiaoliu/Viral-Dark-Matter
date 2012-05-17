function y = modulate_Bit(h, x)
%MODULATE_BIT Modulate binary/bit signal X using modulator object H. Return 
% baseband modulated signal Y.

% @modem/@abstractMod

%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2006/10/10 02:10:12 $

% Check input signal size
checkModInputSizeBit(h, x);

% convert binary works (bits) to symbols (integers)
x = convertBits2Integers(h, x);

%compute output
y = computeModOutput(h, x);

%--------------------------------------------------------------------
% [EOF]
