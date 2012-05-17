function num = setnumerator(Hd, num)
%SETNUMERATOR Overloaded set on the Numerator property.
  
%   Author: R. Losada
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.4.4.3 $  $Date: 2004/12/26 22:05:33 $

% Calculate the FFTCOEFFS first because DTFWNUM_SETNUMERATOR returns [].
fftcoeffs = fft(num(:),Hd.BlockLength+length(num)-1);

% Call super method
num = dtfwnum_setnumerator(Hd, num);

Hd.fftcoeffs = fftcoeffs(:); % In case num is a scalar

% [EOF]
