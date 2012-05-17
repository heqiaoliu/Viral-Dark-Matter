function t = bchnumerr(varargin)
%BCHNUMERR Number of correctable errors for BCH code.
%   T = BCHNUMERR(N) returns all the possible combinations of message lengths
%   (K) and number of correctable errors (t) for BCH code of codeword length
%   N. The codeword length N must have the form 2^m-1 for some integer m
%   between 3 and 16. T is a matrix with 3 columns. The first column lists N,
%   the second column contains K, and the third column lists t.
%
%   T = BCHNUMERR(N,K) returns the number of correctable errors (t) for an
%   (N,K) BCH code.
%
%   See also BCHENC, BCHDEC, BCHGENPOLY.

%   Copyright 1996-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $ Date: $ 

% number of input arguments must be 1 or 2
error(nargchk(1, 2, nargin, 'struct'));

N = varargin{1};

if ~isscalar(N) || floor(N)~=N || N==0
    error('comm:bchnumerr:InvalidN','N must be a positive scalar integer.');
end

if nargin==1;
    K = 0;
else
    K = varargin{2};
    if ~isscalar(K) || floor(K)~=K || K==0
        error('comm:bchnumerr:InvalidK','K must be a positive scalar integer.');
    end
    
end

% number of bits
m = log2(N+1);

if floor(m)~=m || m<3 || m>16
    error('comm:bchnumerr:IncorrectFormN',['N must be of form 2^m-1, where '...
                        'm is an integer between 3 and 16.']);
end

% compute the cosets
gfCosets = cosets(m, [], 'nodisplay');

% unity in GF(2^m) field
alpha = gf(2,m);
alphaPowers = alpha.^(0:2^m-2);
powerVector = alphaPowers.x;
[dummyVar, powerLoc] = sort(powerVector);

% allocate memory
numCosets = numel(gfCosets)-2;
powerPreset = zeros(1,numel(powerVector));
minPolDegree = zeros(1,numCosets);

if nargin == 1
    t = zeros(numCosets, 3);
else
    t = [];
end

% find degree of minimal polynomials for each cosets 
for idx1 = 2:numCosets+1,
    minPolDegree(idx1-1) = numel(gfCosets{idx1}.x);
end

% list of valid message lengths
KVector = N-cumsum(minPolDegree)';

% check for valid K, if K is an input argument
if K>0 && ~any(K==KVector)
    error('comm:bchnumerr:InvalidNK',['The values for N and K do not produce ' ...
          'a valid narrow-sense BCH code.']);
end

% find total number of consecutive powers of ALPHA in IDX1 cosets combined
powerIdx = 2;
for idx1 = 2:numCosets+1,
    cosetIdx1 = gfCosets{idx1}.x;
    
    for idx2 = 1:numel(cosetIdx1)
        powerPreset(powerLoc(cosetIdx1(idx2)))=1;
    end
    
    while powerPreset(powerIdx)==1
        if (powerIdx+2<=N)
            powerIdx = powerIdx + 2;
        end
    end
    
    if K>0
        if(KVector(idx1-1)==K)
            t = powerIdx/2-1;
            break
        end
    else
        t(idx1-1, :) = [N KVector(idx1-1) powerIdx/2-1];
    end
end


%[EOF]
