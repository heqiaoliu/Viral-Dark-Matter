function [settings, X] = rowexch(nfactors,nruns,model,varargin)
%ROWEXCH D-Optimal design of experiments (row exchange algorithm).
%   [SETTINGS, X] = ROWEXCH(NFACTORS,NRUNS,MODEL) generates a D-optimal
%   design having NRUNS runs for NFACTORS factors.  SETTINGS is the
%   matrix of factor settings for the design, and X is the matrix of
%   term values (often called the design matrix).  MODEL is an optional
%   argument that controls the order of the regression model.  By default,
%   ROWEXCH returns the design matrix for a linear additive model with a
%   constant term.  MODEL can be any of the following strings:
%
%     'linear'        constant and linear terms (the default)
%     'interaction'   includes constant, linear, and cross product terms
%     'quadratic'     interactions plus squared terms
%     'purequadratic' includes constant, linear and squared terms
%
%   Alternatively MODEL can be a matrix of term definitions as
%   accepted by the X2FX function.
%
%   [SETTINGS, X] = ROWEXCH(...,'PARAM1',VALUE1,'PARAM2',VALUE2,...)
%   provides more control over the design generation through a set of
%   parameter/value pairs.  Valid parameters are the following:
%
%      Parameter    Value
%      'bounds'     Lower and upper bounds for each factor, specified
%                   as a 2-by-NFACTORS matrix.  Alternatively, this value
%                   can be a cell array containing NFACTORS elements, each
%                   element specifying the vector of allowable values for
%                   the corresponding factor.
%      'categorical'     Indices of categorical predictors.
%      'display'    Either 'on' or 'off' to control display of
%                   iteration number. (default = 'on' unless 'UseParallel'
%                   is 'always', in which case default = 'off').
%      'init'       Initial design as an NRUNS-by-NFACTORS matrix
%                   (default is a randomly selected set of points).
%      'excludefun' Function to exclude undesirable runs.
%      'levels'     Vector of number of levels for each factor.
%      'maxiter'    Maximum number of iterations (default = 10).
%      'tries'      Number of times to try to do generate a design from a
%                   new starting point, using random points for each
%                   try except possibly the first (default 1). 
%      'options'     A structure that contains options specifying whether to
%                    compute multiple tries in parallel, and specifying how
%                    to use random numbers when generating the starting points
%                    for the tries. This argument can be created by a call to 
%                    STATSET. ROWEXCH uses the following fields:
%                        'UseParallel'
%                        'UseSubstreams'
%                        'Streams'
%                    For information on these fields see PARALLELSTATS.
%                    NOTE: if 'UseParallel' is 'always' and 'UseSubstreams' 
%                    is 'never', then the length of Streams must equal the number
%                    of processors used by ROWEXCH. There are two possibilities. 
%                    If a MATLAB pool is open, then Streams is the same length as
%                    the size of the MATLAB pool. If a MATLAB pool is not open,
%                    then Streams must supply a single random number stream.
%
%   The ROWEXCH function searches for a D-optimal design using a row-
%   exchange algorithm.  It first generates a candidate set of points that
%   are eligible to be included in the design, and then iteratively
%   exchanges design points for candidate points in an attempt to reduce the
%   variance of the coefficients that would be estimated using this design.
%   If you need to use a candidate set that differs from the default one,
%   you can call the CANDGEN and CANDEXCH functions in place of ROWEXCH.
%
%   If the 'excludefcn' function is F, it must support the syntax B=F(S) 
%   where S is a matrix of K-by-NFACTORS columns containing settings,
%   and B is a vector of K boolean values.  B(j) is true if the jth row
%   of S should be excluded.
%
%   Example:
%      % Design for two factors, quadratic model
%      sortrows(rowexch(2,9,'q'))
%
%      % Design for 3 categorical factors taking 3 levels each --
%      % multiple tries may be required to find the best design
%      sortrows(rowexch(3,9,'linear','cat',1:3,'levels',3,'tries',10))
%
%   See also CORDEXCH, CANDGEN, CANDEXCH, X2FX, STATSET, PARALLELSTATS.

%   Copyright 1993-2010 The MathWorks, Inc. 
%   $Revision: 1.1.8.3.2.1 $  $Date: 2010/07/06 14:43:10 $
% ====================================================================


% Get default values for optional arguments
if nargin < 3
  model = 'linear';
end

pnames = {'display'   'init'    'maxiter'    'tries' ...
          'bounds',   'levels'  'excludefun' 'categorical' 'options'};

[eid,emsg,dodisp,   settings,  maxiter,   tries, ...
          bnds,     nlevels,   excluder,  categ,  paropt] = ...
                  doptargcheck('rowexch',pnames,nfactors,nruns,varargin{:});
if ~isempty(eid)
   error(sprintf('stats:rowexch:%s',eid),emsg);
end

% Generate a candidate set appropriate for this model,
% and get a matrix of model terms
[xcand,fxcand] = candgen(nfactors,model,'levels',nlevels,...
                         'bounds',bnds,'categorical',categ);

% Exclude some rows if necessary
if ~isempty(excluder)
   try
      badrows = excluder(xcand);
      xcand(badrows,:) = [];
      fxcand(badrows,:) = [];
   catch ME
      throw(addCause(MException('stats:rowexch:BadExclusion',...
                                'Error running exclusion function.'),ME));
   end
end

% Figure out number of levels for each predictor
if isempty(nlevels)
   catlevels = repmat(2,size(categ));
elseif isscalar(nlevels)
   catlevels = repmat(nlevels,size(categ));
else
   catlevels = nlevels(categ);
end

% Convert from actual categorical factor levels to 1:maxlevel
if ~isempty(settings)
    for j=1:length(categ)
        cj = categ(j);
        if iscell(bnds)
           setlist = bnds{cj};
        else
           setlist = linspace(bnds(1,cj),bnds(2,cj),catlevels(j));
        end
        [foundit,catrow] = ismember(settings(:,cj),setlist);
        if any(~foundit)
           error('stats:rowexch:BadInit',...
          ['One or more entries in column %d of the initial design do not'...
           '\nappear in the list specified by the ''bounds'' parameter.'],...
                 cj);
        end
        settings(:,cj) = catrow;
    end
end

% Get a starting design chosen at random within factor range
% (may be overridden in varargin), plus model terms for this design.
% Range of [-1,1] is adequate for continuous factors because these
% points will be replaced in the first pass.
iscat = ismember(1:nfactors,categ);
if isempty(settings)
   settings = zeros(nruns, nfactors);      
   S = RandStream.getDefaultStream;
   useSubstreams = false;
   % If the command line supplied a random stream, use it instead of
   % the default stream.  If there were multiple streams, use the 
   % first in order.  The parallel and stream options are type-checked
   % here, but complete validity checking is deferred to the call to
   % CANDEXCH below.
   if ~isempty(paropt)
       [~, useSubstreams, streams] = ...
           internal.stats.parallel.extractParallelAndStreamFields(paropt);
       if ~isempty(streams)
           S = streams{1};
       end
   end
   if useSubstreams
      internal.stats.parallel.freshSubstream(S);
   end
   settings(:,~iscat) = 2 * (rand(S,nruns,sum(~iscat)) - 0.5);
   for j=1:length(categ)
      settings(:,categ(j)) = ceil(catlevels(j) * rand(S,nruns,1));
   end
elseif size(settings,1)~=nruns || size(settings,2)~=nfactors
   error('stats:rowexch:BadDesign',...
         'Initial design must be a %d-by-%d matrix.',nruns,nfactors);
end

[X,model] = x2fx(settings,model,categ,catlevels);

modelorder = max(model,[],1);   % max order of each factor
if isempty(nlevels)
   nlevels = modelorder+1;
   nlevels(categ) = 2;
end
if any(~iscat & nlevels<modelorder+1)
   error('stats:rowexch:TooFewLevels',...
         'Not all factors have enough levels to fit the model you specified.');
end

% Call candexch to generate design
rowlist = candexch(fxcand,nruns,'init',X,...
              'display',dodisp, 'maxiter',maxiter, ...
              'tries',  tries , 'options',paropt   );

% Return factor settings and model term values if requested
settings = xcand(rowlist,:);
if nargout>1
   X = fxcand(rowlist,:);
end

