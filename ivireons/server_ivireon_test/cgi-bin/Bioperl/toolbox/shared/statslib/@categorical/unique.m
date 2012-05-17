function [b,i,j] = unique(a,flag1,flag2)
%UNIQUE Unique values in a categorical array.
%   B = UNIQUE(A) returns a categorical array containing the unique elements
%   of A, sorted by the order of A's levels.
%
%   [B,I,J] = UNIQUE(A) also returns index vectors I and J such that B = A(I)
%   and A = B(J).
%   
%   [B,I,J] = UNIQUE(A,'first') returns the vector I to index the first
%   occurrence of each unique value in A.  UNIQUE(A,'last'), the default,
%   returns the vector I to index the last occurrence.
%
%   See also CATEGORICAL/ISMEMBER, CATEGORICAL/UNION, CATEGORICAL/INTERSECT,
%            CATEGORICAL/SETXOR, CATEGORICAL/SETDIFF.

%   Copyright 2006 The MathWorks, Inc. 
%   $Revision: 1.1.6.2 $  $Date: 2009/05/07 18:27:17 $

flagvals = {'rows' 'first' 'last'};
if nargin > 1
    options = strcmpi(flag1,flagvals);
    if nargin > 2
        options = options + strcmpi(flag2,flagvals);
        if any(options > 1) || (options(2)+options(3) > 1)
           error('stats:categorical:unique:RepeatedFlag', ...
                 'You may not specify more than one value for the same option.');
        end
    end
    if sum(options) < nargin-1
        error('stats:categorical:unique:UnknownFlag', 'Unrecognized option.');
    end
    if options(1) > 0
        error('stats:categorical:unique:RowsFlag', ...
                '''rows'' flag is not accepted for categorical arrays.');
    end
    if options(2) > 0
        order = 'first';
    else % if options(3) > 0 || sum(options(2:3) == 0)
        order = 'last';
    end
elseif nargin == 1
    order = 'last';
else
    error('stats:categorical:unique:NotEnoughInputs', 'Not enough input arguments.');
end
a = a(:);

acodes = a.codes;

% Set the integer value for undefined elements to the largest integer.  unique
% will put one of these at the end, if any are present.
tmpCode = categorical.maxCode + 1; % not a legal code
undefs = find(acodes==0);
acodes(undefs) = tmpCode;

try
    if nargout > 1
        [bcodes,i,j] = unique(acodes,order);
    else
        bcodes = unique(acodes,order);
    end
catch ME
    throw(ME);
end

% Put back as many undefined elements as needed at the end
if ~isempty(undefs)
    k = length(bcodes) + (1:length(undefs)) - 1;
    bcodes(k) = 0;
    if nargout > 1
        i(k) = undefs;
        j(undefs) = k;
    end
end

b = a;
b.codes = bcodes;
