function jackstat = jackknife(jackfun,varargin)
%JACKKNIFE Jackknife statistics.
%   JACKSTAT = JACKKNIFE(JACKFUN,X) draws jackknife data samples from the
%   N-by-P data array X, computes statistics on each sample using the
%   function JACKFUN, and returns the results in the matrix JACKSTAT.
%   JACKFUN is a function handle specified with @.  Each of the N rows of
%   JACKSTAT contains the results of applying JACKFUN to one jackknife
%   sample.  Row I of JACKSTAT contains the results for the sample
%   consisting of X with the Ith row omitted:
%
%        S = X;
%        S(I,:) = [];
%        JACKSTAT(I,:) = JACKFUN(S);
%
%   If JACKFUN returns a matrix or array, then this output is converted to
%   a row vector for storage in JACKSTAT.  If X is a row vector, it is
%   converted to a column vector.
%
%   JACKSTAT = JACKKNIFE(JACKFUN,X,Y,...) accepts additional arguments to
%   be supplied as inputs to JACKFUN. They may be scalars, column vectors,
%   or matrices.  Scalar data are passed to JACKFUN unchanged.  Non-scalar
%   arguments must have the same number of rows, and each jackknife sample
%   omits the same row from these arguments. 
%
%   JACKSTAT = JACKKNIFE(JACKFUN,...,'Options',OPTION) provides an
%   option to perform jackknife iterations in parallel, if the Parallel
%   Computing Toolbox is available. This argument is a structure that can be
%   created by a call to STATSET. JACKKNIFE uses the following fields: 
% 
%      'UseParallel'   If 'always', compute jackknife iterations in 
%                      parallel.  If Parallel Computing Toolbox is
%                      installed and a MATLAB pool is open, computation
%                      occurs in parallel. If Parallel Computing
%                      Toolbox is not installed, or a MATLAB pool is not
%                      open, computation uses parfor loops in serial mode. 
%                      Defaults to 'never', or serial computation with
%                      for loops. 
%
%   Examples:
%
%   Estimate the bias of the MLE variance estimator of random samples
%   taken from the vector Y using jackknife.  The bias has a known formula
%   in this problem, so we can compare the jackknife value to this formula.
%
%      sigma = 5;
%      y = normrnd(0,sigma,100,1);
%      m = jackknife(@var, y, 1);
%      n = length(y);
%      bias = -sigma^2 / n;               % known bias formula
%      jbias = (n - 1)*(mean(m)-var(y,1)) % jackknife estimate of the bias
%
%   Perform the same computation using parallel processors (this has effect
%   only in conjunction with the Parallel Computing Toolbox).
%
%      matlabpool open;
%      sigma = 5;
%      y = normrnd(0,sigma,100,1);
%      opt = statset('UseParallel','always');
%      m = jackknife(@var, y, 1,'Options',opt);
%      n = length(y);
%      bias = -sigma^2 / n;               % known bias formula
%      jbias = (n - 1)*(mean(m)-var(y,1)) % jackknife estimate of the bias
%
%   See also BOOTSTRP, RANDOM, RANDSAMPLE, STATSET, STATGET, PARFOR, 
%            PARALLELSTATS, HIST, KSDENSITY.

%   Reference:
%      Efron, Bradley, & Tibshirani, Robert, J.
%      "An Introduction to the Bootstrap", 
%      Chapman and Hall, New York. 1993.

%   Copyright 1993-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.2.2.1 $  $Date: 2010/07/06 14:43:06 $


% === Extract the 'Options' name-value pair, if present ====

% If present, the 'Options' name-value pair must be the last two elements
% of varargin, otherwise raise an error.  If 'Options' is present, process it,
% and remove it from varargin.
% (Note: problems can result if the user function JACKFUN has a parameter
% with the value 'Options'. The circumstance is highly unlikely, 
% but in this case the user will have to encapsulate the reference 
% by using an anonymous function.)

options = statset('jackknife');

if length(varargin)>1
    screen = @(arg) (ischar(arg) && strcmpi(arg, 'Options'));
    if screen(varargin{end-1})
       % Process the 'UseParallel' field of the struct that follows 'Options'.
       % Allow the struct to have other fields, but ignore them if present.
       cmdOptions = varargin{end};
       if ~isstruct(cmdOptions)
          error('stats:jackknife:Options', ...
                'OPTIONS must be followed by a struct.');
       end
       options = statset(options, cmdOptions);
       varargin = varargin(1:end-2);
    end
    optfound = cellfun(screen, varargin);
    if any(optfound)
       error('stats:jackknife:BadOptions', ...
             'OPTIONS keyword not in second-to-last position.');
    end
end

% === Process the arguments to jackfun ===

% Sanity check the two initial arguments
if nargin<2
    error('stats:jackknife:TooFewInputs',...
          'JACKKNIFE requires a function handle and at least one data argument.');
end

% Initialize matrix to identify scalar arguments to jackfun.
la = length(varargin);
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
      error('stats:jackknife:BadOptions', ... 
            'Nonscalar arguments to JACKFUN must have the same number of rows.');
   end
   n = max(n,row);
end

if isempty(jackfun)
   jackstat = zeros(n,0);
   return
end

[useParallel, ~, ~] = ...
    internal.stats.parallel.processParallelAndStreamOptions(options,true);

% Define error id and message that will be used in multiple places.
badstatsizeID = 'stats:jackknife:BadJackfunOutputSize';
badstatsizeMSG = ['Statistic size %i for one jackknife sample is not equal' ...
                  ' to statistic size for the entire data %i.'];

% === Begin actual processing ===

% Get result of jackfun on actual data and find its size.
jackstat = feval(jackfun,varargin{:});
jackstat = jackstat(:)';

% Initialize an array to contain the results of all the jackknife
% calculations, preserving the output type
Nexp = numel(jackstat); % Expected size of the statistic
jackstat(n,1:Nexp) = jackstat;

% Do jackfun - n times.
if la==1 && ~any(scalard)
   % For special case of one non-scalar argument and one output, try to be fast
   X1 = varargin{1};   
   jackstat = internal.stats.parallel.smartForSliceout(n,@loopBodyOneArg,useParallel);
elseif la==2 && ~any(scalard)
   % For two non-scalar arguments and one output, try to be fast
   X1 = varargin{1};
   X2 = varargin{2};
   jackstat = internal.stats.parallel.smartForSliceout(n,@loopBodyTwoArg,useParallel);
else
   % General case
   jackstat = internal.stats.parallel.smartForSliceout(n,@loopBodyGeneral,useParallel);
end

% ---------- Nested ----------

    function jackstat = loopBodyOneArg(iter,~)
         onesample = 1:n;
         onesample(iter)=[];
         tmp = feval(jackfun,X1(onesample,:));
         if numel(tmp)~=Nexp
             error(badstatsizeID,badstatsizeMSG,numel(tmp),Nexp);
         end
         jackstat = (tmp(:))';
    end

    function jackstat = loopBodyTwoArg(iter,~)
         onesample = 1:n;
         onesample(iter)=[];
         tmp = feval(jackfun,X1(onesample,:),X2(onesample,:));
         if numel(tmp)~=Nexp
             error(badstatsizeID,badstatsizeMSG,numel(tmp),Nexp);
         end
         jackstat = (tmp(:))';
    end

    function jackstat = loopBodyGeneral(iter,~)
         onesample = 1:n;
         onesample(iter)=[];
         for k = 1:la
            if scalard(k) == 0
               db{k} = varargin{k}(onesample,:);
            else
               db{k} = varargin{k};
            end
         end
         tmp = feval(jackfun,db{:});
         if numel(tmp)~=Nexp
             error(badstatsizeID,badstatsizeMSG,numel(tmp),Nexp);
         end
         jackstat = (tmp(:))';
    end

end %-jackknife

