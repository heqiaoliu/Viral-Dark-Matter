%RANDI Pseudorandom integers from a uniform discrete distribution.
%   R = RANDI(IMAX,N) returns an N-by-N matrix containing pseudorandom
%   integer values drawn from the discrete uniform distribution on 1:IMAX.
%   RANDI(IMAX,M,N) or RANDI(IMAX,[M,N]) returns an M-by-N matrix.
%   RANDI(IMAX,M,N,P,...) or RANDI(IMAX,[M,N,P,...]) returns an
%   M-by-N-by-P-by-... array.  RANDI(IMAX) returns a scalar.
%   RANDI(IMAX,SIZE(A)) returns an array the same size as A.
%
%   R = RANDI([IMIN,IMAX],...) returns an array containing integer
%   values drawn from the discrete uniform distribution on IMIN:IMAX.
%
%   Note: The size inputs M, N, P, ... should be nonnegative integers.
%   Negative integers are treated as 0.
%
%   R = RANDI(..., CLASSNAME) returns an array of integer values of class
%   CLASSNAME.
%
%   The sequence of numbers produced by RANDI is determined by the internal
%   state of the uniform pseudorandom number generator that underlies RAND,
%   RANDI, and RANDN.  RANDI uses one uniform value from that default
%   stream to generate each integer value.  Control the default stream using
%   its properties and methods.  See RANDSTREAM for details about the
%   default stream.
%
%   Resetting the default stream to the same fixed state allows computations
%   to be repeated.  Setting the stream to different states leads to unique
%   computations, however, it does not improve any statistical properties.
%   Since MATLAB uses the same state each time it starts up, RAND, RANDN, and
%   RANDI will generate the same sequence of numbers in each session unless
%   the state is changed.
%
%   Examples:
%
%      Generate integer values from the uniform distribution on the set 1:10.
%         r = randi(10,100,1);
%
%      Generate an integer array of integers drawn uniformly from 1:10.
%         r = randi(10,100,1,'uint32');
%
%      Generate integer values drawn uniformly from -10:10.
%         r = randi([-10 10],100,1);
%
%      Save the current state of the default stream, generate 5 integer
%      values, restore the state, and repeat the sequence.
%         defaultStream = RandStream.getDefaultStream;
%         savedState = defaultStream.State;
%         i1 = randi(10,1,5)
%         defaultStream.State = savedState;
%         i2 = randi(10,1,5) % contains exactly the same values as i1
%
%      Replace the default stream with a stream whose seed is based on CLOCK, so
%      RANDI will return different values in different MATLAB sessions.  NOTE: It
%      is usually not desirable to do this more than once per MATLAB session.
%         RandStream.setDefaultStream(RandStream('mt19937ar','seed',sum(100*clock)));
%         randi(10,1,5)
%
%   See also RAND, RANDN, RANDSTREAM, RANDSTREAM/RANDI, RANDSTREAM.GETDEFAULTSTREAM.

%   Copyright 2008 The MathWorks, Inc. 
%   $Revision: 1.1.6.2 $  $Date: 2008/09/13 06:57:04 $
%   Built-in function.
