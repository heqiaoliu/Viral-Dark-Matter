function p = nctcdf(x,nu,delta)
%NCTCDF Noncentral T cumulative distribution function (cdf).
%   P = NCTCDF(X,NU,DELTA) Returns the noncentral T cdf with NU
%   degrees of freedom and noncentrality parameter, DELTA, at the values
%   in X.
%
%   The size of P is the common size of the input arguments. A scalar input
%   functions as a constant matrix of the same size as the other inputs.
%
%   See also NCTINV, NCTPDF, NCTRND, NCTSTAT, TCDF, CDF.

%   References:
%      [1]  Johnson, Norman, and Kotz, Samuel, "Distributions in
%      Statistics: Continuous Univariate Distributions-2", Wiley
%      1970 p. 205.
%      [2]  Evans, Merran, Hastings, Nicholas and Peacock, Brian,
%      "Statistical Distributions, Second Edition", Wiley
%      1993 pp. 147-148.

%   Copyright 1993-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2010/03/16 00:16:08 $

if nargin <  3,
    error('stats:nctcdf:TooFewInputs','Requires three input arguments.');
end

[errorcode x nu delta] = distchck(3,x,nu,delta);

if errorcode > 0
    error('stats:nctcdf:InputSizeMismatch',...
          'Requires non-scalar arguments to match in size.');
end

% Initialize p to zero.
if isa(x,'single') || isa(nu,'single') || isa(delta,'single')
   p = zeros(size(x),'single');
   seps = eps('single');
else
   p = zeros(size(x));
   seps = eps;
end

% Special cases for delta==0 and x<0.
f1 = (nu <= 0);
f0 = (delta == 0 & ~f1);
fn = (x < 0 & ~f0 & ~f1);
flag1 = any(f1(:));
flag0 = any(f0(:));
flagn = any(fn(:));
if (flag1 || flag0 || flagn)
   fp = ~(f1 | f0 | fn);
   if flag1,        p(f1) = NaN; end
   if flag0,        p(f0) = tcdf(x(f0),nu(f0)); end
   if any(fp(:)),   p(fp) = nctcdf(x(fp), nu(fp), delta(fp)); end
   if flagn,        p(fn) = 1 - nctcdf(-x(fn), nu(fn), -delta(fn)); end
   return
end

%Value passed to Incomplete Beta function.
xsq = x.^2;
denom = nu + xsq;
P = xsq ./ denom;
Q = nu ./ denom;   % Q = 1-P but avoid roundoff if P is close to 1

% Set up for infinite sum.
dsq = delta.^2;

% Compute probability P[t<0] + P[0<t<x], starting with 1st term
p(:) = normcdf(-delta,0,1);

% Now sum a series to compute the second term
k0 = find(x~=0);
if any(k0(:))
   P = P(k0);
   Q = Q(k0);
   nu = nu(k0);
   dsq = dsq(k0);
   signd = sign(delta(k0));
   subtotal = zeros(size(k0));

   % Start looping over term jj and higher, this should be near the
   % peak of the E part of the term (see below)
   jj = 2 * floor(dsq/2);

   % Compute an infinite sum using Johnson & Kotz eq 9, or new
   % edition eq 31.16, each term having this form:
   %      B  = betainc(P,(j+1)/2,nu/2);
   %      E  = (exp(0.5*j*log(0.5*delta^2) - gammaln(j/2+1)));
   %      term = E .* B;
   %
   % We'll compute betainc at the beginning, and then update using
   % recurrence formulas (Abramowitz & Stegun 26.5.16).  We'll sum the
   % series two terms at a time to make the recurrence work out.

   E1 =          exp(0.5* jj   .*log(0.5*dsq) - dsq/2 - gammaln( jj   /2+1));
   E2 = signd .* exp(0.5*(jj+1).*log(0.5*dsq) - dsq/2 - gammaln((jj+1)/2+1));
   
   % Use either P or Q, whichever is more accurately computed
   t = (P < 0.5);   % or maybe < dsq./(dsq+nu)
   B1 = zeros(size(P));
   B2 = zeros(size(P));
   if any(t)
       B1(t) = betainc(P(t),(jj(t)+1)/2,nu(t)/2,'lower');
       B2(t) = betainc(P(t),(jj(t)+2)/2,nu(t)/2,'lower');
   end
   t = ~t;
   if any(t)
       B1(t) = betainc(Q(t),nu(t)/2,(jj(t)+1)/2,'upper');
       B2(t) = betainc(Q(t),nu(t)/2,(jj(t)+2)/2,'upper');
   end
   R1 = exp(gammaln((jj+1)/2+nu/2) - gammaln((jj+3)/2) - gammaln(nu/2) + ...
            ((jj+1)/2) .* log(P) + (nu/2) .* log(Q));
   R2 = exp(gammaln((jj+2)/2+nu/2) - gammaln((jj+4)/2) - gammaln(nu/2) + ...
            ((jj+2)/2) .* log(P) + (nu/2) .* log(Q));
   E10 = E1; E20 = E2; B10 = B1; B20 = B2; R10 = R1; R20 = R2; j0 = jj;
   todo = true(size(dsq));
   while(true)
      %Probability that t lies between 0 and x (x>0)
      twoterms = E1(todo).*B1(todo) + E2(todo).*B2(todo);
      subtotal(todo) = subtotal(todo) + twoterms;
      % Convergence test.
      todo(todo) = (abs(twoterms) > (abs(subtotal(todo))+seps)*seps);
      if (~any(todo))
         break;
      end

      % Update for next iteration
      jj = jj+2;

      E1(todo) = E1(todo) .* dsq(todo) ./ (jj(todo));
      E2(todo) = E2(todo) .* dsq(todo) ./ (jj(todo)+1);

      B1(todo) = B1(todo) - R1(todo);
      B2(todo) = B2(todo) - R2(todo);

      R1(todo) = R1(todo) .* P(todo) .* (jj(todo)+nu(todo)-1) ./ (jj(todo)+1);
      R2(todo) = R2(todo) .* P(todo) .* (jj(todo)+nu(todo)  ) ./ (jj(todo)+2);
   end

   % Go back to the peak and start looping downward as far as necessary.
   E1 = E10; E2 = E20; B1 = B10; B2 = B20; R1 = R10; R2 = R20;
   jj = j0;
   todo = (jj>0);
   while any(todo)
      JJ = jj(todo);
      E1(todo) = E1(todo) .* (JJ  ) ./ dsq(todo);
      E2(todo) = E2(todo) .* (JJ+1) ./ dsq(todo);

      R1(todo) = R1(todo) .* (JJ+1) ./ ((JJ+nu(todo)-1) .* P(todo));
      R2(todo) = R2(todo) .* (JJ+2) ./ ((JJ+nu(todo))   .* P(todo));

      B1(todo) = B1(todo) + R1(todo);
      B2(todo) = B2(todo) + R2(todo);

      twoterms = E1(todo).*B1(todo) + E2(todo).*B2(todo);
      subtotal(todo) = subtotal(todo) + twoterms;

      jj = jj - 2;
      todo(todo) = (abs(twoterms) > (abs(subtotal(todo))+seps)*seps) & ...
                   (jj(todo) > 0);
   end
   p(k0) = min(1, max(0, p(k0) + subtotal/2));
end
