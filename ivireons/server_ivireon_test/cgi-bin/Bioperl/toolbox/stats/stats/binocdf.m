function y = binocdf(x,n,p)
%BINOCDF Binomial cumulative distribution function.
%   Y=BINOCDF(X,N,P) returns the binomial cumulative distribution
%   function with parameters N and P at the values in X.
%
%   The size of Y is the common size of the input arguments. A scalar input  
%   functions as a constant matrix of the same size as the other inputs.    
%
%   The algorithm uses the cumulative sums of the binomial masses.
%
%   See also BINOFIT, BINOINV, BINOPDF, BINORND, BINOSTAT, CDF.

%   Reference:
%      [1]  M. Abramowitz and I. A. Stegun, "Handbook of Mathematical
%      Functions", Government Printing Office, 1964, 26.1.20.

%   Copyright 1993-2007 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $  $Date: 2010/03/16 00:12:22 $

if nargin < 3, 
    error('stats:binocdf:TooFewInputs','Requires three input arguments.'); 
end 

scalarnp = isscalar(n) & isscalar(p);

[errorcode x n p] = distchck(3,x,n,p);

if errorcode > 0
    error('stats:binocdf:InputSizeMismatch',...
          'Requires non-scalar arguments to match in size.');
end

% Initialize Y to 0.
if isa(x,'single') || isa(n,'single') || isa(p,'single')
   y = zeros(size(x),'single');
else
   y = zeros(size(x));
end

% Y = 1 if X >= N
y(x >= n) = 1;

% assign 1 to p==0 indices.
k2 = (p==0 & x>=0);
y(k2) = 1;

% assign 0 to p==1 indices
k3 = (p == 1);
y(k3) = x(k3)>=n(k3);

% Return NaN if any arguments are outside of their respective limits.
% this may overwrite k2 indices.
k1 = (n < 0 | p < 0 | p > 1 | round(n) ~= n); 
y(k1) = NaN;

% Compute Y when 0 < X < N.
xx = floor(x);
if ~isfloat(xx)
   xx = double(xx);
end
k = find(xx >= 0 & xx < n & ~k1 & ~k2 & ~k3);
k = k(:);

% Compute the values not handled above as special cases
if any(k)
    smallp = 1e-4;  % to maintain accuracy, don't switch tails below here
    bign = 1e5;     % to conserve memory, sum over smaller range above here
    
    % for the simplest case, sum the probabilities from 0
    np = n(k).*p(k);
    t = (n(k)<bign) & ((x(k) <= np) | (p(k)<smallp));
    if any(t)
        kt = k(t);
        y(kt) = sumfrom0(xx(kt),n(kt),p(kt),scalarnp);
    end
    done = t;
    
    % get more accuracy by summing from the other direction in the upper
    % tail
    t = (n(k)<bign) & ~done;
    if any(t)
        kt = k(t);
        y(kt) = 1 - sumfrom0(n(kt)-xx(kt)-1,n(kt),1-p(kt),scalarnp);
        done = done | t;
    end
    
    % for the remaining cases, sum over a narrower range
    if any(~done)
        kt = k(~done);
        y(kt) = sumA2B(xx(kt),n(kt),p(kt));
    end 
end

% Make sure that round-off errors never make P greater than 1.
y(y > 1) = 1;

%--------------------------
function y = sumfrom0(xx,n,p,scalarnp)
% sum series starting from 0

val = max(xx(:));
i = (0:val)';
if scalarnp
    tmp = cumsum(binopdf(i,n(1),p(1)));
    y = tmp(xx + 1);
else
    compare = i(:,ones(size(xx)));
    index = xx;
    index = index(:);
    index = index(:,ones(size(i)))';
    nbig = n;
    nbig = nbig(:);
    nbig = nbig(:,ones(size(i)))';
    pbig = p;
    pbig = pbig(:);
    pbig = pbig(:,ones(size(i)))';
    y0 = binopdf(compare,nbig,pbig);
    y0(compare > index) = 0;
    y = sum(y0,1);
end

%---------------------------
function y = sumA2B(x,N,p)
% sum series from A to B, with these selected to avoid negligible values

y = zeros(size(x));
done = false(size(x));
for j=1:numel(x)
    if done(j)    % may have been done along with some other points
        continue
    end
    
    % See how far we need to look into each tail
    mu = N(j)*p(j);
    std = sqrt(N(j)*p(j)*(1-p(j)));
    t1=40;
    t2=10;
    while(binopdf(floor(mu-t1*std),N(j),p(j))>eps(0))
        t1 = 1.5*t1;
    end
    while binopdf(ceil(mu+t2*std),N(j),p(j))>eps(1);
        t2 = 1.5*t2;
    end

    % find the limits for the sum
    t = find(N==N(j) & p==p(j));
    xt = x(t);
    a = max(0, floor(mu-t1*std));  % lower limit of sum
    b = ceil(mu+t2*std);           % upper limit of sum

    % outside limits, set to known values
    y(t(xt<a)) = 0;
    y(t(xt>b)) = 1;

    % sum inside limits
    t = t(xt>=a & xt<=b);
    if any(t)
        xmax = max(x(x<=b));
        tmp = cumsum(binopdf(a:xmax,N(j),p(j)));
        y(t) = tmp(x(t)-a+1);
        done(t) = true;
    end
end


