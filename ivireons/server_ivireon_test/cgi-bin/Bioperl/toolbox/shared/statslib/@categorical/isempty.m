function t = isempty(a)
%ISEMPTY True for empty categorical array.
%   TF = ISEMPTY(A) returns true (1) if A is an empty categorical array and
%   false (0) otherwise. An empty array has no elements, that is NUMEL(A)==0.
%
%   See also CATEGORICAL/SIZE, CATEGORICAL/NUMEL.

%   Copyright 2006 The MathWorks, Inc. 
%   $Revision: 1.1.6.1 $  $Date: 2007/12/10 22:37:00 $

t = isempty(a.codes);
