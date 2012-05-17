function pl = gfminpol(k, prim_poly, p)
%GFMINPOL Find the minimal polynomial of an element of a Galois field.
%   PL = GFMINPOL(K, M) produces a minimal polynomial for each entry in K.
%   K must be either a scalar or a column vector.  Each entry in K represents
%   an element of GF(2^M) in exponential format.  That is, K represents
%   alpha^K, where alpha is a primitive element in GF(2^M).  The ith row of
%   PL represents the minimal polynomial of K(i).  The coefficients of the
%   minimal polynomial are in the base field GF(2) and listed in order of
%   ascending exponents.
%
%   PL = GFMINPOL(K, PRIM_POLY) is the same, except that PRIM_POLY is
%   a vector giving the coefficients of a primitive polynomial for GF(2^M)
%   in order of ascending exponents.  M is the degree of PRIM_POLY.
%
%   PL = GFMINPOL(K, M, P) is the same as PL = GFMINPOL(K, M) except that
%   2 is replaced by a prime number P.
%
%   PL = GFMINPOL(K, PRIM_POLY, P) is the same as PL = GFMINPOL(K, PRIM_POLY)
%   except that 2 is replaced by a prime number P.
%
%   Note: This function performs computations in GF(P^M) where P is prime. To
%   work in GF(2^M), you can also use the MINPOL function with Galois arrays.
%
%   See also GFPRIMDF, GFCOSETS, GFROOTS.

%   Copyright 1996-2007 The MathWorks, Inc.
%   $Revision: 1.15.4.5 $   $Date: 2007/08/03 21:17:38 $                

% Error checking.
error(nargchk(2,3,nargin,'struct'));

% Error checking - P.
if nargin < 3
    p = 2;
elseif ( isempty(p) || numel(p)~=1 || abs(p)~=p || floor(p)~=p || ~isprime(p) )
    error('comm:gfminpol:InvalidP','P must be a real prime scalar.');
end;

[m_p n_p] = size(prim_poly);

% Error checking - PRIM_POLY/M.
if ( isempty(prim_poly) || ndims(prim_poly)>2 || m_p>1 )
    error('comm:gfminpol:InvalidSecondArg','The second parameter must be either a scalar or a row vector.');
end
if n_p < 2
    m = prim_poly;
    % Error checking - M.
    if ( ~isreal(m) || m<1 || floor(m)~=m )
        error('comm:gfminpol:InvalidM','M must be a real positive integer.');
    end
    prim_poly = gfprimdf(m, p);
else
    % Error checking - PRIM_POLY.
    if ( any( abs(prim_poly)~=prim_poly | floor(prim_poly)~=prim_poly | prim_poly>=p ) )
        error('comm:gfminpol:InvalidPrim_poly','Elements in PRIM_POLY must be real nonnegative integers less than P.');
    end
    if ( prim_poly(1)==0 || prim_poly(n_p)~=1 )
        error('comm:gfminpol:Prim_polyNotMonic','PRIM_POLY must be a monic primitive polynomial.');
    end
    m = n_p - 1;
end

[m_k n_k] = size(k);

% Error checking - K.
if ( isempty(k) || ndims(k)>2 || (n_k>1 && m_k>1) )
    error('comm:gfminpol:InvalidK','K must be either a scalar or a vector.');
end
if ( ~isreal(k) || any( floor(k)~=k ) )
    error('comm:gfminpol:KElementNotInt','Elements in K must be real integers.');
end
if ( any( isinf(k) & k>0 ) )  % maybe not?  maybe k>10^16?
    error('comm:gfminpol:InvalidKElement','Elements in K cannot be +Inf.');
end

k = k(:);
m_k = size(k,1);

q = p^m;

% Allocate space for the result.
pl=-Inf*ones(m_k,m+1);

% Define -1 for the field, in exponential form ( alpha^MinusOne = -1 ).
if p>2
   MinusOne=(q-1)/2;
elseif p==2
   MinusOne=0;  % alpha^0 = 1 = -1 in GF(2).
end

% Special case: the polynomial x, in exponential form.
pl(k<0,2) = 0;

% Special case: the polynomial x-1, in exponential form.
idx = find(k==0);
pl(idx,1:2) = [ MinusOne*ones(length(idx),1) zeros(length(idx),1) ];

% Typical case.
idxPos = find(k>0);
k(idxPos) = mod(k(idxPos),q-1); % alpha^(q-1) = alpha^0 etc.

% Create matrix listing all elements of the field.
field = gftuple((-1 : q-2)', prim_poly, p);

% Elements in the same row are conjugates in the field.
cosets = gfcosets(m,p);

len = length(idxPos);
for i = 1:len,

    % Find the conjugates of the current k.
    [row ignored] = find(cosets==k(idxPos(i)));  %#ok

    % Remove the NaN elements from the list of conjugates.
    conjugates = cosets(row,~isnan(cosets(row,:)));

    % Find additive inverse of these elements in exponential form.
    % -(alpha^k) == (-1)*(alpha^k) == (alpha^MinusOne)*(alpha^k) == alpha^(MinusOne + k)
    MinusRoots = mod( MinusOne + conjugates , q-1 );

    % Minimal polynomial is product of x-alpha^j,
    % where j runs over all the conjugates of the current k.
    pl_temp=[MinusRoots(1) 0];
    for j=2:length(MinusRoots),
      pl_temp=gfconv(pl_temp,[MinusRoots(j) 0],field);
    end
    pl(idxPos(i),1:length(pl_temp))=pl_temp;
end

% So far PL gives the minimal polynomials in exponential format.
% Convert coefficients from exponential format to polynomial format.

% Convert -Inf returned by GFCONV to -1.
pl(isinf(pl)) = -1;

% Convert exponential representation into indexes into FIELD matrix.
if (q>2)
    pl = rem(pl,q-1)+2;
else
    pl = pl + 2;    % Special case: P=2, M=1.
end

% They will be elements of the ground field GF(p).
% Only need 1st element since the rest are 0s anyway.
pl = field( pl , 1 );
pl = reshape(pl,m_k,m+1);

% If just a single minimum polynomial is returned, then remove high-order zeros.
if ( m_k == 1 )
    pl = gftrunc(pl);
end

%EOF