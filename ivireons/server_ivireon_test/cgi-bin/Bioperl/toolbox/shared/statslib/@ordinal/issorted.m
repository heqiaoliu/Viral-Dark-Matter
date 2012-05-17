function t = issorted(a,flag)
%ISSORTED TRUE for sorted ordinal array.
%   TF = ISSORTED(A), when A is an ordinal vector, returns true (1) if the
%   elements of A are in sorted order (in other words, if A and SORT(A) are
%   identical) and false (0) if not.
%
%   TF = ISSORTED(A,'rows'), when A is an ordinal matrix, returns true (1) if
%   the rows of A are in sorted order (if A and SORTROWS(A) are identical) and
%   false (0) if not.
%
%   Elements with undefined levels are sorted to the end.
%
%   See also ORDINAL/SORT, ORDINAL/SORTROWS.

%   Copyright 2006 The MathWorks, Inc. 
%   $Revision: 1.1.6.2 $  $Date: 2009/05/07 18:27:53 $

if nargin > 1 && ~ischar(flag)
    error('stats:ordinal:issorted:UnknownFlag', ...
          'Unknown FLAG.');
end

acodes = a.codes;
tmpCode = categorical.maxCode + 1; % not a legal code
acodes(acodes==0) = tmpCode;
try
    if nargin == 1
        t = issorted(acodes);
    else
        t = issorted(acodes,flag);
    end
catch ME
    throw(ME);
end
