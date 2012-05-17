function n = ndims(a)
%NDIMS Number of dimensions of a dataset array.
%   N = NDIMS(A) returns the number of dimensions in the dataset A.  The
%   number of dimensions in an array is always 2.
%  
%   See also DATASET/SIZE.

%   Copyright 2006 The MathWorks, Inc. 
%   $Revision: 1.1.6.1 $  $Date: 2007/12/10 22:37:51 $

n = a.ndims;
