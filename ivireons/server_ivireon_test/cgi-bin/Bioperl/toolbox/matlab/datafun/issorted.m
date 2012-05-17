
%ISSORTED TRUE for sorted vector and matrices.
%   ISSORTED(X), when X is a vector, returns TRUE if the elements of X
%   are in sorted order (in other words, if X and SORT(X) are identical)
%   and FALSE if not. X can be a 1xn or nx1 cell array of strings.
%
%   For character arrays, ASCII order is used. For cell array of strings,
%   dictionary order is used.
%
%   ISSORTED(X,'rows'), when X is a matrix, returns TRUE if the rows of X 
%   are in sorted order (if X and SORTROWS(X) are identical) and FALSE if not.
%   ISSORTED(X,'rows') does not support cell array of strings.
%
%   See also SORT, SORTROWS, UNIQUE, ISMEMBER, INTERSECT, SETDIFF, SETXOR, UNION.

%   Copyright 1984-2005 The MathWorks, Inc.
%   $Revision: 1.2.4.7 $  $Date: 2005/12/12 23:24:08 $

%   Cell array implementation in @cell/issorted.m
