function [c,i] = setdiff(a,b,flag)
%SETDIFF Set difference for ordinal arrays.
%   C = SETDIFF(A,B) when A and B are ordinal arrays returns an ordinal vector
%   C containing the values in A that are not in B. The result C is sorted. A
%   and B must have the same sets of ordinal levels, including their order.
%   
%   [C,I] = SETDIFF(A,B) also returns index vectors I such that C = A(I).
%
%   See also ORDINAL/ISMEMBER, ORDINAL/UNIQUE, ORDINAL/UNION,
%            ORDINAL/INTERSECT, ORDINAL/SETXOR.

%   Copyright 2006 The MathWorks, Inc. 
%   $Revision: 1.1.6.2 $  $Date: 2009/05/07 18:27:56 $

if nargin < 2
    error('stats:ordinal:setdiff:TooFewInputs', ...
          'Requires at least two inputs.');
elseif ~isa(a,'ordinal') || ~isa(b,'ordinal')
    error('stats:ordinal:setdiff:TypeMismatch', ...
          'A and B must be categorical arrays from the same class.');
elseif nargin > 2
    if isequal(flag,'rows')
        error('stats:ordinal:setdiff:RowsFlag', ...
                '''rows'' flag is not accepted for ordinal arrays.');
    else
        error('stats:ordinal:setdiff:TooManyInputs', ...
              'Too many input arguments');
    end
end
a = a(:); b = b(:);

acodes = a.codes;
if isequal(a.labels,b.labels)
    bcodes = b.codes;
    clabels = a.labels;
else
    error('stats:ordinal:setdiff:OrdinalLevelsMismatch', ...
          'Ordinal levels and their ordering must be identical.');
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

c = ordinal;
c.codes = ccodes;
c.labels = clabels;
