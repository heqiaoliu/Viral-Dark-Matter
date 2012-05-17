function t = gt(a,b)
%GT Greater than for ordinal arrays.
%   TF = GT(A,B) returns a logical array the same size as the ordinal arrays A
%   and B, containing true (1) where the elements of A are greater than those
%   of B, and false (0) otherwise.  A and B must have the same sets of ordinal
%   levels, including their order.
%
%   TF = GT(A,S) or TF = GT(S,B), where S is a character string, returns a
%   logical array the same size as A or B, containing true (1) where the
%   elements of A or B have levels that are greater than the level that has
%   label equal to S.  S must be the label for one of the levels of A or B.
%
%   Elements with undefined levels are not considered greater than any other
%   elements, including each other.
%
%   See also ORDINAL/EQ, ORDINAL/NE,  ORDINAL/GE, ORDINAL/LE, ORDINAL/LT.

%   Copyright 2006 The MathWorks, Inc. $Revision: 1.1.6.1 $  $Date: 2007/12/10 22:38:39 $

[acodes,bcodes] = ordinalcheck(a,b);

% undefined elements cannot be greater than anything
t = (acodes > bcodes) & (bcodes ~= 0);
