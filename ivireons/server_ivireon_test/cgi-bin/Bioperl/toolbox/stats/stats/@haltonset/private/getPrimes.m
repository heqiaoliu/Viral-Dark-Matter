function P = getPrimes(N)
%GETPRIMES Find the first N prime numbers
%   GETPRIMES(N) returns a vector containing the first N primes.
    
%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $    $Date: 2010/03/16 00:20:50 $

% We hold a vector of the first 100 primes so we don't have to generate
% them again and again.
persistent LowPrimes
if isempty(LowPrimes)
    LowPrimes = iGetPrimes(100);
end

if N<=100
    P = LowPrimes(1:N);
else
    P = iGetPrimes(N);
end



function P = iGetPrimes(N)
% Find first N prime numbers
k = 4;
P = [];
while length(P)<N
    P = primes(k*N);
    k = k*2;
end
P = P(1:N);
