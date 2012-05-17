%ALL    True if all elements of a vector are nonzero.
%   For vectors, ALL(V) returns logical 1 (TRUE) if none of the elements 
%   of the vector are zero.  Otherwise it returns logical 0 (FALSE).  For 
%   matrices, ALL(X) operates on the columns of X, returning a row vector
%   of logical 1's and 0's. For N-D arrays, ALL(X) operates on the first
%   non-singleton dimension.
%
%   ALL(X,DIM) works down the dimension DIM.  For example, ALL(X,1)
%   works down the first dimension (the rows) of X.
%
%   See also ANY.

%   Copyright 1984-2005 The MathWorks, Inc.
%   $Revision: 5.11.4.6 $  $Date: 2005/06/21 19:36:07 $
%   Built-in function.

