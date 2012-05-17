function N = ndims(D)
%NDIMS Number of dimensions of codistributed array
%   N = NDIMS(D)
%   
%   Example:
%   spmd
%       N = 1000;
%       D = codistributed.rand(2,N,3);
%       n = ndims(D)
%   end
%   
%   returns n = 3.
%   
%   See also NDIMS, CODISTRIBUTED, CODISTRIBUTED/RAND.


%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/12/29 01:59:08 $

N = length(size(D));
