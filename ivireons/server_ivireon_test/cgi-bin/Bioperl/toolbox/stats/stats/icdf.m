function x = icdf(name,p,varargin)
%ICDF Inverse cumulative distribution function for a specified distribution.
%   X = ICDF(NAME,P,A) returns an array of values of the inverse cumulative
%   distribution function for the one-parameter probability distribution
%   specified by NAME with parameter values A, evaluated at the probability
%   values in P.
%
%   X = ICDF(NAME,P,A,B) or X = ICDF(NAME,P,A,B,C) returns values of the
%   inverse cumulative distribution function for a two- or three-parameter
%   probability distribution with parameter values A, B (and C).
%
%   The size of X is the common size of the input arguments.  A scalar input
%   functions as a constant matrix of the same size as the other inputs.  Each
%   element of X contains the inverse cumulative distribution evaluated at the
%   corresponding elements of the inputs.
%
%   Values of the inverse cdf are sometimes known as critical values.
%
%   NAME can be:
%
%      'beta'  or 'Beta',
%      'bino'  or 'Binomial',
%      'chi2'  or 'Chisquare',
%      'exp'   or 'Exponential',
%      'ev'    or 'Extreme Value',
%      'f'     or 'F',
%      'gam'   or 'Gamma',
%      'gev'   or 'Generalized Extreme Value',
%      'gp'    or 'Generalized Pareto',
%      'geo'   or 'Geometric',
%      'hyge'  or 'Hypergeometric',
%      'logn'  or 'Lognormal',
%      'nbin'  or 'Negative Binomial',
%      'ncf'   or 'Noncentral F',
%      'nct'   or 'Noncentral t',
%      'ncx2'  or 'Noncentral Chi-square',
%      'norm'  or 'Normal',
%      'poiss' or 'Poisson',
%      'rayl'  or 'Rayleigh',
%      't'     or 'T',
%      'unif'  or 'Uniform',
%      'unid'  or 'Discrete Uniform',
%      'wbl'   or 'Weibull'.
%
%   ICDF calls other specialized routines that do the calculations.
%
%   Example:
%       z = icdf('normal',0.1:0.2:0.9,0,1) % returns standard normal values
%       x = icdf('Poisson',0.1:0.2:0.9,1:5) % array inputs
%
%   See also CDF, MLE, PDF, RANDOM.

%   Copyright 1993-2006 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2010/03/16 00:14:49 $

if nargin<2
   error('stats:icdf:TooFewInputs','Not enough input arguments');
end
if ~ischar(name)
   error('stats:icdf:BadDistribution',...
         'First argument must be distribution name');
end

if nargin<5
   c = 0;
else
   c = varargin{3};
end
if nargin<4
   b = 0;
else
   b = varargin{2};
end
if nargin<3
   a = 0;
else
   a = varargin{1};
end

if     strcmpi(name,'beta'),
    x = betainv(p,a,b);
elseif strcmpi(name,'bino') || strcmpi(name,'Binomial'),
    x = binoinv(p,a,b);
elseif strcmpi(name,'chi2') || strcmpi(name,'Chisquare'),
    x = chi2inv(p,a);
elseif strcmpi(name,'exp') || strcmpi(name,'Exponential'),
    x = expinv(p,a);
elseif strcmpi(name,'ev') || strcmpi(name,'Extreme Value'),
    x = evinv(p,a,b);
elseif strcmpi(name,'f'),
    x = finv(p,a,b);
elseif strcmpi(name,'gam') || strcmpi(name,'Gamma'),
    x = gaminv(p,a,b);
elseif strcmpi(name,'gev') || strcmpi(name,'Generalized Extreme Value'),
    x = gevinv(p,a,b,c);
elseif strcmpi(name,'gp') || strcmpi(name,'Generalized Pareto'),
    x = gpinv(p,a,b,c);
elseif strcmpi(name,'geo') || strcmpi(name,'Geometric'),
    x = geoinv(p,a);
elseif strcmpi(name,'hyge') || strcmpi(name,'Hypergeometric'),
    x = hygeinv(p,a,b,c);
elseif strcmpi(name,'logn') || strcmpi(name,'Lognormal'),
    x = logninv(p,a,b);
elseif strcmpi(name,'nbin') || strcmpi(name,'Negative Binomial'),
    x = nbininv(p,a,b);
elseif strcmpi(name,'ncf') || strcmpi(name,'Noncentral F'),
    x = ncfinv(p,a,b,c);
elseif strcmpi(name,'nct') || strcmpi(name,'Noncentral T'),
    x = nctinv(p,a,b);
elseif strcmpi(name,'ncx2') || strcmpi(name,'Noncentral Chi-square'),
    x = ncx2inv(p,a,b);
elseif strcmpi(name,'norm') || strcmpi(name,'Normal'),
    x = norminv(p,a,b);
elseif strcmpi(name,'poiss') || strcmpi(name,'Poisson'),
    x = poissinv(p,a);
elseif strcmpi(name,'rayl') || strcmpi(name,'Rayleigh'),
    x = raylinv(p,a);
elseif strcmpi(name,'t'),
    x = tinv(p,a);
elseif strcmpi(name,'unid') || strcmpi(name,'Discrete Uniform'),
    x = unidinv(p,a);
elseif strcmpi(name,'unif')  || strcmpi(name,'Uniform'),
    x = unifinv(p,a,b);
elseif strcmpi(name,'weib') || strcmpi(name,'Weibull') || strcmpi(name,'wbl')
    if strcmpi(name,'weib') || strcmpi(name,'Weibull')
        warning('stats:icdf:ChangedParameters', ...
'The Statistics Toolbox uses a new parametrization for the\nWEIBULL distribution beginning with release 4.1.');
    end
    x = wblinv(p,a,b);
else
    spec = dfgetdistributions(name);
    if isempty(spec)
       error('stats:icdf:BadDistribution',...
             'Unrecognized distribution name: ''%s''.',name);
    elseif length(spec)>1
       error('stats:icdf:BadDistribution',...
             'Ambiguous distribution name: ''%s''.',name);
    end
    x = feval(spec.invfunc,p,varargin{:});
end
