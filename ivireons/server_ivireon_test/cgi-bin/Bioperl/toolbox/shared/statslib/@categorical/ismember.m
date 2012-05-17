%ISMEMBER True for elements of a categorical array in a set.
%   TF = ISMEMBER(A,LEVELS) returns a logical array the same size as the
%   categorical array A, containing true (1) where the level of the
%   corresponding element of A is equal to one of the levels specified in
%   LEVELS, and false (0) otherwise.  LEVELS is a categorical array, or a cell
%   array of strings or 2-dimensional character array containing level labels.
%
%   [TF,LOC] = ISMEMBER(A,LEVELS) also returns an index array LOC containing
%   the highest absolute index in LEVELS for each element in A whose level is
%   a member of LEVELS, and 0 if there is no such index.
%
%   See also CATEGORICAL/ISLEVEL, CATEGORICAL/UNIQUE, CATEGORICAL/UNION,
%            CATEGORICAL/INTERSECT, CATEGORICAL/SETXOR, CATEGORICAL/SETDIFF.

%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/12/10 22:37:03 $

% This is an abstract method.