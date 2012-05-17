function [b,varargout] = sortrows(a,col)
%SORTROWS Sort rows of an ordinal matrix in ascending order.
%   B = SORTROWS(A) sorts the rows of the 2-dimensional ordinal matrix A in
%   ascending order as a group.  B is an ordinal array with the same levels as
%   A.
%
%   B = SORTROWS(A,COL) sorts A based on the columns specified in the vector
%   COL.  If an element of COL is positive, the corresponding column in A will
%   be sorted in ascending order; if an element of COL is negative, the
%   corresponding column in A will be sorted in descending order. For example,
%   SORTROWS(A,[2 -3]) sorts the rows of A first in ascending order for the
%   second column, and then by descending order for the third column.
%
%   [B,I] = SORTROWS(A) and [B,I] = SORTROWS(A,COL) also returns an index 
%   matrix I such that B = A(I,:).
%
%   Elements with undefined levels are sorted to the end.
%
%   See also ORDINAL/ISSORTED, ORDINAL/SORT.

%   Copyright 2006 The MathWorks, Inc. 
%   $Revision: 1.1.6.2 $  $Date: 2009/05/07 18:27:59 $

if nargin > 1 && ~isnumeric(col)
    error('stats:ordinal:sort:InvalidCol', ...
          'COL must be numeric.');
end

acodes = a.codes;
tmpCode = categorical.maxCode + 1; % not a legal code
acodes(acodes==0) = tmpCode;
try
    if nargin == 1
        [bcodes,varargout{1:nargout-1}] = sortrows(acodes);
    else
        [bcodes,varargout{1:nargout-1}] = sortrows(acodes,col);
    end
catch ME
    throw(ME);
end
bcodes(bcodes==tmpCode) = 0;
b = ordinal([],a.labels,1:length(a.labels));
b.codes = bcodes;
