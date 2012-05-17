function len = length(a)
%LENGTH Length of a dataset array.
%   N = LENGTH(A) returns the number of observations in the dataset A.  LENGTH
%   is equivalent to SIZE(A,1).
%  
%   See also DATASET/SIZE.

%   Copyright 2006 The MathWorks, Inc. 
%   $Revision: 1.1.6.1 $  $Date: 2007/12/10 22:37:50 $

len = a.nobs;
