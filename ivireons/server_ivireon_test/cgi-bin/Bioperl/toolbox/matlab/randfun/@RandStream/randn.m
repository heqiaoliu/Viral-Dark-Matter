%RANDN Pseudorandom numbers from a standard normal distribution.
%   R = RANDN(S,N) returns an N-by-N matrix containing pseudorandom values drawn
%   from the standard normal distribution.  RANDN draws those values from the
%   random stream S.  RANDN(S,M,N) or RANDN(S,[M,N]) returns an M-by-N matrix.
%   RANDN(S,M,N,P,...) or RANDN(S,[M,N,P,...]) returns an M-by-N-by-P-by-...
%   array.  RANDN(S) returns a scalar.  RANDN(S,SIZE(A)) returns an array the
%   same size as A.
%
%   Note: The size inputs M, N, P, ... should be nonnegative integers.
%   Negative integers are treated as 0.
%
%   R = RANDN(..., 'double') or R = RANDN(..., 'single') returns an array of
%   normal values of the specified class.
%
%   The sequence of numbers produced by RANDN is determined by the internal
%   state of the random stream S.  RANDN uses one or more uniform values from S
%   to generate each normal value.  Resetting that stream to the same fixed
%   state allows computations to be repeated.  Setting the stream to different
%   states leads to unique computations, however, it does not improve any
%   statistical properties.
%
%   See also RANDN, RANDSTREAM, RANDSTREAM/RAND, RANDSTREAM/RANDI.


%   Copyright 2008 The MathWorks, Inc. 
%   $Revision: 1.1.6.2 $  $Date: 2008/09/13 06:57:09 $
%   Mex function.
