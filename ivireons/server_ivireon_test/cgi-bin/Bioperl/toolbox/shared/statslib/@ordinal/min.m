function [c,varargout] = min(a,b,dim)
%MIN Smallest element in an ordinal array.
%   B = MIN(A), when A is an ordinal vector, returns the smallest element in
%   A. For ordinal matrices, MIN(A) is a row vector containing the minimum
%   element from each column.  For N-D ordinal arrays, MIN(A) operates along
%   the first non-singleton dimension.  B is an ordinal array with the same
%   levels as A.
%
%   [B,I] = MIN(A) returns the indices of the minimum values in vector I. If
%   the values along the first non-singleton dimension contain more than one
%   minimal element, the index of the first one is returned.
%
%   C = MIN(A,B) returns an ordinal array the same size as A and B with the
%   smallest elements taken from A or B.  A and B must have the same sets of
%   ordinal levels, including their order.
%
%   [B,I] = MIN(A,[],DIM) operates along the dimension DIM. 
%
%   Elements with undefined levels are not considered less than any other
%   elements, including each other.
%
%   See also ORDINAL/MIN, ORDINAL/SORT.

%   Copyright 2006-2009 The MathWorks, Inc. 
%   $Revision: 1.1.6.3 $  $Date: 2009/06/16 05:25:50 $

if nargin > 2 && ~isnumeric(dim)
    error('stats:ordinal:max:InvalidDim', ...
          'DIM must be a positive integer scalar in the range 1 to 2^31.');
end

if (nargin < 2) || isequal(b,[]) % && isa(a,'ordinal')
    acodes = a.codes;
    bcodes = [];
    c = ordinal([],a.labels,1:length(a.labels));
else
    % Accept +Inf as a valid "identity element" in the two-arg case.  If compared
    % to <undefined>, the maximal value will be the result.
    if isequal(a,Inf) % && isa(b,'ordinal')
        a = getlevels(b);
        a.codes = length(a); % maximal value, or <undefined>
    elseif isequal(b,Inf) % && isa(a,'ordinal')
        b = getlevels(a);
        b.codes = length(b); % maximal value, or <undefined>
    end
    [acodes,bcodes] = ordinalcheck(a,b);
    if ischar(a)
        c = ordinal([],b.labels,1:length(b.labels));
    else
        c = ordinal([],a.labels,1:length(a.labels));
    end
end

% Undefined elements (temporarily) have code greater than any legal
% code.  They will not be the min value unless there's nothing else.
tmpCode = categorical.maxCode + 1; % not a legal code
acodes(acodes==0) = tmpCode;
bcodes(bcodes==0) = tmpCode;
try
    if nargin == 1
        [ccodes,varargout{1:nargout-1}] = min(acodes);
    elseif nargin == 2
        [ccodes,varargout{1:nargout-1}] = min(acodes,bcodes);
    else
        [ccodes,varargout{1:nargout-1}] = min(acodes,bcodes,dim);
    end
catch ME
    throw(ME);
end
ccodes(ccodes==tmpCode) = 0; % restore undefined code
c.codes = ccodes;
