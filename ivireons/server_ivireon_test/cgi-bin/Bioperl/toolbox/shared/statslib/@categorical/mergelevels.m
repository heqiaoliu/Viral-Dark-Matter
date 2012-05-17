%MERGELEVELS Merge levels of a categorical array.
%   B = MERGELEVELS(A,OLDLEVELS,NEWLEVEL) merges two or more levels of the
%   categorical array A into a single new level.  OLDLEVELS is a cell array of
%   strings or a 2-dimensional character matrix that specifies the levels to
%   be merged.  Any elements of A that have levels in OLDLEVELS are assigned
%   the new level in the corresponding elements of B.  NEWLEVEL is a character
%   string that specifies the label for the new level.
%
%   B = MERGELEVELS(A,OLDLEVELS) merges two or more levels of A and uses the
%   first label in OLDLEVELS as the label for the new level.
%
%   See also CATEGORICAL/ADDLEVELS, CATEGORICAL/DROPLEVELS, CATEGORICAL/ISLEVEL,
%            CATEGORICAL/REORDERLEVELS, CATEGORICAL/GETLABELS.

%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/12/10 22:37:09 $

% This is an abstract method.