function t = isvector(a)
%ISVECTOR True if categorical array is a vector.
%   TF = ISVECTOR(A) returns true (1) if the categorical array A is a 1-by-N
%   or N-by-1 vector, where N >= 0, and false (0) otherwise.
%
%   See also CATEGORICAL/ISSCALAR, CATEGORICAL/ISEMPTY, CATEGORICAL/SIZE.

%   Copyright 2006 The MathWorks, Inc. 
%   $Revision: 1.1.6.1 $  $Date: 2007/12/10 22:37:06 $

t = isvector(a.codes);
