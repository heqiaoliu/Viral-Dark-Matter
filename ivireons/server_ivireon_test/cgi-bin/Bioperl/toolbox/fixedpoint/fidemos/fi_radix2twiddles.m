function w = fi_radix2twiddles(n) 
%FI_RADIX2TWIDDLES  Twiddle factors for radix-2 FFT example.
%   W = FI_RADIX2TWIDDLES(N) compultes the length N-1 vector W of
%   twiddle factors to be used in the FI_M_RADIX2FFT example code.
%
%   See also FI_RADIX2FFT_DEMO.

%   Reference:
%
%   Twiddle factors for Algorithm 1.6.2, p. 45, Charles Van Loan,
%   Computational Frameworks for the Fast Fourier Transform, SIAM,
%   Philadelphia, 1992.
%
%   Copyright 2003-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2005/02/23 02:43:45 $

t = log2(n);
if floor(t) ~= t
  error('N must be an exact power of two.');
end

w = zeros(n-1,1);
k=1;
L=2;
% Equation 1.4.11, p. 34
while L<=n
  theta = 2*pi/L;
  % Algorithm 1.4.1, p. 23
  for j=0:(L/2 - 1)
    w(k) = complex( cos(j*theta), -sin(j*theta) );
    k = k + 1;
  end
  L = L*2;
end
