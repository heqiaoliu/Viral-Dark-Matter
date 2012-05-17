%MTIMES Matrix product of fi objects
%   C = MTIMES(A,B) is the matrix product of A and B.
%   A and B must be such that the number of columns in A is equal to the
%   number of rows in B, unless one of them is a scalar.
%   A scalar can multiply anything.
%   C = MTIMES(A,B) is called for the syntax A * B when A or B is a fi 
%   object.
%   MTIMES does not support fi objects of data type boolean.
%
%   See also EMBEDDED.FI/PLUS, EMBEDDED.FI/MINUS, EMBEDDED.FI/TIMES,
%            EMBEDDED.FI/UMINUS

%   Copyright 1999-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2006/11/19 21:19:07 $