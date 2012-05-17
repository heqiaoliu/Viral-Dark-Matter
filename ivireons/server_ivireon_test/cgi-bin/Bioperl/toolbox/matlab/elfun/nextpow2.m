function p = nextpow2(n)
%NEXTPOW2 Next higher power of 2.
%   NEXTPOW2(N) returns the first P such that 2.^P >= abs(N).  It is
%   often useful for finding the nearest power of two sequence
%   length for FFT operations.
%
%   Class support for input N:
%      float: double, single
%
%   See also LOG2, POW2.

%   Copyright 1984-2009 The MathWorks, Inc. 
%   $Revision: 5.11.4.4 $  $Date: 2009/07/06 20:37:15 $

[f,p] = log2(abs(n));

% Check for exact powers of 2.
k = (f == 0.5);
p(k) = p(k)-1;

% Check for infinities and NaNs
k = ~isfinite(f);
p(k) = f(k);
