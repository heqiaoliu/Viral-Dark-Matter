function t = lt(a,b)
%LT Less than for ordinal arrays.
%   TF = LT(A,B) returns a logical array the same size as the ordinal arrays A
%   and B, containing true (1) where the elements of A are less than those of
%   B, and false (0) otherwise.  A and B must have the same sets of ordinal
%   levels, including their order.
%
%   TF = LT(A,S) or TF = LT(S,B), where S is a character string, returns a
%   logical array the same size as A or B, containing true (1) where the
%   elements of A or B have levels that are less than the level that has label
%   equal to S.  S must be the label for one of the levels of A or B.
%
%   Elements with undefined levels are not considered less than any other
%   elements, including each other.
%
%   See also ORDINAL/EQ, ORDINAL/NE, ORDINAL/GE, ORDINAL/LE, ORDINAL/GT.

%   Copyright 2006 The MathWorks, Inc. $Revision: 1.1.6.1 $  $Date: 2007/12/10 22:38:45 $

[acodes,bcodes] = ordinalcheck(a,b);

% undefined elements cannot be less than anything
t = (acodes < bcodes) & (acodes ~= 0);
