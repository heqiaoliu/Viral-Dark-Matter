function levels = getlevels(a)
%GETLEVELS Get levels of a categorical array.
%   S = GETLEVELS(A) returns the levels for the categorical array A. S is a
%   vector with the same type as A.
%
%   See also CATEGORICAL/GETLABELS, CATEGORICAL/ADDLEVELS, CATEGORICAL/DROPLEVELS,
%            CATEGORICAL/MERGELEVELS, CATEGORICAL/REORDERLEVELS.

%   Copyright 2008-2009 The MathWorks, Inc. 
%   $Revision: 1.1.6.2 $  $Date: 2009/10/10 20:10:51 $

levels = a;
levels.codes = uint16(1:length(a.labels));
