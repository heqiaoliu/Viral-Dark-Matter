function [h,p,stats] = chi2gof(x,varargin)
%CHI2GOF   Chi-square goodness-of-fit test.
%   CHI2GOF performs a chi-square goodness-of-fit test for discrete or
%   continuous distributions.  The test is performed by grouping the data into
%   bins, calculating the observed and expected counts for those bins, and
%   computing the chi-square test statistic SUM((O-E).^2./E), where O is the
%   observed counts and E is the expected counts.  This test statistic has an
%   approximate chi-square distribution when the counts are sufficiently
%   large.
%
%   Bins in either tail with an expected count less than 5 are pooled with
%   neighboring bins until the count in each extreme bin is at least 5.  If
%   bins remain in the interior with counts less than 5, CHI2GOF displays a
%   warning.  In that case, you should use fewer bins, or provide bin
%   centers or edges, to increase the expected counts in all bins.
%
%   H = CHI2GOF(X) performs a chi-square goodness-of-fit test that the data in
%   the vector X are a random sample from a normal distribution with mean and
%   variance estimated from X.  The result is H=0 if the null hypothesis (that
%   X is a random sample from a normal distribution) cannot be rejected at the
%   5% significance level, or H=1 if the null hypothesis can be rejected at
%   the 5% level.  CHI2GOF uses NBINS=10 bins, and compares the test statistic
%   to a chi-square distribution with NBINS-3 degrees of freedom, to take into
%   account that two parameters were estimated.
%
%   [H,P] = CHI2GOF(...) also returns the p-value P.  The P value is the
%   probability of observing the given result, or one more extreme, by
%   chance if the null hypothesis is true.  If there are not enough degrees
%   of freedom to carry out the test, P is NaN.
%
%   [H,P,STATS] = CHI2GOF(...) also returns a STATS structure with the
%   following fields:
%      'chi2stat'  Chi-square statistic 
%      'df'        Degrees of freedom
%      'edges'     Vector of bin edges after pooling
%      'O'         Observed count in each bin
%      'E'         Expected count in each bin
%
%   [...] = CHI2GOF(X,'NAME1',VALUE1,'NAME2',VALUE2,...) specifies
%   optional argument name/value pairs chosen from the following list.
%   Argument names are case insensitive and partial matches are allowed.
%
%   The following options control the initial binning of the data before
%   pooling.  You should not specify more than one of these options.
%
%      Name       Value
%     'nbins'     The number of bins to use.  Default is 10.
%     'ctrs'      A vector of bin centers.
%     'edges'     A vector of bin edges.
%
%   The following options determine the null distribution for the test.  You
%   should not specify both 'cdf' and 'expected'.
%
%      Name       Value
%     'cdf'       A fully specified cumulative distribution function.  This
%                 can be a ProbDist object, a function handle, or a function.
%                 name.  The function must take X values as its only argument.
%                 Alternately, you may provide a cell array whose first
%                 element is a function name or handle, and whose later
%                 elements are parameter values, one per cell. The function
%                 must take X values as its first argument, and other
%                 parameters as later arguments.
%     'expected'  A vector with one element per bin specifying the
%                 expected counts for each bin.
%     'nparams'   The number of estimated parameters; used to adjust
%                 the degrees of freedom to be NBINS-1-NPARAMS, where
%                 NBINS is the number of bins.
%
%   If your 'cdf' or 'expected' input depends on estimated parameters, you
%   should use the 'nparams' parameter to ensure that the degrees of freedom
%   for the test is correct.  Otherwise the default 'nparams' value is
%
%     'cdf' is a ProbDist object:  the number of estimated parameters
%     'cdf' is a function:         0
%     'cdf' is a cell array:       the number of parameters in the array
%     'expected' is specified:     0
%
%   The following options control other aspects of the test.
%
%      Name       Value
%     'emin'      The minimum allowed expected value for a bin; any bin
%                 in either tail having an expected value less than this
%                 amount is pooled with a neighboring bin.  Use the
%                 value 0 to prevent pooling.  Default is 5.
%     'frequency' A vector of the same length as X containing the
%                 frequency of the corresponding X values.
%     'alpha'     An ALPHA value such that the hypothesis is rejected
%                 if P<ALPHA.  Default is ALPHA=0.05.
%
%
%   Examples:
%
%      % Three equivalent ways to test against an unspecified normal
%      % distribution (i.e., with estimated parameters)
%      x = normrnd(50,5,100,1);
%      [h,p] = chi2gof(x)
%      [h,p] = chi2gof(x,'cdf',@(z)normcdf(z,mean(x),std(x)),'nparams',2)
%      [h,p] = chi2gof(x,'cdf',{@normcdf,mean(x),std(x)})
%
%      % Test against standard normal (mean 0, standard deviation 1)
%      x = randn(100,1);
%      [h,p] = chi2gof(x,'cdf',@normcdf)
%
%      % Test against the standard uniform
%      x = rand(100,1);
%      n = length(x);
%      edges = linspace(0,1,11);
%      expectedCounts = n * diff(edges);
%      [h,p,st] = chi2gof(x,'edges',edges,'expected',expectedCounts)
%
%      % Test against the Poisson distribution by specifying observed and
%      % expected counts
%      bins = 0:5; obsCounts = [6 16 10 12 4 2]; n = sum(obsCounts);
%      lambdaHat = sum(bins.*obsCounts) / n;
%      expCounts = n * poisspdf(bins,lambdaHat);
%      [h,p,st] = chi2gof(bins,'ctrs',bins,'frequency',obsCounts, ...
%                         'expected',expCounts,'nparams',1)
%
%   See also CROSSTAB, CHI2CDF, KSTEST, LILLIETEST.

%   Copyright 2005-2009 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $  $Date: 2010/03/16 00:12:47 $

error(nargchk(1,Inf,nargin,'struct'));
if ~isvector(x) || ~isreal(x)
   error('stats:chi2gof:NotVector','X must be a vector of real values.');
end

% Process optional arguments and do error checking
okargs =   {'nbins' 'ctrs' 'edges' 'cdf' 'expected' 'nparams' ...
            'emin' 'frequency' 'alpha'};
defaults = {[]      []     []      []     []        [] ...
            5      []          0.05};
[eid,emsg,nbins,ctrs,edges,cdfspec,expected,nparams,emin,freq,alpha] = ...
             internal.stats.getargs(okargs,defaults,varargin{:});
if ~isempty(eid)
   error(sprintf('stats:chi2gof:%s',eid),emsg);
end
errorcheck(x,nbins,ctrs,edges,cdfspec,expected,nparams,emin,freq,alpha);

% Get bins and observed counts.  This will also perform error checking on
% the nbins, ctrs, and edges inputs.
x = x(:);
if isempty(freq)
   freq = ones(size(x));
else
   freq = freq(:);
end
t = isnan(freq) | isnan(x);
if any(t)
    x(t) = [];
    freq(t) = [];
end
if ~isempty(ctrs)
   [Obs,edges] = statgetbins(x,freq,'ctrs',ctrs);
elseif ~isempty(edges)
   [Obs,edges] = statgetbins(x,freq,'edges',edges);
else
   if isempty(nbins)
      if isempty(expected)
         nbins = 10;               % default number of bins
      else
         nbins = length(expected); % implied by expected value vector
      end
   end
   [Obs,edges] = statgetbins(x,freq,'nbins',nbins);
end    
Obs = Obs(:);
nbins = length(Obs);

% Get expected counts
cdfargs = {};
if ~isempty(expected)
   % Get them from the input argument, if any
   if ~isvector(expected) || numel(expected)~=nbins
      error('stats:chi2gof:BadExpected',...
            'The ''expected'' value must be a vector with %d elements.',nbins);
   end
   if any(expected<0) 
      error('stats:chi2gof:BadExpected',...
            'The ''expected'' values must be non-negative.');
   end
   Exp = expected(:);
else
   % Get them from the cdf
   if isempty(cdfspec)
      % Default cdf is estimated normal
      cdffunc = @normcdf;
      sumfreq = sum(freq);
      cdfargs = {sum(x.*freq)/sumfreq, sqrt((sumfreq/(sumfreq-1))*var(x,freq))};
      if isempty(nparams)
          nparams = 2;
      end
   elseif isa(cdfspec,'ProbDist')
      nparams = length(cdfspec.Params) - sum(cdfspec.ParamIsFixed);
      cdffunc = @(x) cdf(cdfspec,x);
   elseif iscell(cdfspec)
      % Get function and args from cell array
      cdffunc = cdfspec{1};
      cdfargs = cdfspec(2:end);
      if isempty(nparams)
          nparams = numel(cdfargs);
      end
   else
      % Function only, no args
      cdffunc = cdfspec;
   end
   if ~ischar(cdffunc) && ~isa(cdffunc,'function_handle')
      error('stats:chi2gof:BadCdf',...
            'The ''cdf'' value must be a function handle or cell array containing a function handle.');
   end
   if isa(cdffunc,'function_handle')
      cdfname = func2str(cdffunc);
   else
      cdfname = cdffunc;
   end
   
   % For the purpose of computing expected values, we don't need to compute
   % the cdf at the left edge of the first bin or the right edge of the
   % last bin, as the probability in the tails is included in the
   % calculation of expected counts for the first and last bins
   interioredges = edges(2:end-1);
   
   % Compute the cumulative probabilities at the bin boundaries
   try
      Fcdf = feval(cdffunc,interioredges,cdfargs{:});
   catch myException
      newException = MException('stats:chi2gof:BadCdf', ...
                                'Error evaluating cdf function ''%s'':\n%s', ...
                                cdfname);
      newException = newException.addCause(myException);
      throw(newException); 
   end
   if ~isvector(Fcdf) || numel(Fcdf)~=(nbins-1)
      error('stats:chi2gof:BadCdf',...
        'The cdf function ''%s'' returned an incorrect number of values.',...
        cdfname);
   end
    
   % Compute the expected values 
   Exp = sum(Obs) * diff([0;Fcdf(:);1]);
end

% Make sure expected values are not too small
if any(Exp<emin)
   [Exp,Obs,edges] = poolbins(Exp,Obs,edges,emin);
   nbins = length(Exp);
end

% Compute test statistic
cstat = sum((Obs-Exp).^2 ./ Exp);

% Figure out degrees of freedom
if isempty(nparams)
    nparams = 0;   % default if not specified or determined above
end
df = nbins - 1 - nparams;

if df>0
   p = chi2pval(cstat, df);
else
   df = 0;
   p = NaN(class(cstat));
end
h = cast(p<=alpha,class(p));
if nargout>2
   stats = struct('chi2stat',cstat, 'df',df, 'edges',edges, ...
                  'O',Obs', 'E',Exp');
end


% -------------------------
function [Exp,Obs,edges] = poolbins(Exp,Obs,edges,emin)
%POOLBINS Check that expected bin counts are not too small

% Pool the smallest bin each time, working from the end, but
% avoid pooling everything into one bin.  We will never pool bins
% except at either edge (no two internal bins will get pooled together).
i = 1;
j = length(Exp);
while(i<j-1 && ...
      (   Exp(i)<emin || Exp(i+1)<emin ...
       || Exp(j)<emin || Exp(j-1)<emin))
   if Exp(i)<Exp(j)
      Exp(i+1) = Exp(i+1) + Exp(i);
      Obs(i+1) = Obs(i+1) + Obs(i);
      i = i+1;
   else
      Exp(j-1) = Exp(j-1) + Exp(j);
      Obs(j-1) = Obs(j-1) + Obs(j);
      j = j-1;
   end
end      

% Retain only the pooled bins
Exp = Exp(i:j);
Obs = Obs(i:j);
edges(j+1:end-1) = [];  % note j is a bin number, not an edge number
edges(2:i) = [];        % same for i

% Warn if some remaining bins have expected counts too low
if any(Exp<emin)
   warning('stats:chi2gof:LowCounts',...
           ['After pooling, some bins still have low expected counts.\n'...
            'The chi-square approximation may not be accurate']);
end

% -------------------------
function errorcheck(x,nbins,ctrs,edges,cdf,expected,nparams,emin,freq,alpha)
%ERRORCHECK Local function to do error checking on inputs

if (~isempty(nbins) + ~isempty(ctrs) + ~isempty(edges))>1
   error('stats:chi2gof:InconsistentArgs',...
         'You cannot specify more than one of ''nbins'', ''ctrs'', and ''edges<''.');
end

if (~isempty(cdf) + ~isempty(expected))>1
   error('stats:chi2gof:InconsistentArgs',...
         'You cannot specify both ''cdf'' and ''expected''.');
end

if ~isempty(freq)
   if ~isvector(freq) || numel(freq)~=numel(x)
       error('stats:chi2gof:InputSizeMismatch',...
             'The ''frequency'' vector must have the same size as X.');
   end
   if any(freq<0)
       error('stats:chi2gof:BadFreq',...
             'The ''frequency'' values must be zero or positive.');
   end
end

if ~isscalar(emin) || emin<0 || emin~=round(emin) || ~isreal(emin)
   error('stats:chi2gof:BadEMin',...
         'The ''emin'' value must be a non-negative integer.');
end

if ~isempty(nparams)
   if ~isscalar(nparams) || nparams<0 || nparams~=round(nparams) ...
                                      || ~isreal(nparams)
      error('stats:chi2gof:BadNParams',...
            'The ''nparams'' value must be a non-negative integer.');
   end
end

if ~isscalar(alpha) || ~isreal(alpha) || alpha<=0 || alpha>=1
   error('stats:chi2gof:BadAlpha',...
         'The ''alpha'' value must be a scalar between 0 and 1.');
end
