function [b,varargout] = sort(a,dim,mode)
%SORT Sort an ordinal array in ascending or descending order.
%   B = SORT(A), when A is an ordinal vector, sorts the elements of A in
%   ascending order.  For ordinal matrices, SORT(A) sorts each column of A in
%   ascending order.  For N-D ordinal arrays, SORT(A) sorts the along the
%   first non-singleton dimension of A.  B is an ordinal array with the same
%   levels as A.
%
%   B = SORT(A,DIM) sorts A along dimension DIM.
%
%   B = SORT(A,DIM,MODE) sorts A in the order specified by MODE.  MODE is
%   'ascend' for ascending order, or 'descend' for descending order.
%
%   [B,I] = SORT(A,...) also returns an index matrix I.  If A is a
%   vector, then B = A(I).  If A is an m-by-n matrix and DIM = 1, then
%   B(:,j) = A(I(:,j),j) for j = 1:n.
%
%   Elements with undefined levels are sorted to the end.
%
%   See also ORDINAL/ISSORTED, ORDINAL/SORTROWS.

%   Copyright 2006 The MathWorks, Inc. 
%   $Revision: 1.1.6.2 $  $Date: 2009/05/07 18:27:58 $

if nargin > 1 && ~isnumeric(dim)
    error('stats:ordinal:sort:InvalidDim', ...
          'DIM must be a positive integer scalar in the range 1 to 2^31.');
elseif nargin > 2 && ~ischar(mode)
    error('stats:ordinal:sort:InvalidMode', ...
          'MODE must be ''ascend'' or ''descend''.');
end

acodes = a.codes;

% Undefined elements (temporarily) have code greater than any legal
% code.  They will sort to the end.
tmpCode = categorical.maxCode + 1; % not a legal code
acodes(acodes==0) = tmpCode;
try
    if nargin == 1
        [bcodes,varargout{1:nargout-1}] = sort(acodes);
    elseif nargin == 2
        [bcodes,varargout{1:nargout-1}] = sort(acodes,dim);
    else
        [bcodes,varargout{1:nargout-1}] = sort(acodes,dim,mode);
    end
catch ME
    throw(ME);
end
bcodes(bcodes==tmpCode) = 0; % restore undefined code
b = a;
b.codes = bcodes;
