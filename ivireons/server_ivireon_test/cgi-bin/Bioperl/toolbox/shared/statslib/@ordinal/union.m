function [c,ia,ib] = union(a,b,flag)
%UNION Set union for ordinal arrays.
%   C = UNION(A,B) when A and B are ordinal arrays returns an ordinal vector C
%   containing the combined values from A and B but with no repetitions. The
%   result C is sorted. A and B must have the same sets of ordinal levels,
%   including their order.
%   
%   [C,IA,IB] = UNION(A,B) also returns index vectors IA and IB such that C is
%   a sorted combination of the elements A(IA) and B(IB).
%
%   See also ORDINAL/ISMEMBER, ORDINAL/UNIQUE, ORDINAL/INTERSECT,
%            ORDINAL/SETXOR, ORDINAL/SETDIFF.

%   Copyright 2006-2009 The MathWorks, Inc. 
%   $Revision: 1.1.6.3 $  $Date: 2009/06/16 05:25:56 $

if nargin < 2
    error('stats:ordinal:union:TooFewInputs', ...
          'Requires at least two inputs.');
elseif nargin > 2
    if isequal(flag,'rows')
        error('stats:ordinal:union:RowsFlag', ...
                '''rows'' flag is not accepted for ordinal arrays.');
    else
        error('stats:ordinal:union:TooManyInputs', ...
              'Too many input arguments');
    end
      
% Accept [] as a valid "identity element" for either arg.
elseif isequal(a,[]) % && isa(b,'ordinal')
    a = getlevels(b); a.codes = []; % an empty nominal with the same levels as b
elseif isequal(b,[]) % && isa(a,'ordinal')
    b = getlevels(a); b.codes = []; % an empty nominal with the same levels as a
elseif ~isa(a,'ordinal') || ~isa(b,'ordinal')
    error('stats:ordinal:union:TypeMismatch', ...
          'A and B must be categorical arrays from the same class.');
end
a = a(:); b = b(:);

acodes = a.codes;
if isequal(a.labels,b.labels)
    bcodes = b.codes;
    clabels = a.labels;
else
    error('stats:ordinal:union:OrdinalLevelsMismatch', ...
          'Ordinal levels and their ordering must be identical.');
end

% Set the integer value for undefined elements to the largest integer.  union
% will put one of these at the end, if any are present in A or B.
tmpCode = categorical.maxCode + 1; % not a legal code
undefsa = find(acodes==0);
acodes(undefsa) = tmpCode;
undefsb = find(bcodes==0);
bcodes(undefsb) = tmpCode;

try
    if nargout > 1
        [ccodes,ia,ib] = union(acodes,bcodes);
    else
        ccodes = union(acodes,bcodes);
    end
catch ME
    throw(ME);
end

% Put back as many undefined elements as needed at the end
if ~isempty(undefsa) || ~isempty(undefsb)
    % There will always already be a single tmpCode at the end of ccodes
    ccodes(end:end+length(undefsa)+length(undefsb)-1) = 0;
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
