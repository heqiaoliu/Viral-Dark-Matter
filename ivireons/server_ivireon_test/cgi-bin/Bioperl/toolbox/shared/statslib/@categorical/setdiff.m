%SETDIFF Set difference for categorical arrays.
%   C = SETDIFF(A,B) when A and B are categorical arrays returns a categorical
%   vector C containing the values in A that are not in B. The result C is
%   sorted. The set of categorical levels for C is the sorted union of the
%   sets of levels of the inputs, as determined by their labels.
%   
%   [C,I] = SETDIFF(A,B) also returns index vectors I such that C = A(I).
%
%   See also CATEGORICAL/ISMEMBER, CATEGORICAL/UNIQUE, CATEGORICAL/UNION,
%            CATEGORICAL/INTERSECT, CATEGORICAL/SETXOR.

%   Copyright 2006 The MathWorks, Inc. 
%   $Revision: 1.1.6.1 $  $Date: 2007/12/10 22:37:18 $

% This is an abstract method.