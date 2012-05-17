function [c,ia,ib] = setxor(a,b,flag)
%SETXOR Set exclusive-or for ordinal arrays.
%   C = SETXOR(A,B) when A and B are ordinal arrays returns an ordinal vector
%   C containing the values not in the intersection of A and B. The result C
%   is sorted. A and B must have the same sets of ordinal levels, including
%   their order.
%   
%   [C,IA,IB] = SETXOR(A,B) also returns index vectors IA and IB such that C
%   is a sorted combination of the elements A(IA) and B(IB).
%
%   See also ORDINAL/ISMEMBER, ORDINAL/UNIQUE, ORDINAL/UNION,
%            ORDINAL/INTERSECT, ORDINAL/SETDIFF.

%   Copyright 2006 The MathWorks, Inc. 
%   $Revision: 1.1.6.2 $  $Date: 2009/05/07 18:27:57 $

if nargin < 2
    error('stats:ordinal:setxor:TooFewInputs', ...
          'Requires at least two inputs.');
elseif ~isa(a,'ordinal') || ~isa(b,'ordinal')
    error('stats:ordinal:setxor:TypeMismatch', ...
          'A and B must be categorical arrays from the same class.');
elseif nargin > 2
    if isequal(flag,'rows')
        error('stats:ordinal:setxor:RowsFlag', ...
                '''rows'' flag is not accepted for ordinal arrays.');
    else
        error('stats:ordinal:setxor:TooManyInputs', ...
              'Too many input arguments');
    end
end
a = a(:); b = b(:);

acodes = a.codes;
if isequal(a.labels,b.labels)
    bcodes = b.codes;
    clabels = a.labels;
else
    error('stats:ordinal:setxor:OrdinalLevelsMismatch', ...
          'Ordinal levels and their ordering must be identical.');
end

% Set the integer value for undefined elements to the largest integer.  setxor
% will put one of these at the end, if any are present in A but not B or in B
% but not A.
tmpCode = categorical.maxCode + 1; % not a legal code
undefsa = find(acodes==0);
acodes(undefsa) = tmpCode;
undefsb = find(bcodes==0);
bcodes(undefsb) = tmpCode;

try
    if nargout > 1
        [ccodes,ia,ib] = setxor(acodes,bcodes);
    else
        ccodes = setxor(acodes,bcodes);
    end
catch ME
    throw(ME);
end

% Put back as many undefined elements as needed at the end
if ~isempty(undefsa) || ~isempty(undefsb)
    % There may or may not already be a single tmpCode at the end of ccodes
    k = length(ccodes) + (ccodes(end) ~= tmpCode);
    ccodes(k:k+length(undefsa)+length(undefsb)-1) = 0;
    if nargout > 1
        k = length(ia) + (isempty(ia) || acodes(ia(end)) ~= tmpCode);
        ia(k:k+length(undefsa)-1) = undefsa;
        k = length(ib) + (isempty(ib) || bcodes(ib(end)) ~= tmpCode);
        ib(k:k+length(undefsb)-1) = undefsb;
    end
end

c = ordinal;
c.codes = ccodes;
c.labels = clabels;
