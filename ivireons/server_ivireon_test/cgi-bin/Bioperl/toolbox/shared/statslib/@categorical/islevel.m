function tf = islevel(s,a)
%ISLEVEL Test for categorical array levels.
%   TF = ISLEVEL(LEVELS,A) returns a logical array the same size as the cell
%   array of strings LEVELS, containing true (1) where the corresponding
%   element of LEVELS is a level of the categorical array A, and false (0)
%   otherwise.  The test is performed by comparing LEVELS with the labels of
%   A's levels.  A need not contain any elements that have values from LEVELS
%   for ISLEVEL to return true.
%
%   LEVELS can also be a single string or a 2-dimensional character matrix.
%
%   See also CATEGORICAL/ISMEMBER, CATEGORICAL/UNIQUE.

%   Copyright 2006 The MathWorks, Inc. 
%   $Revision: 1.1.6.1 $  $Date: 2007/12/10 22:37:02 $

tf = ismember(s,a.labels);
