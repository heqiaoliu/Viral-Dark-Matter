function [c,ia,ib] = setxor(a,b,flag)
%SETXOR Set exclusive-or for nominal arrays.
%   C = SETXOR(A,B) when A and B are nominal arrays returns a nominal vector C
%   containing the values not in the intersection of A and B. The result C is
%   sorted. The set of nominal levels for C is the sorted union of the
%   sets of levels of the inputs, as determined by their labels.
%   
%   [C,IA,IB] = SETXOR(A,B) also returns index vectors IA and IB such that C
%   is a sorted combination of the elements A(IA) and B(IB).
%
%   See also NOMINAL/ISMEMBER, NOMINAL/UNIQUE, NOMINAL/UNION,
%            NOMINAL/INTERSECT, NOMINAL/SETDIFF.

%   Copyright 2006 The MathWorks, Inc. 
%   $Revision: 1.1.6.2 $  $Date: 2009/05/07 18:27:46 $

if nargin < 2
    error('stats:nominal:setxor:TooFewInputs', ...
          'Requires at least two inputs.');
elseif ~isa(a,'nominal') || ~isa(b,'nominal')
    error('stats:nominal:setxor:TypeMismatch', ...
          'A and B must be categorical arrays from the same class.');
elseif nargin > 2
    if isequal(flag,'rows')
        error('stats:nominal:setxor:RowsFlag', ...
                '''rows'' flag is not accepted for nominal arrays.');
    else
        error('stats:nominal:setxor:TooManyInputs', ...
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

c = nominal;
c.codes = ccodes;
c.labels = clabels;
