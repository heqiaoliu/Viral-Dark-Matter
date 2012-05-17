%SETXOR Set exclusive-or for categorical arrays.
%   C = SETXOR(A,B) when A and B are categorical arrays returns a categorical
%   vector C containing the values not in the intersection of A and B. The
%   result C is sorted. The set of categorical levels for C is the sorted
%   union of the sets of levels of the inputs, as determined by their labels.
%   
%   [C,IA,IB] = SETXOR(A,B) also returns index vectors IA and IB such that C
%   is a sorted combination of the elements A(IA) and B(IB).
%
%   See also CATEGORICAL/ISMEMBER, CATEGORICAL/UNIQUE, CATEGORICAL/UNION,
%            CATEGORICAL/INTERSECT, CATEGORICAL/SETDIFF.

%   Copyright 2006 The MathWorks, Inc. 
%   $Revision: 1.1.6.1 $  $Date: 2007/12/10 22:37:20 $

% This is an abstract method.