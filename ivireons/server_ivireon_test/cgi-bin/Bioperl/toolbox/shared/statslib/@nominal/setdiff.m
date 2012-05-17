function [c,i] = setdiff(a,b,flag)
%SETDIFF Set difference for nominal arrays.
%   C = SETDIFF(A,B) when A and B are nominal arrays returns a nominal vector
%   C containing the values in A that are not in B. The result C is sorted.
%   The set of nominal levels for C is the sorted union of the sets of
%   levels of the inputs, as determined by their labels.
%   
%   [C,I] = SETDIFF(A,B) also returns index vectors I such that C = A(I).
%
%   See also NOMINAL/ISMEMBER, NOMINAL/UNIQUE, NOMINAL/UNION,
%            NOMINAL/INTERSECT, NOMINAL/SETXOR.

%   Copyright 2006 The MathWorks, Inc. 
%   $Revision: 1.1.6.2 $  $Date: 2009/05/07 18:27:45 $

if nargin < 2
    error('stats:nominal:setdiff:TooFewInputs', ...
          'Requires at least two inputs.');
elseif ~isa(a,'nominal') || ~isa(b,'nominal')
    error('stats:nominal:setdiff:TypeMismatch', ...
          'A and B must be categorical arrays from the same class.');
elseif nargin > 2
    if isequal(flag,'rows')
        error('stats:nominal:setdiff:RowsFlag', ...
                '''rows'' flag is not accepted for nominal arrays.');
    else
        error('stats:nominal:setdiff:TooManyInputs', ...
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

% Set the integer value for undefined elements to the largest integer. setdiff
% will put one of these at the end, if any are present in A but not B, but
% won't otherwise.
tmpCode = categorical.maxCode + 1; % not a legal code
undefsa = find(acodes==0);
acodes(undefsa) = tmpCode;
undefsb = find(bcodes==0);
bcodes(undefsb) = tmpCode;

try
    if nargout > 1
        [ccodes,i] = setdiff(acodes,bcodes);
    else
        ccodes = setdiff(acodes,bcodes);
    end
catch ME
    throw(ME);
end

% Put back as many undefined elements as needed at the end
if ~isempty(undefsa)
    % There may or may not already be a single tmpCode at the end of ccodes
    k = length(ccodes) + (isempty(ccodes) || ccodes(end) ~= tmpCode);
    ccodes(k:k+length(undefsa)-1) = 0;
    if nargout > 1
        k = length(i) + (isempty(i) || acodes(i(end)) ~= tmpCode);
        i(k:k+length(undefsa)-1) = undefsa;
    end
end

c = nominal;
c.codes = ccodes;
c.labels = clabels;
