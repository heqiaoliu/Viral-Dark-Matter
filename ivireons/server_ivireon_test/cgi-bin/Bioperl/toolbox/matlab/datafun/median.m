function y = median(x,dim)
%MEDIAN Median value.
%   For vectors, MEDIAN(a) is the median value of the elements in a.
%   For matrices, MEDIAN(A) is a row vector containing the median
%   value of each column.  For N-D arrays, MEDIAN(A) is the median
%   value of the elements along the first non-singleton dimension
%   of A.
%
%   MEDIAN(A,DIM) takes the median along the dimension DIM of A.
%
%   Example: If A = [1 2 4 4; 3 4 6 6; 5 6 8 8; 5 6 8 8];
%
%   then median(A) is [4 5 7 7] and median(A,2) 
%   is [3 5 7 7].'
%
%   Class support for input A:
%      float: double, single
%
%   See also MEAN, STD, MIN, MAX, VAR, COV, MODE.

%   Copyright 1984-2009 The MathWorks, Inc.
%   $Revision: 5.15.4.7 $  $Date: 2009/09/03 05:19:03 $

%   Calculation method for even lists: b - (b-a)/2.
%   This method reduces the likelihood of rounding errors.

nInputs = nargin;

if isempty(x)
  if nInputs == 1

    % The output size for [] is a special case when DIM is not given.
    if isequal(x,[]), y = nan(1,class(x)); return; end

    % Determine first nonsingleton dimension
    dim = find(size(x)~=1,1);

  end

  s = size(x);
  if dim <= length(s)
     s(dim) = 1;                  % Set size to 1 along dimension
  end
  y = nan(s,class(x));

elseif nInputs == 1 && isvector(x)
  % If input is a vector, calculate single value of output.
  x = sort(x);
  nCompare = numel(x);
  half = floor(nCompare/2);
  y = x(half+1);
  if 2*half == nCompare        % Average if even number of elements
    y = meanof(x(half),y);
  end
  if isnan(x(nCompare))        % Check last index for NaN
    y = nan(class(x));
  end
else
  if nInputs == 1              % Determine first nonsingleton dimension
    dim = find(size(x)~=1,1);
  end

  s = size(x);

  if dim > length(s)           % If dimension is too high, just return input.
    y = x;
    return
  end

  % Sort along given dimension
  x = sort(x,dim);

  nCompare = s(dim);           % Number of elements used to generate a median
  half = floor(nCompare/2);    % Midway point, used for median calculation

  if dim == 1
    % If calculating along columns, use vectorized method with column
    % indexing.  Reshape at end to appropriate dimension.
    y = x(half+1,:);
    if 2*half == nCompare
      y = meanof(x(half,:),y);
    end

    y(isnan(x(nCompare,:))) = NaN;   % Check last index for NaN

  elseif dim == 2 && length(s) == 2
    % If calculating along rows, use vectorized method only when possible.
    % This requires the input to be 2-dimensional.   Reshape at end.
    y = x(:,half+1);
    if 2*half == nCompare
      y = meanof(x(:,half),y);
    end

    y(isnan(x(:,nCompare))) = NaN;   % Check last index for NaN

  else
    % In all other cases, use linear indexing to determine exact location
    % of medians.  Use linear indices to extract medians, then reshape at
    % end to appropriate size.
    cumSize = cumprod(s);
    total = cumSize(end);            % Equivalent to NUMEL(x)
    numMedians = total / nCompare;

    numConseq = cumSize(dim - 1);    % Number of consecutive indices
    increment = cumSize(dim);        % Gap between runs of indices
    ixMedians = 1;

    y = repmat(x(1),numMedians,1);   % Preallocate appropriate type

    % Nested FOR loop tracks down medians by their indices.
    for seqIndex = 1:increment:total
      for consIndex = half*numConseq:(half+1)*numConseq-1
        absIndex = seqIndex + consIndex;
        y(ixMedians) = x(absIndex);
        ixMedians = ixMedians + 1;
      end
    end

    % Average in second value if n is even
    if 2*half == nCompare
      ixMedians = 1;
      for seqIndex = 1:increment:total
        for consIndex = (half-1)*numConseq:half*numConseq-1
          absIndex = seqIndex + consIndex;
          y(ixMedians) = meanof(x(absIndex),y(ixMedians));
          ixMedians = ixMedians + 1;
        end
      end
    end

    % Check last indices for NaN
    ixMedians = 1;
    for seqIndex = 1:increment:total
      for consIndex = (nCompare-1)*numConseq:nCompare*numConseq-1
        absIndex = seqIndex + consIndex;
        if isnan(x(absIndex))
          y(ixMedians) = NaN;
        end
        ixMedians = ixMedians + 1;
      end
    end
  end

  % Now reshape output.
  s(dim) = 1;
  y = reshape(y,s);
end

%============================

function c = meanof(a,b)
% MEANOF the mean of A and B with B > A
%    MEANOF calculates the mean of A and B. It uses different formula
%    in order to avoid overflow in floating point arithmetic. 

c = a + (b-a)/2;
k = (sign(a) ~= sign(b)) | isinf(a) | isinf(b);
c(k) = (a(k)+b(k))/2;

