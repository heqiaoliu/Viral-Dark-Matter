function t = ne(a,b)
%NE Not equal for ordinal arrays.
%   TF = NE(A,B) returns a logical array the same size as the ordinal arrays A
%   and B, containing true (1) where the corresponding elements of A and B are
%   not equal, and false (0) otherwise.  A and B must have the same sets of
%   ordinal levels, including their order.
%
%   TF = NE(A,S) or TF = NE(S,B), where S is a character string, returns a
%   logical array the same size as A or B, containing true (1) where the
%   elements of A or B have levels whose labels are not equal to S.
%
%   Elements with undefined levels are considered not equal to any other
%   elements, including each other.
%
%   See also ORDINAL/EQ, ORDINAL/GE, ORDINAL/LE, ORDINAL/LT,  ORDINAL/GT.

%   Copyright 2006 The MathWorks, Inc. 
%   $Revision: 1.1.6.1 $  $Date: 2007/12/10 22:38:49 $

[acodes,bcodes] = ordinalcheck(a,b);

% undefined elements are not equal to everything
t = (acodes ~= bcodes) | (acodes == 0) | (bcodes == 0);
