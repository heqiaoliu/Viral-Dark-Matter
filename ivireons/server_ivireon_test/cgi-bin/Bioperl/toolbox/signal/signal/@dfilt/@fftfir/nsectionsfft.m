function n = nsectionsfft(Hd)
%NSECTIONSFFT Returns the number of sections of the FFT.
  
%   Author: V. Pellissier
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2007/12/14 15:08:38 $

nfft = nstates(Hd) + Hd.BlockLength;
n = log2(nfft);

if round(n)~=n,
    error(generatemsgid('InvalidParam'),'The length of numerator + blocklength - 1 must be a power of 2 to compute a number of sections.');
end
