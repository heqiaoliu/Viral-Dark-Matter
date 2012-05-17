%RESHAPE Reshape array.
%   RESHAPE(X,M,N) returns the M-by-N matrix whose elements
%   are taken columnwise from X.  An error results if X does
%   not have M*N elements.
%
%   RESHAPE(X,M,N,P,...) returns an N-D array with the same
%   elements as X but reshaped to have the size M-by-N-by-P-by-...
%   M*N*P*... must be the same as PROD(SIZE(X)).
%
%   RESHAPE(X,[M N P ...]) is the same thing.
%
%   RESHAPE(X,...,[],...) calculates the length of the dimension
%   represented by [], such that the product of the dimensions 
%   equals PROD(SIZE(X)). PROD(SIZE(X)) must be evenly divisible 
%   by the product of the known dimensions. You can use only one 
%   occurrence of [].
%
%   In general, RESHAPE(X,SIZ) returns an N-D array with the same
%   elements as X but reshaped to the size SIZ.  PROD(SIZ) must be
%   the same as PROD(SIZE(X)). 
%
%   See also SQUEEZE, SHIFTDIM, COLON.

%   Copyright 1984-2005 The MathWorks, Inc.
%   $Revision: 5.14.4.5 $  $Date: 2009/05/18 20:48:03 $
%   Built-in function.

