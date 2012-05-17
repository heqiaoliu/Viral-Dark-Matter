classdef ProbDistUnivKernel < ProbDistKernel
%ProbDistUnivKernel Univariate kernel probability distribution.
%   A ProbDistUnivKernel object represents a univariate nonparametric
%   probability distribution defined by kernel smoothing.  You can create
%   this object by calling the FITDIST function or by calling the class
%   constructor.
%
%   ProbDistUnivKernel properties:
%       DistName      - name of the distribution, 'kernel'
%       InputData     - structure containing data used to fit the distribution
%       NLogL         - negative log likelihood for fitted data
%       Support       - structure describing the support of the distribution
%       Kernel        - name of the kernel smoothing function
%       BandWidth     - bandwidth of the smoothing kernel
%
%   ProbDistUnivKernel methods:
%      ProbDistUnivKernel - constructor
%      cdf            - Cumulative distribution function
%      icdf           - Inverse cumulative distribution function
%      iqr            - Interquartile range
%      median         - Median
%      pdf            - Probability density function
%      random         - Random number generation
%
%   See also FITDIST, PROBDIST, PROBDISTKERNEL, KSDENSITY.

%   Copyright 2008-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2010/03/16 00:19:06 $
   
    properties(Dependent)
        %NLogL Negative log likelihood.
        NLogL = [];
    end
    
    properties(GetAccess='protected', SetAccess='protected')
        ksinfo = []; % structure with kernel smoothing info
    end
    
    methods
        function pd = ProbDistUnivKernel(x,varargin)
%ProbDistUnivKernel Univariate kernel probability distribution constructor.
%   PD = ProbDistUnivKernel(X) creates an object PD defining a
%   nonparametric probability distribution based on a normal kernel
%   smoothing function.
%
%   PD = ProbDistUnivKernel(X,'NAME1',VALUE1,'NAME2',VALUE2,...) specifies
%   optional argument name/value pairs chosen from the following list.
%   Argument names are case insensitive and partial matches are allowed.
%
%      Name         Value
%      'censoring'  A boolean vector of the same size as X, containing
%                   ones when the corresponding elements of X are
%                   right-censored observations and zeros when the
%                   corresponding elements are exact observations.
%                   Default is all observations observed exactly.
%      'frequency'  A vector of the same size as X, containing
%                   non-negative integer frequencies for the
%                   corresponding elements in X.  Default is one
%                   observation per element of X.
%      'kernel'     The type of kernel smoother to use, chosen from among
%                   'normal' (default), 'box', 'triangle', and
%                   'epanechnikov'.
%      'support'    Either 'unbounded' (default) if the density can extend
%                   over the whole real line, or 'positive' to restrict it to
%                   positive values, or a two-element vector giving finite
%                   lower and upper limits for the support of the density.
%      'width'      The bandwidth of the kernel smoothing window.  The default
%                   is optimal for estimating normal densities, but you
%                   may want to choose a smaller value to reveal features
%                   such as multiple modes.
%
%   See also PROBDIST, PROBDISTKERNEL, FITDIST, KSDENSITY.

% The 'options' parameter is accepted for compatibility with other
% distribution fitting functions, but it is not used.
            
            pd.DistName = 'kernel';
            
            if nargin==0
                error('stats:ProbDistUnivKernel:TooFewInputs',...
                      'X input is required.')
            end
            if ~isvector(x) || ~isnumeric(x) || size(x,2)~=1 || isempty(x)
                error('stats:ProbDistUnivKernel:BadX',...
                    'X must be a non-empty numeric column vector.');
            end
            
            % Process other arguments.
            okargs =   {'censoring' 'frequency' 'kernel' 'support'   'width' 'options'};
            defaults = {[]          []          'normal' 'unbounded' []      ''};
            
            [eid,emsg,cens,freq,kernel,support,width,options] = ...
                internal.stats.getargs(okargs,defaults,varargin{:});
            if ~isempty(eid)
                error(sprintf('stats:ProbDistUnivKernel:%s',eid),emsg);
            end
            
            kernelnames = {'normal' 'epanechnikov'  'box'    'triangle'};
            if ischar(kernel) && size(kernel,1)==1
                kernel = dfswitchyard('statgetkeyword',kernel,kernelnames,false,...
                    'kernel','stats:ProbDistUnivKernel:BadKernel');
            else
                error('stats:ProbDistUnivKernel:BadKernel',...
                    'KERNEL must be a valid kernel name.');
            end
            
            if ~isempty(cens) && ...
                    ~(   isequal(size(x),size(cens)) ...
                    && (islogical(cens) || all(ismember(cens,0:1))))
                error('stats:ProbDistUnivKernel:BadCens',...
                    'CENSORING must be a logical vector of the same size as X.');
            end
            if ~isempty(freq)
                if ~isvector(freq) || ~isnumeric(freq) || any(freq<0)
                    error('stats:ProbDistUnivKernel:BadFreq',...
                        'FREQUENCY must be a vector of positive values.')
                end
                if isscalar(freq)
                    freq = repmat(freq,size(x));
                elseif ~isequal(size(freq),size(x))
                    error('stats:ProbDistUnivKernel:BadFreq',...
                        'FREQUENCY must be a vector of the same size as X.')
                end
            end
            
            if ischar(support) && size(support,1)==1 ...
                    && isscalar(strmatch(support,{'unbounded' 'positive'}))
                if support(1)=='u'
                    support = 'unbounded';
                else
                    support = 'positive';
                end
            elseif isequal(support(:),[-Inf;Inf])
                support = 'unbounded';
            elseif isequal(support(:),[0;Inf])
                support = 'positive';
            elseif ~isnumeric(support) || numel(support)~=2 ...
                    || ~all(isfinite(support)) ...
                    || support(1)>=support(2)
                error('stats:ProbDistUnivKernel:BadSupport',...
                    'SUPPORT must be ''unbounded'', ''positive'', or a finite two-element sorted vector.');
            end
            if ~isempty(width)
                if ~isnumeric(width) || ~isscalar(width) ...
                        || ~isfinite(width) || width<=0
                    error('stats:ProbDistUnivKernel:BadWidth',...
                        'WIDTH must be a positive scalar.');
                end
            end
            
            % Remove entries with NaN or with 0 frequency
            freq(freq==0) = NaN;
            [badin,wasnan,x,cens,freq]=dfswitchyard('statremovenan',x,cens,freq);
            if isempty(x)
                error('stats:ProbDistUnivKernel:BadX',...
                    'X is empty after removing NaNs and zero-frequency values.');
            end
            
            % Get ks info, including default width if needed
            if ~isempty(x)
                xi = x(1);
            elseif isnumeric(support)
                xi = sum(support)/2;
            else
                xi = 1;
            end
            [ignore,ignore,defaultwidth,ksinfo] = ...
                         ksdensity(x,xi,'cens',cens,'weight',freq,....
                                   'support',support,'width',width);
            if isempty(width)
                width = defaultwidth;
            end
            
            % Fill in object properties
            pd.Kernel = kernel;
            pd.BandWidth = width;
            pd.Support.range = support;
            pd.InputData.data = x;
            pd.InputData.cens = cens;
            pd.InputData.freq = freq;
            pd.ksinfo = ksinfo;
        end %constructor
        
        function v = get.NLogL(pd)
%GET.NLOGL Access method for NLogL property
            f = pd.InputData.freq;
            c = pd.InputData.cens;
            x = pd.InputData.data;
            if isempty(f)
                f = ones(size(x));
            end
            if isempty(c)
                c = false(size(x));
            end
            
            v = 0;
            if any(c) % compute log survivor function for censoring points
                v = v - sum(f(c) .* log(1-cdf(pd, x(c))));
            end
            if any(~c) % compute log pdf for observed data
                v = v - sum(f(~c) .* log(pdf(pd,x(~c))));
            end
        end
        
    end
    
    methods(Static = true, Hidden = true)
       function pd = fit(varargin)
%ProbDistUnivKernel/FIT Fit univariate kernel probability distribution object.
%   PD = ProbDistKernel.FIT(X,...) creates an object PD defining a
%   nonparametric probability distribution based on a normal kernel
%   smoothing function.  It is equivalent to calling the constructor
%   PD = ProbDistUnivKernel(X,...).
%
%   See also PROBDISTUNIVKERNEL, FITDIST, KSDENSITY.
            
            if nargin < 1
                error('stats:ProbDistUnivKernel:fit:TooFewInputs',...
                      'At least one input argument is required.');
            end
            
            pd = ProbDistUnivKernel(varargin{:});
        end
    end
end % classdef
