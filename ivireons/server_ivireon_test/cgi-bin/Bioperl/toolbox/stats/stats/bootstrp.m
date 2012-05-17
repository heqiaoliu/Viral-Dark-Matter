function [bootstat, bootsam] = bootstrp(nboot,bootfun,varargin)
%BOOTSTRP Bootstrap statistics.
%   BOOTSTAT = BOOTSTRP(NBOOT,BOOTFUN,D1,...) draws NBOOT bootstrap data
%   samples, computes statistics on each sample using the function BOOTFUN,
%   and returns the results in the matrix BOOTSTAT.  NBOOT must be a
%   positive integer.  BOOTFUN is a function handle specified with @.
%   Each row of BOOTSTAT contains the results of applying BOOTFUN to one
%   bootstrap sample.  If BOOTFUN returns a matrix or array, then this
%   output is converted to a row vector for storage in BOOTSTAT.
%
%   The third and later input arguments (D1,...) are data (scalars,
%   column vectors, or matrices) that are used to create inputs to BOOTFUN.
%   BOOTSTRP creates each bootstrap sample by sampling with replacement
%   from the rows of the non-scalar data arguments (these must have the
%   same number of rows).  Scalar data are passed to BOOTFUN unchanged.
%
%   [BOOTSTAT,BOOTSAM] = BOOTSTRP(...) returns BOOTSAM, an N-by-B matrix of
%   indices into the rows of the extra arguments, where N is the number of
%   rows in non-scalar input arguments to BOOTSTRP and B is the number of
%   generated bootstrap replicates.  To get the output samples BOOTSAM
%   without applying a function, set BOOTFUN to empty ([]).
%
%   BOOTSTAT = BOOTSTRP(..., 'PARAM1',val1, 'PARAM2',val2, ...) specifies
%   optional parameter name/value pairs to control how BOOTSTRP performs
%   computations.  Parameter names/values may only appear after the data
%   arguments used as inputs to BOOTFUN.  Parameters are:
%
%      'Weights' Observation weights. This must be a vector of
%                non-negative numbers with at least one positive
%                element. The number of elements in WEIGHTS must be
%                equal to the number of rows in non-scalar input
%                arguments to BOOTSTRP. To obtain one bootstrap
%                replicate, BOOTSTRP samples N out of N with
%                replacement using these weights as multinomial
%                sampling probabilities.
%
%      'Options' A structure that contains options specifying whether to 
%                compute bootstrap iterations in parallel, and specifying
%                how to use random numbers during the bootstrap sampling.
%                This argument can be created by a call to STATSET. 
%                BOOTSTRP uses the following fields:
%                    'UseParallel'
%                    'UseSubstreams'
%                    'Streams'
%                For information on these fields see PARALLELSTATS.
%                NOTE: if 'UseParallel' is 'always' and 'UseSubstreams' 
%                is 'never', then the length of Streams must equal the number 
%                of processors used by BOOTSTRP. There are two possibilities. 
%                If a MATLAB pool is open, then Streams is the same length as
%                the size of the MATLAB pool. If a MATLAB pool is not open,
%                then Streams must supply a single random number stream.
%
%
%   Examples:
%
%   Compute a sample of 100 bootstrapped means of random samples taken from
%   the vector Y, and plot an estimate of the density of these bootstrapped
%   means:
%      y = exprnd(5,100,1);
%      m = bootstrp(100, @mean, y);
%      [fi,xi] = ksdensity(m);
%      plot(xi,fi);
%
%   Compute a sample of 100 bootstrapped means and standard deviations of
%   random samples taken from the vector Y, and plot the bootstrap estimate
%   pairs:
%      y = exprnd(5,100,1);
%      stats = bootstrp(100, @(x) [mean(x) std(x)], y);
%      plot(stats(:,1),stats(:,2),'o')
%
%   Estimate the standard errors for a coefficient vector in a linear
%   regression by bootstrapping residuals:
%      load hald ingredients heat
%      x = [ones(size(heat)), ingredients];
%      y = heat;
%      b = regress(y,x);
%      yfit = x*b;
%      resid = y - yfit;
%      se = std(bootstrp(1000, @(bootr) regress(yfit+bootr,x), resid));
%
%   Bootstrap a correlation coefficient standard error:
%      load lawdata gpa lsat
%      se = std(bootstrp(1000,@corr,gpa,lsat));
%
%   Compute a sample of 100 bootstrapped means and standard deviations of
%   random samples taken from the vector Y.  Compute the bootstrap iterations
%   in parallel (this only works with the Parallel Computing Toolbox).
%   Plot the bootstrap estimate pairs:
%      y = exprnd(5,100,1);
%      matlabpool open;  % only works with the Parallel Computing Toolbox
%      opt = statset('UseParallel','always');
%      stats = bootstrp(100, @(x) [mean(x) std(x)], y, 'Options', opt);
%      plot(stats(:,1),stats(:,2),'o')
%
%   See also RANDOM, RANDSTREAM, STATSET, STATGET, PARALLELSTATS,
%            HIST, KSDENSITY.

%   Reference:
%      Efron, Bradley, & Tibshirani, Robert, J.
%      "An Introduction to the Bootstrap",
%      Chapman and Hall, New York. 1993.

%   Copyright 1993-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $  $Date: 2010/05/10 17:58:39 $

% Sanity check the two initial arguments
if nargin<2
    error('stats:bootstrp:TooFewInputs', ...
        'BOOTSTRP requires at least two arguments.');
end
if nboot<=0 || nboot~=round(nboot)
    error('stats:bootstrp:BadNboot','NBOOT must be a positive integer.')
end

% === Extract name-value pairs that are not arguments for bootfun ====
[weights, options, bootargs] = extractNameValuePairs(varargin{:});

% === Process the arguments to bootfun ===
[n,booteval] = bootEvalCommand(bootfun,bootargs{:});

% === Process the Options parameters ===
[useParallel, RNGscheme, poolsz] = ...
    internal.stats.parallel.processParallelAndStreamOptions(options,true);
usePool = useParallel && poolsz>0;


% === Set up the bootstrp sampling function ===
[myrand,randargs] = defineRNGcall(RNGscheme, usePool, n, weights);

% === Begin actual processing ===

% Preallocate index matrix of bootstrap samples if requested.
haveallsamples = (nargout>=2);

% If no bootfun was supplied, we still generate a matrix of bootstrap samples,
% if two output arguments were supplied.  This behavior is specified in
% the help text. We also return a dimensioned but empty matrix of zeros
% for the bootstrap statistics.
%
if isempty(bootfun)
    bootstat = zeros(nboot,0);
    if haveallsamples
        bootsam = internal.stats.parallel.smartForSliceout( ...
            nboot, @loopBodyEmptyBootfun, useParallel, RNGscheme);
    end
    return
end

% Sanity check bootfun call and determine dimension and type of result
try
    % Get result of bootfun on actual data, force to a row.
    bootstat = feval(bootfun,bootargs{:});
    bootstat = bootstat(:)';
catch ME
    MEboot =  MException('stats:bootstrp:BadBootFun', ...
        'Unable to evaluate BOOTFUN with the supplied arguments.');
    ME = addCause(ME,MEboot);
    rethrow(ME);
end

% Initialize an array to contain the results of all the bootstrap
% calculations, preserving the output type
bootstat(nboot,1:numel(bootstat)) = bootstat;

% === Do bootfun - nboot times. ===

    if haveallsamples
        [bootstat,bootsam] = internal.stats.parallel.smartForSliceout( ...
            nboot, @loopBody, useParallel, RNGscheme);
    else
        bootstat = internal.stats.parallel.smartForSliceout( ...
           nboot, @loopBody, useParallel, RNGscheme);
    end

% ---- Nested functions ----

    function onesample = loopBodyEmptyBootfun(~,~)
        onesample = myrand(randargs{:});
    end 

    function [onebootstat,onebootsam] = loopBody(~,~)
        onesample = myrand(randargs{:});
        tmp = booteval(onesample);
        onebootstat = (tmp(:))';
        if nargout > 1
            onebootsam = onesample;
        end
    end 

end   % of bootstrp

function [myrand,randargs] = defineRNGcall(RNGscheme,usePool,n,weights)
uuid = RNGscheme.uuid;
streams = RNGscheme.streams;
useSubstreams = RNGscheme.useSubstreams;

if isempty(streams)
    if isempty(weights)
        myrand = @randi;
        randargs = {n,n,1};
    else
        myrand = @randsample;
        randargs = {n,n,true,weights};
    end
else
    % a stream or streams were supplied in the command line
    S = streams{1};
    if isempty(weights)
        myrand = @randi;
        if ~usePool || useSubstreams
            % a single stream is in use throughout
            randargs = {S,n,n,1};
        else
            %- We defer the stream assignment to within the loop iteration,
            %  the stream to be used by the worker is not known now
            myrand = @(streams,useSubstreams,usePool) ...
                randi(internal.stats.parallel.workerGetValue(uuid),n,n,1);
            randargs = {streams,useSubstreams,usePool};
        end
    else
        if ~usePool || useSubstreams
            % a single stream is in use throughout
            myrand = @randsample;
            randargs = {S,n,n,true,weights};
        else
            %- We defer the stream assignment to within the loop iteration,
            %  the stream to be used by the worker is not known now
            myrand = @(streams,useSubstreams,usePool) ...
                randsample(internal.stats.parallel.workerGetValue(uuid),n,n,true,weights);
            randargs = {streams,useSubstreams,usePool};
        end
    end
end
end %-defineRNGcall

function tmp = generalEval(onesample,bootfun,la,scalard,varargin)
db = cell(la,1);
for k = 1:la
    if scalard(k) == 0
        db{k} = varargin{k}(onesample,:);
    else
        db{k} = varargin{k};
    end
end
tmp = feval(bootfun,db{:});
end %-generalEval

function [n,anonfun] = bootEvalCommand(bootfun,varargin)

% === Process the arguments to bootfun ===

% Initialize matrix to identify scalar arguments to bootfun.
la = length(varargin);
if la == 0
    error('stats:bootstrp:BadBootfunArgs', ...
        'BOOTFUN must have at least one argument.');
end
scalard = zeros(la,1);

% find out the size information in varargin.
n = 1;
for k = 1:la
    [row,col] = size(varargin{k});
    if max(row,col) == 1
        scalard(k) = 1;
    end
    if row == 1 && col ~= 1
        row = col;
        varargin{k} = varargin{k}(:);
    end
    if n>1 && row>1 && row~=n
        error('stats:bootstrp:BadBootfunArgs', ...
            'Nonscalar arguments to BOOTFUN must have the same number of rows.');
    end
    n = max(n,row);
end
if n<2
    error('stats:bootstrp:BadBootfunArgs', ...
        'BOOTFUN must have at least one non-scalar argument.');
end

% === Define anonymous function to evaluate bootfun with the supplied arguments ===

if la==1 && ~any(scalard)
    X1 = varargin{1};
    anonfun = @(onesample) feval(bootfun,X1(onesample,:));
elseif la==2 && ~any(scalard)
    X1 = varargin{1};
    X2 = varargin{2};
    anonfun = @(onesample) feval(bootfun,X1(onesample,:),X2(onesample,:));
else
    anonfun = @(onesample) generalEval(onesample,bootfun,la,scalard,varargin{:});
end
end %-bootEval

function [weights,options,bootargs] = extractNameValuePairs(varargin)
% Scan the argument list until we run into a string. Everything to the
% right of the string is considered arguments not for bootfun.

weights = [];
options = statset('bootstrp');

defSpecialArgs = {'weights' 'options'};
defSpecialValues = {weights options};

if length(varargin)>1
    screen = @(arg) (ischar(arg) && size(arg,1)==1);
    isspecial = cellfun(screen,varargin);
    newOptions = [];
    if any(isspecial)
        firstspecial = find(isspecial,1,'first');
        specialArgs = varargin(firstspecial:end);
        varargin = varargin(1:firstspecial-1);
        [eid,emsg,weights,newOptions] ...
            = internal.stats.getargs(defSpecialArgs,defSpecialValues,specialArgs{:});
        if ~isempty(emsg)
            error(sprintf('stats:bootstrp:%s',eid),emsg);
        end
    end
    
    % Check parallel options
    if ~isempty(newOptions)
        try
            if ~isstruct(newOptions)
                error('stats:bootstrp:BadOption', ...
                    'The ''Options'' parameter must be a struct.')
            end
            options = statset(options, newOptions);
        catch ME
            newME = MException('stats:bootstrp:BadOption',...
                'The ''Options'' parameter value is invalid.');
            newME = addCause(newME,ME);
            throw(newME);
        end
    end
end
bootargs = varargin;
end %-extractNameValuePairs
