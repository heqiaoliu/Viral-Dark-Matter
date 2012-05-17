%EQ Equality for categorical arrays.
%   TF = EQ(A,B) returns a logical array the same size as the categorical
%   arrays A and B, containing true (1) where the corresponding elements of A
%   and B are equal, and false (0) otherwise.  A and B need not have the same
%   sets of levels for EQ to return true.  The test is performed by comparing
%   the labels of the levels of each pair of elements.
%
%   TF = EQ(A,S) or TF = EQ(S,B), where S is a character string, returns a
%   logical array the same size as A or B, containing true (1) where the
%   levels of corresponding elements of A or B have labels equal to S.
%
%   Elements with undefined levels are not considered equal to each other.
%
%   See also CATEGORICAL/NE.

%   Copyright 2006 The MathWorks, Inc. 
%   $Revision: 1.1.6.1 $  $Date: 2007/12/10 22:36:48 $

% This is an abstract method.