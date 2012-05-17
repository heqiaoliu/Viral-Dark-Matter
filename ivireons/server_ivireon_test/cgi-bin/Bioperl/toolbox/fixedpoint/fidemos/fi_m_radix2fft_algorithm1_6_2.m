function x = fi_m_radix2fft_algorithm1_6_2(x, w)
%FI_M_RADIX2FFT_ALGORITHM1_6_2  Radix-2 FFT example.
%   Y = FI_M_RADIX2FFT_ALGORITHM1_6_2(X, W) computes the radix-2 FFT of
%   input vector X with twiddle-factors W.  
%
%   The length of vector X must be an exact power of two.
%   Twiddle-factors W are computed via
%      W = FI_RADIX2TWIDDLES(N)
%   where N = length(X).
%
%   This version of the algorithm has no scaling before the stages.
%
%   See also FI_RADIX2FFT_DEMO, FI_M_RADIX2FFT_WITHSCALING.

%   Reference:
%     Charles Van Loan, Computational Frameworks for the Fast Fourier
%     Transform, SIAM, Philadelphia, 1992, Algorithm 1.6.2, p. 45.
% 
%   Thomas A. Bryan
%   Copyright 2004-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2009/05/14 16:53:23 $ 

n = length(x);  t = log2(n);
x = fi_bitreverse(x,n);
for q=1:t
  L = 2^q; r = n/L; L2 = L/2;
  for k=0:(r-1)
    for j=0:(L2-1)
      temp          = w(L2-1+j+1) * x(k*L+j+L2+1);
      x(k*L+j+L2+1) = x(k*L+j+1)  - temp;
      x(k*L+j+1)    = x(k*L+j+1)  + temp;
    end
  end
end
