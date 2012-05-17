function rnd = nbinrnd(r,p,varargin)
%NBINRND Random arrays from the negative binomial distribution.
%   RND = NBINRND(R,P,M,N) returns an array of random numbers chosen from a
%   negative binomial distribution with parameters R and P.  The size of RND
%   is the common size of R and P if both are arrays.  If either parameter
%   is a scalar, the size of RND is the size of the other parameter.
%   
%   RND = NBINRND(R,P,M,N,...) or RND = NBINRND(R,P,[M,N,...]) returns an
%   M-by-N-by-... array. 
%
%   See also NBINCDF, NBININV, NBINPDF, NBINSTAT, RANDOM.

%   NBINRND uses either a sum of geometric random values, or a
%   Poisson/gamma mixture.

%   Copyright 1993-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2010/03/16 00:16:01 $

if nargin < 2
    error('stats:nbinrnd:TooFewInputs','Requires at least two input arguments.'); 
end

[err, sizeOut] = statsizechk(2,r,p,varargin{:});
if err > 0
    error('stats:nbinrnd:InputSizeMismatch','Size information is inconsistent.');
end

if isscalar(r), r = repmat(r,sizeOut); end
if isscalar(p), p = repmat(p,sizeOut); end

if isa(r,'single') || isa(p,'single')
   rnd = zeros(size(r),'single');
else
   rnd = zeros(size(r));
end

% Out of range or missing parameters return NaN.  Infinite values for
% R correspond to a Poisson, but its mean cannot be determined from the
% (R,P) parametrization.
nans = ~(0 < r & isfinite(r) & 0 < p & p <= 1);
rnd(nans) = NaN;

k = find(~nans);
rlong = r(k); 
maxr = max(rlong(:));
nout = prod(sizeOut);

% Generate Poisson random values mixed on gamma random values.
if any(round(rlong) ~= rlong  |  rlong > 50) ...
        || (~isempty(maxr) && maxr*nout>1e6)
    rnd(k) = poissrnd(randg(rlong) .* (1-p(k))./p(k));
    
% Generate a sum of geometric random values.  This "discrete" generator
% is slow when R is large and may run out of memory if the product of
% R and the number of output elements is large.
elseif any(k)
    rlong = rlong(:)';
    plong = p(k); plong = plong(:)';
    if maxr == 1
        rnd(k) = geornd(plong);
    else
        pbig = plong(ones(maxr,1),:);
        gr = geornd(pbig);

        count = length(plong);
        kk = (0:count-1);
        mask = zeros(maxr,count);
        mask(kk*maxr+rlong)=ones(count,1);
        mask = 1 - cumsum(mask) + mask; 
        rnd(k) = sum(gr .* mask);
    end
end