function a = reorderlevels(a,newlevels)
%REORDERLEVELS Reorder levels in an ordinal array.
%   B = REORDERLEVELS(A,NEWLEVELS) reorders the levels of the ordinal array A.
%   NEWLEVELS is a cell array of strings or a 2-dimensional character matrix
%   that specifies the new order.  NEWLEVELS must be a reordering of GETLABELS(A).
%
%   The order of the levels of an ordinal array has significance for
%   relational operators, minimum and maximum, and for sorting.
%
%   See also ORDINAL/ADDLEVELS, ORDINAL/DROPLEVELS, ORDINAL/ISLEVEL,
%            ORDINAL/MERGELEVELS, ORDINAL/GETLABELS.

%   Copyright 2006 The MathWorks, Inc. 
%   $Revision: 1.1.6.1 $  $Date: 2007/12/10 22:38:51 $

a = reorderlevels@categorical(a,newlevels);