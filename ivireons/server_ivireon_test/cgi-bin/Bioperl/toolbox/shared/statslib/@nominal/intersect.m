function [c,ia,ib] = intersect(a,b,flag)
%INTERSECT Set intersection for nominal arrays.
%   C = INTERSECT(A,B) when A and B are nominal arrays returns a nominal
%   vector C containing the values common to both A and B. The result C is
%   sorted. The set of nominal levels for C is the sorted union of the
%   sets of levels of the inputs, as determined by their labels.
%   
%   [C,IA,IB] = UNION(A,B) also returns index vectors IA and IB such that
%   C = A(IA) and C = B(IB).
%
%   See also NOMINAL/ISMEMBER, NOMINAL/UNIQUE, NOMINAL/UNION,
%            NOMINAL/SETXOR, NOMINAL/SETDIFF.

%   Copyright 2006 The MathWorks, Inc. 
%   $Revision: 1.1.6.2 $  $Date: 2009/05/07 18:27:43 $

if nargin < 2
    error('stats:nominal:intersect:TooFewInputs', ...
          'Requires at least two inputs.');
elseif ~isa(a,'nominal') || ~isa(b,'nominal')
    error('stats:nominal:intersect:TypeMismatch', ...
          'A and B must be categorical arrays from the same class.');
elseif nargin > 2
    if isequal(flag,'rows')
        error('stats:nominal:intersect:RowsFlag', ...
                '''rows'' flag is not accepted for nominal arrays.');
    else
        error('stats:nominal:intersect:TooManyInputs', ...
              'Too many input arguments');
    end
end
a = a(:); b = b(:);

acodes = a.codes;
if isequal(a.labels,b.labels)
    bcodes = b.codes;
    clabels = a.labels;
else
    % Get a's codes for b's data, possibly adding to a's levels
    [bcodes,clabels] = matchlevels(a,b);
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

c = nominal;
c.codes = ccodes;
c.labels = clabels;
