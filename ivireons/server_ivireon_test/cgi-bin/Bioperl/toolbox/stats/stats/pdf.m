function y = pdf(name,x,varargin)
%PDF Density function for a specified distribution.
%   Y = PDF(NAME,X,A) returns an array of values of the probability density
%   function for the one-parameter probability distribution specified by NAME
%   with parameter values A, evaluated at the values in X.
%
%   Y = PDF(NAME,X,A,B) or Y = PDF(NAME,X,A,B,C) returns values of the
%   probability density function for a two- or three-parameter probability
%   distribution with parameter values A, B (and C).
%
%   The size of Y is the common size of the input arguments.  A scalar input
%   functions as a constant matrix of the same size as the other inputs.  Each
%   element of Y contains the probability density evaluated at the
%   corresponding elements of the inputs.
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
%   PDF calls many specialized routines that do the calculations.
%
%   See also CDF, ICDF, MLE, RANDOM.

%   Copyright 1993-2006 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2010/03/16 00:16:40 $

if nargin<2,
    error('stats:pdf:TooFewInputs','Requires at least two input arguments.');
end

if ~ischar(name),
    error('stats:pdf:BadDistribution',...
          'Requires the first input to be the name of a distribution.');
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
    y = betapdf(x,a,b);
elseif strcmpi(name,'bino') || strcmpi(name,'Binomial'),
    y = binopdf(x,a,b);
elseif strcmpi(name,'chi2') || strcmpi(name,'Chisquare'),
    y = chi2pdf(x,a);
elseif strcmpi(name,'exp') || strcmpi(name,'Exponential'),
    y = exppdf(x,a);
elseif strcmpi(name,'ev') || strcmpi(name,'Extreme Value'),
    y = evpdf(x,a,b);
elseif strcmpi(name,'f'),
    y = fpdf(x,a,b);
elseif strcmpi(name,'gam') || strcmpi(name,'Gamma'),
    y = gampdf(x,a,b);
elseif strcmpi(name,'gev') || strcmpi(name,'Generalized Extreme Value'),
    y = gevpdf(x,a,b,c);
elseif strcmpi(name,'gp') || strcmpi(name,'Generalized Pareto'),
    y = gppdf(x,a,b,c);
elseif strcmpi(name,'geo') || strcmpi(name,'Geometric'),
    y = geopdf(x,a);
elseif strcmpi(name,'hyge') || strcmpi(name,'Hypergeometric'),
    y = hygepdf(x,a,b,c);
elseif strcmpi(name,'logn') || strcmpi(name,'Lognormal'),
    y = lognpdf(x,a,b);
elseif strcmpi(name,'nbin') || strcmpi(name,'Negative Binomial'),
    y = nbinpdf(x,a,b);
elseif strcmpi(name,'ncf') || strcmpi(name,'Noncentral F'),
    y = ncfpdf(x,a,b,c);
elseif strcmpi(name,'nct') || strcmpi(name,'Noncentral T'),
    y = nctpdf(x,a,b);
elseif strcmpi(name,'ncx2') || strcmpi(name,'Noncentral Chi-square'),
    y = ncx2pdf(x,a,b);
 elseif strcmpi(name,'norm') || strcmpi(name,'Normal'),
    y = normpdf(x,a,b);
elseif strcmpi(name,'poiss') || strcmpi(name,'Poisson'),
    y = poisspdf(x,a);
elseif strcmpi(name,'rayl') || strcmpi(name,'Rayleigh'),
    y = raylpdf(x,a);
elseif strcmpi(name,'t'),
    y = tpdf(x,a);
elseif strcmpi(name,'unid') || strcmpi(name,'Discrete Uniform'),
    y = unidpdf(x,a);
elseif strcmpi(name,'unif')  || strcmpi(name,'Uniform'),
    y = unifpdf(x,a,b);
elseif strcmpi(name,'weib') || strcmpi(name,'Weibull') || strcmpi(name,'wbl')
    if strcmpi(name,'weib') || strcmpi(name,'Weibull')
        warning('stats:pdf:ChangedParameters', ...
'The Statistics Toolbox uses a new parametrization for the\nWEIBULL distribution beginning with release 4.1.');
    end
    y = wblpdf(x,a,b);
else
    spec = dfgetdistributions(name);
    if isempty(spec)
       error('stats:pdf:InvalidDistName',...
             'Unrecognized distribution name: ''%s''.',name);
    elseif length(spec)>1
       error('stats:pdf:AmbiguousDistName',...
             'Ambiguous distribution name: ''%s''.',name);
    end
    y = feval(spec.pdffunc,x,varargin{:});
end
