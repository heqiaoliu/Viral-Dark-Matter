function [c,ia,ib] = intersect(a,b,flag)
%INTERSECT Set intersection for ordinal arrays.
%   C = INTERSECT(A,B) when A and B are ordinal arrays returns an ordinal
%   vector C containing the values common to both A and B. The result C is
%   sorted. A and B must have the same sets of ordinal levels, including
%   their order.
%   
%   [C,IA,IB] = UNION(A,B) also returns index vectors IA and IB such that
%   C = A(IA) and C = B(IB).
%
%   See also ORDINAL/ISMEMBER, ORDINAL/UNIQUE, ORDINAL/UNION,
%            ORDINAL/SETXOR, ORDINAL/SETDIFF.

%   Copyright 2006 The MathWorks, Inc. 
%   $Revision: 1.1.6.2 $  $Date: 2009/05/07 18:27:51 $

if nargin < 2
    error('stats:ordinal:intersect:TooFewInputs', ...
          'Requires at least two inputs.');
elseif ~isa(a,'ordinal') || ~isa(b,'ordinal')
    error('stats:ordinal:intersect:TypeMismatch', ...
          'A and B must be categorical arrays from the same class.');
elseif nargin > 2
    if isequal(flag,'rows')
        error('stats:ordinal:intersect:RowsFlag', ...
                '''rows'' flag is not accepted for ordinal arrays.');
    else
        error('stats:ordinal:intersect:TooManyInputs', ...
              'Too many input arguments');
    end
end
a = a(:); b = b(:);

acodes = a.codes;
if isequal(a.labels,b.labels)
    bcodes = b.codes;
    clabels = a.labels;
else
    error('stats:ordinal:intersect:OrdinalLevelsMismatch', ...
          'Ordinal levels and their ordering must be identical.');
end

% Set the integer value for undefined elements to the largest integer. intersect
% will put one of these at the end, if any are present in both A and B.
tmpCode = categorical.maxCode + 1; % not a legal code
undefsa = find(acodes==0);
acodes(undefsa) = tmpCode;
undefsb = find(bcodes==0);
bcodes(undefsb) = tmpCode;

try
    if nargout > 1
        [ccodes,ia,ib] = intersect(acodes,bcodes);
    else
        ccodes = intersect(acodes,bcodes);
    end
catch ME
    throw(ME);
end

% Remove undefined element from end if present
if ~isempty(undefsa) && ~isempty(undefsb)
    % There will always be a single tmpCode at the end of ccodes
    ccodes(end) = [];
    if nargout > 1
        ia(end) = [];
        ib(end) = [];
    end
end

c = ordinal;
c.codes = ccodes;
c.labels = clabels;
