function [M,F,C] = mode(x,dim)
%MODE   Mode, or most frequent value in a sample.
%   M=MODE(X) for vector X computes M as the sample mode, or most frequently
%   occurring value in X.  For a matrix X, M is a row vector containing
%   the mode of each column.  For N-D arrays, MODE(X) is the mode of the
%   elements along the first non-singleton dimension of X.
%
%   When there are multiple values occurring equally frequently, MODE
%   returns the smallest of those values.  For complex inputs, this is taken
%   to be the first value in a sorted list of values.
%
%   [M,F]=MODE(X) also returns an array F, of the same size as M.
%   Each element of F is the number of occurrences of the corresponding
%   element of M.
%
%   [M,F,C]=MODE(X) also returns a cell array C, of the same size
%   as M.  Each element of C is a sorted vector of all the values having
%   the same frequency as the corresponding element of M.
%
%   [...]=MODE(X,DIM) takes the mode along the dimension DIM of X.
%
%   This function is most useful with discrete or coarsely rounded data.
%   The mode for a continuous probability distribution is defined as
%   the peak of its density function.  Applying the MODE function to a
%   sample from that distribution is unlikely to provide a good estimate
%   of the peak; it would be better to compute a histogram or density
%   estimate and calculate the peak of that estimate.  Also, the MODE
%   function is not suitable for finding peaks in distributions having
%   multiple modes.
%
%   Example: If X = [3 3 1 4
%                    0 0 1 1
%                    0 1 2 4]
%
%   then mode(X) is [0 0 1 4] and mode(X,2) is [3
%                                               0
%                                               0]
%
%   To find the mode of a continuous variable grouped into bins:
%      y = randn(1000,1);
%      edges = -6:.25:6;
%      [n,bin] = histc(y,edges);
%      m = mode(bin);
%      edges([m, m+1])
%      hist(y,edges+.125)
%
%   Class support for input X:
%      float:  double, single
%
%   See also MEAN, MEDIAN, HIST, HISTC.

%   Copyright 2005-2006 The MathWorks, Inc. 
%   $Revision: 1.1.6.3 $  $Date: 2006/12/15 19:27:32 $

error(nargchk(1,2,nargin, 'struct'))    
if ~isfloat(x)
    error('MATLAB:mode:InvalidInput',...
          'X must be an array of double or single numeric values.')
end

if nargin<2
    % Special case to make mode and mean behave similarly
    if isequal(x, [])
        M = NaN(class(x));
        F = 0;
        C = {zeros(0,1,class(x))};
        warning('MATLAB:mode:EmptyInput',...
                'MODE of a 0-by-0 matrix is NaN; result was an empty matrix in previous releases.')
        return
    end
    
    % Determine which dimension to use
    dim = find(size(x)~=1, 1);
    if isempty(dim)
      dim = 1;
    end
else
    if ~isscalar(dim) || ~isa(dim,'double') || dim~=floor(dim) ...
                      || dim<1              || ~isreal(dim)
        error('MATLAB:mode:BadDim',...
              'DIM argument must be a scalar specifying a dimension of X.');
    end
end

dofreq = nargout>=2;
docell = nargout>=3;
wassparse = issparse(x);

sizex = size(x);
if dim>length(sizex)
    sizex = [sizex, ones(1,dim-length(sizex))];
end

sizem = sizex;
sizem(dim) = 1;

% Set up outputs with the proper dimension and type
if wassparse
    M = sparse(sizem(1),sizem(2));  % guaranteed to be 2-D double
else
    M = zeros(sizem,class(x));
end
if dofreq
    F = zeros(sizem);
end
if docell
    C = cell(sizem);
end

% Dispose of empty arrays right away
if isempty(x)
    if docell
        C(:) = {M(1:0)};  % fill C with empties of the proper type
    end
    if prod(sizem)>0
        M(:) = NaN;
        if dofreq
            F(:) = 0;
        end
    end
    return
end

% Convert data to operate along columns of a 2-d array
x = permute(x,[dim, (1:dim-1), (dim+1:length(sizex))]);
x = reshape(x,[sizex(dim),prod(sizem)]);
[nrows,ncols] = size(x);

% Loop over these columns
for j=1:ncols
    v = sort(x(:,j));                        % sorted data
    start = find([1; v(1:end-1)~=v(2:end)]); % start of run of equal values
    freq = [start(2:end);nrows+1] - start;   % frequency of these values
    [maxfreq,firstloc] = max(freq);          % find most frequent
    M(j) = v(start(firstloc));               % smallest most frequent
    if dofreq
        F(j) = maxfreq;                      % highest frequency
    end
    if docell
        if wassparse
            C{j} = sparse(v(start(freq==maxfreq)));
        else
            C{j} = v(start(freq==maxfreq));  % all most frequent
        end
    end
end
