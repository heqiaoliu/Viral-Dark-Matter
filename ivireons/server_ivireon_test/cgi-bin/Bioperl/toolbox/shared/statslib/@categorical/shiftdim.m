function [b,nshifts] = shiftdim(a,varargin)
%SHIFTDIM Shift dimensions of a categorical array.
%   B = SHIFTDIM(A,N) shifts the dimensions of the categorical array A by N.
%   When N is positive, SHIFTDIM shifts the dimensions to the left and wraps
%   the N leading dimensions to the end.  When N is negative, SHIFTDIM shifts
%   the dimensions to the right and pads with singletons.
%
%   [B,NSHIFTS] = SHIFTDIM(A) returns the array B with the same number of
%   elements as A but with any leading singleton dimensions removed.  NSHIFTS
%   returns the number of dimensions that are removed.  If A is a scalar,
%   SHIFTDIM has no effect.
%
%   See also CATEGORICAL/CIRCSHIFT,  CATEGORICAL/RESHAPE, CATEGORICAL/SQUEEZE.

%   Copyright 2006 The MathWorks, Inc. 
%   $Revision: 1.1.6.1 $  $Date: 2007/12/10 22:37:21 $

b = a;
[b.codes,nshifts] = shiftdim(a.codes,varargin{:});
