function y = convertIntegers2Bits(h, x)
%CONVERTINTEGERS2BITS Convert symbols/integers stored in X to bits/binary words. 

% @modem/@abstractDemod

%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2006/05/31 02:45:26 $

nbits = log2(h.M);
sizeX = size(x);
x = x(:);
y = rem(floor(x*pow2(1-nbits:0)),2);
y = y';
y = reshape(y, sizeX(1)*nbits, sizeX(2));

%--------------------------------------------------------------------
% [EOF]
        