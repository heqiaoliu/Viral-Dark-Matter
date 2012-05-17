%RAND Pseudorandom numbers from a uniform distribution.
%   R = RAND(S,N) returns an N-by-N matrix containing pseudorandom values drawn
%   from the standard uniform distribution on the open interval(0,1).  RAND
%   draws those values from the random stream S.  RAND(S,M,N) or RAND(S,[M,N])
%   returns an M-by-N matrix. RAND(S,M,N,P,...) or RAND(S,[M,N,P,...]) returns
%   an M-by-N-by-P-by-... array.  RAND(S) returns a scalar.  RAND(S,SIZE(A))
%   returns an array the same size as A.
%
%   Note: The size inputs M, N, P, ... should be nonnegative integers.
%   Negative integers are treated as 0.
%
%   R = RAND(..., 'double') or R = RAND(..., 'single') returns an array of
%   uniform values of the specified class.
%
%   The sequence of numbers produced by RAND is determined by the internal state
%   of the random number stream S.  Resetting that stream to the same fixed
%   state allows computations to be repeated.  Setting the stream to different
%   states leads to unique computations, however, it does not improve any
%   statistical properties.
%
%   See also RAND, RANDSTREAM, RANDSTREAM/RANDI, RANDSTREAM/RANDN, RANDSTREAM/RANDPERM.

%   Copyright 2008 The MathWorks, Inc. 
%   $Revision: 1.1.6.2 $  $Date: 2008/09/13 06:57:07 $
%   Mex function.
