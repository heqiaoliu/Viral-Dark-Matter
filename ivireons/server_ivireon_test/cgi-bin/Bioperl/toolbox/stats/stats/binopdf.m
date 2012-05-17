function y = binopdf(x,n,p)
% BINOPDF Binomial probability density function.
%   Y = BINOPDF(X,N,P) returns the binomial probability density 
%   function with parameters N and P at the values in X.
%   Note that the density function is zero unless X is an integer.
%
%   The size of Y is the common size of the input arguments. A scalar input  
%   functions as a constant matrix of the same size as the other inputs.    
%
%   See also BINOCDF, BINOFIT, BINOINV, BINORND, BINOSTAT, PDF.

%   References:
%      [1]  M. Abramowitz and I. A. Stegun, "Handbook of Mathematical
%      Functions", Government Printing Office, 1964, 26.1.20.
%      [2]  C. Loader, "Fast and Accurate Calculations
%      of Binomial Probabilities", July 9, 2000.

%   Copyright 1993-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.3 $  $Date: 2010/05/10 17:58:35 $
if nargin < 3, 
    error('stats:binopdf:TooFewInputs','Requires three input arguments');
end

[errorcode x n p] = distchck(3,x,n,p);

if errorcode > 0
    error('stats:binopdf:InputSizeMismatch',...
          'Requires non-scalar arguments to match in size.');
end

% Initialize Y to zero.
if isa(x,'single') || isa(n,'single') || isa(p,'single')
   y = zeros(size(x),'single');
else
   y = zeros(size(x));
end
y(isnan(x) | isnan(n) | isnan(p)) = NaN;

% Binomial distribution is defined on positive integers less than N.
if ~isfloat(x)
   x = double(x);
end
if ~isfloat(n)
   n = double(n);
end
k = find(x >= 0  &  x==round(x)  &  x <= n & n==round(n) & p>=0 & p<=1);
if any(k)
   % First deal with borderline cases
   t = (p(k)==0);
   if any(t)
      kt = k(t);
      y(kt) = (x(kt)==0);
      k(t) = [];
   end
   t = (p(k)==1);
   if any(t)
      kt = k(t);
      y(kt) = (x(kt)==n(kt));
      k(t) = [];
   end
end

% More borderline cases: x=0 and x=n
if any(k)
    t = (x(k)==0);
    if any(t)
        kt = k(t);
        y(kt) = exp(n(kt).*log(1-p(kt)));
        k(t) = [];
    end
    t = (x(k)==n(k));
    if any(t)
        kt = k(t);
        y(kt) = exp(n(kt).*log(p(kt)));
        k(t) = [];
    end
end
if any(k)
    t = (n(k)<10);
    if any(t)
        % Faster method that is not accurate for large n
        K = k(t);
        nk = gammaln(n(K) + 1) - gammaln(x(K) + 1) - gammaln(n(K) - x(K) + 1);
        lny = nk + x(K).*log( p(K)) + (n(K) - x(K)).*log1p(-p(K));
        y(K) = exp(lny);
    end
    if any(~t)
        % Slower method
        K = k(~t);
        
        % Notes:
        % 1- Equation 3 in reference [2] is used to calculate the pdf.
        % 2- The second term on the RHS of Equation 3 is calculated using
        % Equation 5.
        % 3- The deviance, bd0(x,np), is equivalent to npD0(x/np) in the
        % reference, which is calculated using Equation 5.2.
        % 4- The function stirlerr(n) is the error term (delta(n)) in the
        % Stirling-De Moivre series in Equation 4.2 of the reference.
        
        % Calculate the pdf
        lc = stirlerr(n(K))-stirlerr(x(K))-stirlerr(n(K)-x(K)) ...
             -binodeviance(x(K),n(K).*p(K)) ...
             -binodeviance(n(K)-x(K),n(K).*(1.0-p(K)));
        y(K) = exp(lc).*sqrt(n(K)./(2*pi*x(K).*(n(K)-x(K))));
    end
end
k1 = find(n < 0 | p < 0 | p > 1 | round(n) ~= n); 
if any(k1)
   y(k1) = NaN;
end
end
