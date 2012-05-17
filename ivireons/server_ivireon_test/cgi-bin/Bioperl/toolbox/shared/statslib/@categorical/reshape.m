function b = reshape(a,varargin)
%RESHAPE Change size of a categorical array.
%   B = RESHAPE(A,M,N) returns an M-by-N categorical matrix whose elements are
%   taken columnwise from the categorical array A.  An error results if A does
%   not have M*N elements.
%
%   B = RESHAPE(A,M,N,P,...) or RESHAPE(A,[M N P ...]) returns an array with
%   the same elements as A but reshaped to have the size M-by-N-by-P-by-... .
%   M*N*P*... must be the same as NUMEL(A).
%
%   B = RESHAPE(A,...,[],...) calculates the length of the dimension
%   represented by [], such that the product of the dimensions equals
%   NUMEL(A). NUMEL(A) must be evenly divisible by the product of the known
%   dimensions.  You can use only one occurrence of [].
%
%   In general, RESHAPE(A,SIZ) returns an array with the same elements as A
%   but reshaped to the size SIZ.  PROD(SIZ) must be the same as
%   NUMEL(A). 
%
%   See also CATEGORICAL/SQUEEZE, CATEGORICAL/SHIFTDIM.

%   Copyright 2006 The MathWorks, Inc. 
%   $Revision: 1.1.6.1 $  $Date: 2007/12/10 22:37:16 $

b = a;
b.codes = reshape(a.codes,varargin{:});
