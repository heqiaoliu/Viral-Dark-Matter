function labels = getlabels(a)
%GETLABELS Get level labels of a categorical array.
%   S = GETLABELS(A) returns the labels for the levels of the categorical
%   array A. S is a cell array of strings.
%
%   See also CATEGORICAL/SETLABELS.

%   Copyright 2006 The MathWorks, Inc. 
%   $Revision: 1.1.6.1 $  $Date: 2007/12/10 22:36:52 $

labels = a.labels;
