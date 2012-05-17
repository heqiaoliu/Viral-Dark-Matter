function str = capability(data,specs)
%CAPABILITY Capability indices.
%   STR=CAPABILITY(DATA,SPECS) returns a structure STR containing a variety
%   of capability indices for the specified data.  DATA may be either a
%   vector or a matrix of measurements.  SPECS is a two-element vector
%   containing lower and upper specification limits.  The indices are
%   computed under the assumption that the DATA values come from a process
%   that can be described by a normal distribution with constant mean and
%   variance, and that the data values are independent.
%
%   If DATA is a matrix, CAPABILITY operates on the columns.  SPECS may be
%   either a two-element vector, or a two-row matrix with the same number
%   of columns as DATA.
%
%   The output STR is a structure with the following fields:
%       mu      sample mean
%       sigma   sample standard deviation
%       P       estimated probability of being within limits
%       Pl      estimated probability of being below L (lower spec)
%       Pu      estimated probability of being above U (upper spec)
%       Cp      (U-L)/(6*sigma)
%       Cpl     (mu-L)./(3.*sigma)
%       Cpu     (U-mu)./(3.*sigma)
%       Cpk     min(Cpl, Cpu)
%
%   When there is no lower bound, use -Inf as the first element of SPECS.
%   Similarly, use Inf as the second element when there is no upper bound.
%
%   CAPAPLOT treats NaN values in DATA as missing, and ignores them.
%
%   See also CAPAPLOT, HISTFIT.

%   Reference: Montgomery, Douglas, Introduction to Statistical
%   Quality Control, John Wiley & Sons 1991 p. 369-374.

%   Copyright 2006-2009 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $  $Date: 2010/03/16 00:12:36 $

error(nargchk(2,2,nargin,'struct'));

if ~isnumeric(data) || ndims(data)>2
   error('stats:capability:BadData','DATA must be a vector or matrix.');
end
if isvector(data)
    data = data(:);
end
[n,m] = size(data);

if m==1
    if ~isnumeric(specs) || numel(specs)~=2
        error('stats:capability:BadSpecs',...
       'SPECS must be a vector of lower and upper specification limits.');
    end
    specs = specs(:);
else
    if numel(specs)==2 && isnumeric(specs)
        specs = repmat(specs(:),1,m);
    elseif ~isnumeric(specs) || ~isequal(size(specs),[2 m])
        error('stats:capability:BadSpecs',...
     'SPECS must be a 2-element vector or 2-by-%d matrix of specification limits.',m);
    end  
end

t = specs(2,:) < specs(1,:);
if any(t)
    specs([1 2],t) = specs([2 1],t);
end
lb = specs(1,:);
ub = specs(2,:);
lb(isnan(lb)) = -Inf;  % for convenience, make the obvious correction
ub(isnan(ub)) = Inf;

if any(isinf(lb) & isinf(ub))
   error('stats:capability:BadSpecs',...
         'The SPECS argument cannot have both lower and upper bounds infinite.');
elseif any(lb==ub)
   error('stats:capability:BadSpecs',...
         'The SPECS argument cannot have equal lower and upper bounds.');
end

% Compute distribution parameters
mu = nanmean(data);
sigma = nanstd(data);

% Compute probabilities for being in or out of spec limits
Pl = normcdf(lb,mu,sigma);
Pu = normcdf(-ub,-mu,sigma); % = 1-normcdf(ub,mu,sigma)
P  = 1 - (Pl + Pu);

% Set up arrays for indices, then compute where they are defined
Cp = NaN(1,m);
Cpl = NaN(1,m);
Cpu = NaN(1,m);

t = isfinite(ub) & isfinite(lb);
Cp(t) = (ub(t) - lb(t))./(6.*sigma(t));

t = isfinite(lb);
Cpl(t) = (mu(t)-lb(t))./(3.*sigma(t));

t = isfinite(ub);
Cpu(t) = (ub(t) - mu(t))./(3.*sigma(t));

Cpk = min(Cpl,Cpu);

% Create output structure
str.mu = mu;
str.sigma = sigma;
str.P = P;
str.Pl = Pl;
str.Pu = Pu;
str.Cp = Cp;
str.Cpl = Cpl;
str.Cpu = Cpu;
str.Cpk = Cpk;
