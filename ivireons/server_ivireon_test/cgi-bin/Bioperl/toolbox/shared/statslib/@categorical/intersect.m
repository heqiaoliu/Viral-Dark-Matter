%INTERSECT Set intersection for categorical arrays.
%   C = INTERSECT(A,B) when A and B are categorical arrays returns a
%   categorical vector C containing the values common to both A and B. The
%   result C is sorted. The set of categorical levels for C is the sorted
%   union of the sets of levels of the inputs, as determined by their labels.
%   
%   [C,IA,IB] = UNION(A,B) also returns index vectors IA and IB such that
%   C = A(IA) and C = B(IB).
%
%   See also CATEGORICAL/ISMEMBER, CATEGORICAL/UNIQUE, CATEGORICAL/UNION,
%            CATEGORICAL/SETXOR, CATEGORICAL/SETDIFF.

%   Copyright 2006 The MathWorks, Inc. 
%   $Revision: 1.1.6.1 $  $Date: 2007/12/10 22:36:58 $

% This is an abstract method.