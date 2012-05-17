function gfcs = gfcosets(m, p)
%GFCOSETS Produce cyclotomic cosets for a Galois field.
%   GFCS = GFCOSETS(M) produces cyclotomic cosets mod(2^M - 1). Each row of the
%   output GFCS contains one cyclotomic coset.
%
%   GFCS = GFCOSETS(M, P) produces cyclotomic cosets mod(P^M - 1), where 
%   P is a prime number.
%       
%   Because the length of the cosets varies in the complete set, NaN is used to
%   fill out the extra space in order to make all variables have the same
%   length in the output matrix GFCS.
%
%   Note: This function performs computations in GF(P^M) where P is prime. To
%   work in GF(2^M), you can also use the COSETS function.
%
%   See also GFMINPOL, GFPRIMDF, GFROOTS.

%   Copyright 1996-2007 The MathWorks, Inc.
%   $Revision: 1.14.4.4 $   $Date: 2007/08/03 21:17:35 $                

% Error checking.
error(nargchk(1,2,nargin,'struct'));

% Error checking - P.
if nargin < 2
    p = 2;
elseif ( isempty(p) || numel(p)~=1 || abs(p)~=p || floor(p)~=p || ~isprime(p) )
    error('comm:gfcosets:InvalidP','The field parameter P must be a positive prime integer.');
end

% Error checking - M.
if ( isempty(m) || numel(m)~=1 || ~isreal(m) || floor(m)~=m || m<1 )
    error('comm:gfcosets:InvalidM','M must be a real positive integer.');
end

% The cyclotomic coset containing s is 
% {s, s^p, s^(p^2),...,s^(p^(k-1))}, where
% k is the smallest positive integer such that s^(p^k) = s.

% Special case, P=2 & M=1.
if ( ( p == 2 ) && ( m == 1 ) )
    i = [];
else
    i = 1;
end

n = p^m - 1;
gfcs = [];                   % used for the output
ind = ones(1, n - 1);      % used to register unprocessed numbers.

while ~isempty(i)

   % to process numbers that have not been done before.
   ind(i) = 0;             % mark the register
   s = i;
   v = s;
   pk = rem(p*s, n);       % the next candidate

   % build cyclotomic coset containing s=i
   while (pk > s)
          ind(pk) = 0;    % mark the register
          v = [v pk];     % recruit the number
          pk = rem(pk * p, n);    % the next candidate
   end;

   % append the coset to gfcs
   [m_cs, n_cs] = size(gfcs);
   [m_v, n_v ]  = size(v);
   if (n_cs == n_v) || (m_cs == 0)
          gfcs = [gfcs; v];
   elseif (n_cs > n_v)
          gfcs = [gfcs; [v, ones(1, n_cs - n_v) * NaN]];
   else
          % this case should not happen, in general.
          gfcs = [[gfcs, ones(m_cs, n_v - n_cs) * NaN]; v];
   end;
   i = find(ind == 1,1,'first');        % the next number.

end;

% add the number "0" to the first coset
[m_cs, n_cs] = size(gfcs);
gfcs = [[0, ones(1, n_cs - 1) * NaN]; gfcs];

%--end of GFCOSETS--


