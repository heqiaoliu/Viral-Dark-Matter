%MIN    Smallest component.
%   For vectors, MIN(X) is the smallest element in X. For matrices,
%   MIN(X) is a row vector containing the minimum element from each
%   column. For N-D arrays, MIN(X) operates along the first
%   non-singleton dimension.
%
%   [Y,I] = MIN(X) returns the indices of the minimum values in vector I.
%   If the values along the first non-singleton dimension contain more
%   than one minimal element, the index of the first one is returned.
%
%   MIN(X,Y) returns an array the same size as X and Y with the
%   smallest elements taken from X or Y. Either one can be a scalar.
%
%   [Y,I] = MIN(X,[],DIM) operates along the dimension DIM.
%
%   When X is complex, the minimum is computed using the magnitude
%   MIN(ABS(X)). In the case of equal magnitude elements, then the phase
%   angle MIN(ANGLE(X)) is used.
%
%   NaN's are ignored when computing the minimum. When all elements in X
%   are NaN's, then the first one is returned as the minimum.
%
%   Example: If X = [2 8 4   then min(X,[],1) is [2 3 4],
%                    7 3 9]
%
%       min(X,[],2) is [2    and min(X,5) is [2 5 4
%                       3],                   5 3 5].
%
%   See also MAX, MEDIAN, MEAN, SORT.

%   Copyright 1984-2005 The MathWorks, Inc.
%   $Revision: 5.16.4.5 $  $Date: 2006/01/18 21:58:53 $

%   Built-in function.

