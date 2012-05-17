function rsConstructor(h,N,K)
%rsConstructor Helper function for RS encoder/decoder object construction

%   Copyright 2007-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/05/23 07:49:17 $

error(nargchk(3, 4, nargin));

% Parameter checks
if isempty(N) || ~isnumeric(N) || ~isscalar(N) || ~isreal(N) || N~=floor(N) || N<3
    error([getErrorId(h) ':Nval'],'N must be a real integer scalar equal to or larger than 3.');
end
if isempty(K) || ~isnumeric(K) || ~isscalar(K) || ~isreal(K) || K~=floor(K) || K<1
    error([getErrorId(h) ':kVal'],'K must be a real positive integer scalar.');
end

if N > 65535,
    error([getErrorId(h) ':nRange'],'N must be between 3 and 65535.');
end

% compute M
M = nextpow2(N+1);

if N ~= (2^M -1)
    error([getErrorId(h) ':nRange2'],'N must equal 2^m-1 for some integer m between 3 and 16.')
end

h.shortened = 0;

if M < 3
    error([getErrorId(h) ':Mval'],'Symbols to be encoded must all have 3 or more bits.');
end

h.t = floor((N-K)/2);
h.T2 = 2*h.t;       

h.nSet = false;
h.kSet = false;

h.N = N;
h.K = K;

h.nSet = true;
h.kSet = true;

genpoly = rsgenpoly(N,K);
h.GenPoly = genpoly;
h.m = genpoly.m;

h.ParityPosition = 'end';

h.PuncturePattern = true(1,N-K);

primpoly = h.GenPoly.prim_poly;
h.PrimPoly = primpoly;


