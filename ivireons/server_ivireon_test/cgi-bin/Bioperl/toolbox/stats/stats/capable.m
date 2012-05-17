function [p, Cp, Cpk] = capable(data,specs)
%CAPABLE Capability indices.
%   CAPABLE(DATA,SPECS) returns the probability that a sample from
%   the process will fall outside the specifications, SPECS.
%   The assumptions are that the measured values in DATA are normally
%   distributed with constant mean and variance and the measurements
%   are statistically independent.
%
%   SPECS is a two element vector containing a lower and upper bound. If
%   there is no lower bound, then use -Inf. Similarly, for no upper bound
%   use Inf.
%
%   [P, CP, CPK] = CAPABLE(DATA,SPECS) also returns the capability 
%   indices CP and CPK. 
%
%   CAPABLE treats NaN values in DATA as missing, and ignores them.
%
%   See also CAPABILITY, HISTFIT.

%   Reference: Montgomery, Douglas, Introduction to Statistical
%   Quality Control, John Wiley & Sons 1991 p. 369-374.

%   Copyright 1993-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2010/03/16 00:12:37 $

if numel(specs) ~= 2,
   error('stats:capable:BadSpecs','SPECS must be a two element vector.');
end

lb = specs(1);
ub = specs(2);
if lb > ub
  lb = specs(2);
  ub = specs(1);
end

if lb == -Inf && ub == Inf
   error('stats:capable:BadSpecs',...
         'The SPECS vector must have at least one finite element');
end

if ~isvector(data)
   error('stats:capable:VectorRequired','First argument has to be a vector.');
end

data = data(~isnan(data));
mu = mean(data);
sigma = std(data);

if lb == -Inf,
   p = normcdf(-ub,-mu,sigma); % P(t > ub)
   if nargout > 1
      Cp = NaN;
      Cpk = NaN;
      disp('Capability indices Cp and Cpk are undefined if there is no lower bound.');
   end
elseif ub == Inf,
   p = normcdf(lb,mu,sigma); % P(t < lb)
   if nargout > 1
      Cp = NaN;
      Cpk = NaN;
      disp('Capability indices Cp and Cpk are undefined if there is no upper bound.');
   end
else  
   p = sum(normcdf([lb -ub],[mu -mu],sigma)); % P(t < lb) + P(t > ub)
   Cp = (ub - lb)./(6.*sigma);
   Cpk = min((ub - mu)./(3.*sigma),(mu-lb)./(3.*sigma));
end


