function x = fi_bitreverse(x,n)
%FI_BITREVERSE  Bit-reverse the input.
%   X = FI_BITREVERSE(x,n) bit-reverse the input sequence X, where N=length(X).
%
%   See also FI_RADIX2FFT_DEMO.

%   Thomas A. Bryan
%   Copyright 2004-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $
%#eml
nv2 = n/2;
j=1;
for i=1:(n-1)
  if i<j
    temp = x(j);
    x(j) = x(i);
    x(i) = temp;
  end
  k = nv2;
  while k<j
    j = j-k;
    k = k/2;
  end
  j = j+k;
end
