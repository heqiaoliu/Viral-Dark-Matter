function b = rot90(a,varargin)
%ROT90 Rotate categorical matrix 90 degrees.
%   B = ROT90(A) returns the 90 degree counterclockwise rotation of the
%   2-dimensional categorical matrix A.
%
%   B = ROT90(A,K) returns the K*90 degree rotation of A, K = +-1,+-2,...
%
%   See also CATEGORICAL/FLIPLR,  CATEGORICAL/FLIPUD, CATEGORICAL/FLIPDIM.

%   Copyright 2006 The MathWorks, Inc. 
%   $Revision: 1.1.6.1 $  $Date: 2007/12/10 22:37:17 $

b = a;
b.codes = rot90(a.codes,varargin{:});
