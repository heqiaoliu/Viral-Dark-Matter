function c = times(a,b)
%TIMES Product of categorical arrays.
%   C = TIMES(A,B) returns a categorical array each of whose elements has the
%   level formed from the concatenation of the levels of the corresponding
%   elements of A and B.  The set of levels of C is the cartesian product of
%   the sets of levels of A and of B.
%
%   C = TIMES(A,B) is called for the syntax A .* B.
%
%   See also CATEGORICAL.

%   Copyright 2006 The MathWorks, Inc. 
%   $Revision: 1.1.6.2 $  $Date: 2009/06/16 05:24:54 $

% Accept 1 as a valid "identity element".
if isequal(a,1)
    c = b;
    return;
elseif isequal(b,1)
    c = a;
    return;
    
elseif ~isa(b,class(a))
    error('stats:categorical:times:SizeMismatch', ...
          'All input arguments must be the same categorical class.');
end

if length(a.labels)*length(b.labels) > categorical.maxCode
    error('stats:categorical:categorical:MaxNumLevelsExceeded', ...
          'Too many categorical levels.');
end

c = a;
alabels = repmat(a.labels,1,length(b.labels));
blabels = repmat(b.labels,length(a.labels),1); blabels = blabels(:)';
c.labels = strcat(alabels,{' '},blabels);
c.codes = a.codes + length(a.labels)*(b.codes-1);
