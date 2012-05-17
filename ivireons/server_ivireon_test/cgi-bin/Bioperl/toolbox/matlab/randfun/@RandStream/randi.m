%RANDI Pseudorandom integers from a uniform discrete distribution.
%   R = RANDI(S,IMAX,N) returns an N-by-N matrix containing pseudorandom
%   integer values drawn from the discrete uniform distribution on 1:IMAX.
%   RANDI draws those values from the random stream S.  RANDI(S,IMAX,M,N) or
%   RANDI(S,IMAX,[M,N]) returns an M-by-N matrix.  RANDI(S,IMAX,M,N,P,...)
%   or RANDI(S,IMAX,[M,N,P,...]) returns an M-by-N-by-P-by-... array.
%   RANDI(S,IMAX) returns a scalar.  RANDI(S,IMAX,SIZE(A)) returns an array
%   the same size as A.
%
%   R = RANDI(S,[IMIN,IMAX],...) returns an array containing integer
%   values drawn from the discrete uniform distribution on IMIN:IMAX.
%
%   Note: The size inputs M, N, P, ... should be nonnegative integers.
%   Negative integers are treated as 0.
%
%   R = RANDI(..., CLASSNAME) returns an array of integer values of class
%   CLASSNAME.
%
%   The sequence of numbers produced by RANDI is determined by the internal
%   state of the random stream S.  RANDI uses one uniform value from S to
%   generate each integer value.  Resetting that stream to the same fixed state
%   allows computations to be repeated.  Setting the stream to different states
%   leads to unique computations, however, it does not improve any statistical
%   properties.
%
%   See also RANDI, RANDSTREAM, RANDSTREAM/RAND, RANDSTREAM/RANDN.

%   Copyright 2008 The MathWorks, Inc. 
%   $Revision: 1.1.6.2 $  $Date: 2008/09/13 06:57:08 $
%   Mex function.
