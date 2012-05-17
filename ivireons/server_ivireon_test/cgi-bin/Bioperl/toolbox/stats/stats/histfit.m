function h = histfit(data,nbins,dist)
%HISTFIT Histogram with superimposed fitted normal density.
%   HISTFIT(DATA,NBINS) plots a histogram of the values in the vector DATA,
%   along with a normal density function with parameters estimated from the
%   data.  NBINS is the number of bars in the histogram. With one input
%   argument, NBINS is set to the square root of the number of elements in
%   DATA. 
%
%   HISTFIT(DATA,NBINS,DIST) plots a histogram with a density from the DIST
%   distribution.  DIST can take the following values:
%
%         'beta'                             Beta
%         'birnbaumsaunders'                 Birnbaum-Saunders
%         'exponential'                      Exponential
%         'extreme value' or 'ev'            Extreme value
%         'gamma'                            Gamma
%         'generalized extreme value' 'gev'  Generalized extreme value
%         'generalized pareto' or 'gp'       Generalized Pareto (threshold 0)
%         'inverse gaussian'                 Inverse Gaussian
%         'logistic'                         Logistic
%         'loglogistic'                      Log logistic
%         'lognormal'                        Lognormal
%         'negative binomial' or 'nbin'      Negative binomial
%         'nakagami'                         Nakagami
%         'normal'                           Normal
%         'poisson'                          Poisson
%         'rayleigh'                         Rayleigh
%         'rician'                           Rician
%         'tlocationscale'                   t location-scale
%         'weibull' or 'wbl'                 Weibull
%
%   H = HISTFIT(...) returns a vector of handles to the plotted lines.
%   H(1) is a handle to the histogram, H(2) is a handle to the density curve.

%   Copyright 1993-2008 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $  $Date: 2010/03/16 00:14:37 $

if ~isvector(data)
   error('stats:histfit:VectorRequired','DATA must be a vector.');
end

data = data(:);
data(isnan(data)) = [];
n = numel(data);

if nargin<2 || isempty(nbins)
    nbins = ceil(sqrt(n));
elseif ~isscalar(nbins) || ~isnumeric(nbins) || ~isfinite(nbins) ...
                        || nbins~=round(nbins)
    error('stats:histfit:BadNumBins','NBINS must be a positive integer.')
end

% Do histogram calculations
[bincounts,bincenters]=hist(data,nbins);

% Fit distribution to data
if nargin<3 || isempty(dist)
    dist = 'normal';
end
try
    pd = fitdist(data,dist);
catch myException
    if isequal(myException.identifier,'stats:ProbDistUnivParam:fit:NRequired')
        % Binomial is not allowed because we have no N parameter
        error('stats:histfit:BadDistribution',...
              'Binomial distribution not allowed.')
    else
        % Pass along another other errors
        throw(myException)
    end
end

% Find range for plotting
q = icdf(pd,[0.0013499 0.99865]); % three-sigma range for normal distribution
x = linspace(q(1),q(2));
if ~pd.Support.iscontinuous
    % For discrete distribution use only integers
    x = round(x);
    x(diff(x)==0) = [];
end

% Plot the histogram with no gap between bars.
hh = bar(bincenters,bincounts,1);

% Normalize the density to match the total area of the histogram
xd = get(hh,'Xdata');             % Gets the x-data of the bins.
rangex = max(xd(:)) - min(xd(:)); % Finds the range of this data.
binwidth = rangex/nbins;          % Finds the width of each bin.
area = n * binwidth;
y = area * pdf(pd,x);

% Overlay the density
np = get(gca,'NextPlot');    
set(gca,'NextPlot','add')    
hh1 = plot(x,y,'r-','LineWidth',2);

if nargout == 1
  h = [hh; hh1];
end

set(gca,'NextPlot',np) 
