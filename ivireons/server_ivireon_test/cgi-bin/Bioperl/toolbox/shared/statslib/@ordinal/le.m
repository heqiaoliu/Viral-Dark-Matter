function t = le(a,b)
%LE Less than or equal to for ordinal arrays.
%   TF = LE(A,B) returns a logical array the same size as the ordinal arrays A
%   and B, containing true (1) where the elements of A are less than or equal
%   to those of B, and false (0) otherwise.  A and B must have the same sets
%   of ordinal levels, including their order.
%
%   TF = LE(A,S) or TF = LE(S,B), where S is a character string, returns a
%   logical array the same size as A or B, containing true (1) where the
%   elements of A or B have levels that are less than or equal to the level
%   that has label equal to S.  S must be the label for one of the levels of A
%   or B.
%
%   Elements with undefined levels are not considered less than or equal to any
%   other elements, including each other.
%
%   See also ORDINAL/EQ, ORDINAL/NE, ORDINAL/GE, ORDINAL/GT, ORDINAL/LT.

%   Copyright 2006 The MathWorks, Inc. 
%   $Revision: 1.1.6.1 $  $Date: 2007/12/10 22:38:44 $

[acodes,bcodes] = ordinalcheck(a,b);

% undefined elements cannot be less than or equal to anything
t = (acodes <= bcodes) & (acodes ~= 0);
