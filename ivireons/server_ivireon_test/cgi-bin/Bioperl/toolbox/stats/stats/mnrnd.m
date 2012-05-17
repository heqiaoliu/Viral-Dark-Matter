function r = mnrnd(n,p,m)
%MNRND Random vectors from the multinomial distribution.
%   R = MNRND(N,PROB) returns a random vector chosen from the multinomial
%   distribution with parameters N and PROB.  N is a positive scalar integer
%   specifying the number of trials for each multinomial outcome, also known
%   as the sample size, and PROB is a 1-by-K vector of multinomial
%   probabilities, where K is the number of multinomial bins or categories.
%   PROB must sum to one.  R is a 1-by-K vector containing the counts for each
%   of the K multinomial bins. If PROB does not sum to one, R is a
%   1-by-K vector of NaN values.
%
%   R = MNRND(N,PROB,M) returns M random vectors chosen from the multinomial
%   distribution with parameters N and PROB.  R is an M-by-K matrix.  Each row
%   of R corresponds to one multinomial outcome.
%
%   To generate outcomes from different multinomial distributions, PROB can
%   also be an M-by-K matrix, where each row contains a different set of
%   multinomial probabilities.  Each row of PROB must sum to one.  N can also
%   an M-by-1 vector of positive integers or a positive scalar integer. In
%   this case, MNRND generates each row of R using the corresponding rows of
%   the inputs, or replicates them if needed. If any row of PROB does not sum
%   to one, the corresponding row of R is a 1-by-K vector of NaN values.
%
%   Examples:
%    Generate 10 random vectors with N=1000 and the same probabilities
%    P=[0.2,0.3,0.5];
%    X=mnrnd(1000,P,10);
%
%    Generate 2 random vectors with N=1000 and different probabilities
%    P=[0.2, 0.3, 0.5; 0.3 0.4 0.3];
%    X=mnrnd(1000,P);
%
%   See also MNPDF, MNRFIT, MNRVAL, RANDSAMPLE

%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.1.2.1 $  $Date: 2010/06/14 14:30:35 $

if nargin < 2
    error('stats:mnrnd:TooFewInputs', ...
          'Requires two input arguments.');
end

% If p is a column that can be interpreted as a single vector of MN
% probabilities (non-empty and sums to one), transpose it to a row.
% Otherwise, treat as a matrix with one category.
if size(p,2)==1 && size(p,1)>1 && abs(sum(p,1)-1)<=size(p,1)*eps(class(p))
    p = p';
end

if nargin < 3
    [m,k] = size(p);
elseif ~isscalar(m)
    error('stats:mnrnd:NonscalarM', ...
          'M must be a scalar.');
else
    [mm,k] = size(p);
    if ~(mm == 1 || mm == m)
        error('stats:mnrnd:InputSizeMismatch', ...
              'P must be a row vector or have M rows.');
    end
end
if k < 1
    error('stats:mnrnd:NoCategories', ...
          'P must have at least one column.');
end

[mm,kk] = size(n);
if kk ~= 1
    error('stats:mnrnd:InputSizeMismatch', ...
          'N must be a scalar, or a column vector with as many rows as P.');
elseif m == 1 && ~isscalar(n)
    m = mm; % p will replicate out to match n
end

outClass = superiorfloat(n,p);

edges = [zeros(size(p,1),1,outClass) cumsum(p,2)];
pOK = all(0 <= p & p <= 1, 2) & (abs(edges(:,end)-1) <= size(p,2)*eps(class(p)));
edges = min(edges,1); % guard histc against accumulated round-off, but after above check
edges(:,end) = 1; % get the upper edge exact
nOK = (0 <= n & round(n) == n);

% If all cases have the same size and probs, histc can do them all at once
if isscalar(n) && (isvector(p) && (size(p,1)==1))
    if pOK && nOK
        r = histc(rand(m,n,outClass),edges,2);
        if strcmp(outClass,'single'), r = single(r); end
    else
        r = NaN(m,k+1,outClass);
    end

% Otherwise, treat each case individually
else
    r = NaN(m,k+1,outClass);
    if (isvector(p) && (size(p,1)==1)) % && ~isscalar(n)
        if pOK
            for i = 1:m
                if nOK(i)
                    r(i,:) = histc(rand(1,n(i),outClass),edges);
                end
            end
        end
    elseif isscalar(n) % && ~(isvector(p) && (size(p,1)==1))
        if nOK
            for i = 1:m
                if pOK(i)
                    r(i,:) = histc(rand(1,n,outClass),edges(i,:));
                end
            end
        end
    else
        for i = 1:m
            if pOK(i) && nOK(i)
                r(i,:) = histc(rand(1,n(i),outClass),edges(i,:));
            end
        end
    end
end
r(:,end) = []; % remove histc's degenerate uppermost bin
