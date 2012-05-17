function b = cellstr(a)
%CELLSTR Convert categorical array to cell array of strings.
%   B = CELLSTR(A) converts the categorical array A to a cell array of
%   strings.  Each element of B contains the categorical level label for the
%   corresponding element of A.
%
%   See also CATEGORICAL/CHAR, CATEGORICAL/GETLABELS.

%   Copyright 2006 The MathWorks, Inc. 
%   $Revision: 1.1.6.1 $  $Date: 2007/12/10 22:36:38 $

labs = [categorical.undefLabel a.labels];
b = reshape(labs(a.codes+1),size(a.codes));
