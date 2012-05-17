function y = randsample(n, k, varargin)
%RANDSAMPLE Random sample, with or without replacement.
%   Y = RANDSAMPLE(N,K) returns Y as a column vector of K values sampled
%   uniformly at random, without replacement, from the integers 1:N.
%
%   Y = RANDSAMPLE(POPULATION,K) returns K values sampled uniformly at random,
%   without replacement, from the values in the vector POPULATION.  Y is a
%   vector of the same type as POPULATION.  NOTE:  When POPULATION is a
%   numeric vector containing only non-negative integer values, and it might
%   have length 1, use
%
%      Y = POPULATION(RANDSAMPLE(LENGTH(POPULATION),K)
%
%   instead of Y = RANDSAMPLE(POPULATION,K).
%
%   Y = RANDSAMPLE(N,K,REPLACE) or RANDSAMPLE(POPULATION,K,REPLACE) returns a
%   sample taken with replacement if REPLACE is true, or without replacement
%   if REPLACE is false (the default).
%
%   Y = RANDSAMPLE(N,K,true,W) or RANDSAMPLE(POPULATION,K,true,W) returns a
%   weighted sample, using positive weights W, taken with replacement.  W is
%   often a vector of probabilities. This function does not support weighted
%   sampling without replacement.
%
%   Y = RANDSAMPLE(S,...) uses the random number stream S for random number 
%   generation.  RANDSAMPLE uses the MATLAB default random number stream by
%   default.
%
%   Examples:
%
%   Draw a single value from the integers 1:10.
%      n = 10;
%      x = randsample(n,1);
%
%   Draw a single value from the population 1:n, when n > 1.
%      y = randsample(1:n,1);
%
%   Generate a random sequence of the characters ACGT, with
%   replacement, according to specified probabilities.
%      R = randsample('ACGT',48,true,[0.15 0.35 0.35 0.15])
%
%   See also RAND, RANDPERM, RANDSTREAM.

%   Copyright 1993-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.1.2.2 $  $Date: 2010/07/14 23:42:53 $

nargs = nargin;

% Process the stream argument, if present
defaultStream = isnumeric(n) || ~isa(n,'RandStream'); % simple test first for speed
if ~defaultStream
    % shift right to drop s from the argument list
    nargs = nargs - 1;
    s = n;
    n = k;
    if nargs > 1
        k = varargin{1};
        varargin(1) = [];
    end
end

if nargs < 2
    error('stats:randsample:TooFewInputs','Not enough input arguments.');
end

if isscalar(n) && isnumeric(n) && (round(n) == n) && (n >= 0)
    havePopulation = false;
    population = [];
else
    havePopulation = true;
    population = n;
    n = numel(population);
    if ~isvector(population)
        error('stats:randsample:BadPopulation','POPULATION must be a vector.');
    end
end

if nargs < 3
    replace = false;
else
    replace = varargin{1};
end

if nargs < 4
    w = [];
else
    w = varargin{2};
    if ~isempty(w)
        if length(w) ~= n
            if havePopulation
                error('stats:randsample:InputSizeMismatch',...
                    'W must have the same length as the population.');
            else
                error('stats:randsample:InputSizeMismatch',...
                    'W must have length equal to N.');
            end
        else
            sumw = sum(w);
            if ~(sumw > 0) || ~all(w>=0) % catches NaNs
                error('stats:randsample:InvalidWeights',...
                      'W must contain non-negative values with at least one positive value.');
            end
            p = w(:)' / sumw;
        end
    end
end

switch replace
    
    % Sample with replacement
    case {true, 'true', 1}
        if n == 0
            if k == 0
                y = zeros(0,1);
            elseif havePopulation
                error('stats:randsample:SampleTooLarge',...
                    'K must be 0 when sampling from an empty population.');
            else
                error('stats:randsample:SampleTooLarge',...
                    'K must be 0 when N is 0.');
            end
        elseif isempty(w)
            if defaultStream
                y = randi(n,k,1);
            else
                y = randi(s,n,k,1);
            end

        else
            edges = min([0 cumsum(p)],1); % protect against accumulated round-off
            edges(end) = 1; % get the upper edge exact
            if defaultStream
                [~, y] = histc(rand(k,1),edges);
            else
                [~, y] = histc(rand(s,k,1),edges);
            end
        end
        
    % Sample without replacement
    case {false, 'false', 0}
        if k > n
            if havePopulation
                error('stats:randsample:SampleTooLarge',...
                    'K must be less than or equal to the population size for sampling without replacement.');
            else
                error('stats:randsample:SampleTooLarge',...
                    'K must be less than or equal to N for sampling without replacement.');
            end
        end
        
        if isempty(w)
            % If the sample is a sizeable fraction of the population,
            % just randomize the whole population (which involves a full
            % sort of n random values), and take the first k.
            if 4*k > n
                if defaultStream
                    rp = randperm(n);
                else
                    rp = randperm(s,n);
                end
                y = rp(1:k);
                
            % If the sample is a small fraction of the population, a full sort
            % is wasteful.  Repeatedly sample with replacement until there are
            % k unique values.
            else
                x = zeros(1,n); % flags
                sumx = 0;
                while sumx < floor(k) % prevent infinite loop when 0<k<1
                    if defaultStream
                        x(randi(n,1,k-sumx)) = 1; % sample w/replacement
                    else
                        x(randi(s,n,1,k-sumx)) = 1; % sample w/replacement
                    end
                    sumx = sum(x); % count how many unique elements so far
                end
                y = find(x > 0);
                if defaultStream
                    y = y(randperm(k));
                else
                    y = y(randperm(s,k));
                end
            end
        else
            error('stats:randsample:NoWeighting',...
                'Weighted sampling without replacement is not supported.');
        end
    otherwise
        error('stats:randsample:BadReplaceValue',...
            'REPLACE must be either true or false.');
end

if havePopulation
    y = population(y);
else
    y = y(:);
end
