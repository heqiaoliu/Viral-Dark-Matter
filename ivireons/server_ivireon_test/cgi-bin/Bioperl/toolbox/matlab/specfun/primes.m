function p = primes(n)
%PRIMES Generate list of prime numbers.
%   PRIMES(N) is a row vector of the prime numbers less than or 
%   equal to N.  A prime number is one that has no factors other
%   than 1 and itself.
%
%   Class support for input N:
%      float: double, single
%
%   See also FACTOR, ISPRIME.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.16.4.2 $  $Date: 2004/07/05 17:02:09 $

if length(n)~=1 
  error('MATLAB:primes:InputNotScalar', 'N must be a scalar'); 
end
if n < 2, p = zeros(1,0,class(n)); return, end
p = 1:2:n;
q = length(p);
p(1) = 2;
for k = 3:2:sqrt(n)
  if p((k+1)/2)
     p(((k*k+1)/2):k:q) = 0;
  end
end
p = p(p>0);

