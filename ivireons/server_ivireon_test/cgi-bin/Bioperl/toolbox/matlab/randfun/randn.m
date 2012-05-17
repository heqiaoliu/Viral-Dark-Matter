%RANDN Normally distributed pseudorandom numbers.
%   R = RANDN(N) returns an N-by-N matrix containing pseudorandom values drawn
%   from the standard normal distribution.  RANDN(M,N) or RANDN([M,N]) returns
%   an M-by-N matrix. RANDN(M,N,P,...) or RANDN([M,N,P,...]) returns an
%   M-by-N-by-P-by-... array. RANDN returns a scalar.  RANDN(SIZE(A)) returns
%   an array the same size as A.
%
%   Note: The size inputs M, N, P, ... should be nonnegative integers.
%   Negative integers are treated as 0.
%
%   R = RANDN(..., 'double') or R = RANDN(..., 'single') returns an array of
%   normal values of the specified class.
%
%   Compatibility Note: In versions of MATLAB prior to 7.7, you controlled
%   the internal state of the random number stream used by RANDN by calling
%   RANDN directly with the 'seed' or 'state' keywords.  That syntax is
%   still supported for backwards compatibility, but is deprecated. Beginning
%   in MATLAB 7.7, use the default stream as described in RANDSTREAM.
%
%   The sequence of numbers produced by RANDN is determined by the internal
%   state of the uniform pseudorandom number generator that underlies RAND,
%   RANDI, and RANDN.  RANDN uses one or more uniform values from that
%   default stream to generate each normal value.  Control the default
%   stream using its properties and methods.  See RANDSTREAM for details
%   about the default stream.
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
%      Generate values from a normal distribution with mean 1 and standard
%      deviation 2.
%         r = 1 + 2.*randn(100,1);
%
%      Generate values from a bivariate normal distribution with specified mean
%      vector and covariance matrix.
%         mu = [1 2];
%         Sigma = [1 .5; .5 2]; R = chol(Sigma);
%         z = repmat(mu,100,1) + randn(100,2)*R;
%
%      Save the current state of the default stream, generate 5 values,
%      restore the state, and repeat the sequence.
%         defaultStream = RandStream.getDefaultStream;
%         savedState = defaultStream.State;
%         z1 = randn(1,5)
%         defaultStream.State = savedState;
%         z2 = randn(1,5) % contains exactly the same values as z1
%
%      Replace the default stream with a stream whose seed is based on CLOCK, so
%      RANDN will return different values in different MATLAB sessions.  NOTE: It
%      is usually not desirable to do this more than once per MATLAB session.
%         RandStream.setDefaultStream(RandStream('mt19937ar','seed',sum(100*clock)));
%         randn(1,5)
%
%   See also RAND, RANDI, RANDSTREAM, RANDSTREAM/RANDN, RANDSTREAM.GETDEFAULTSTREAM.

%   Copyright 1984-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2008/09/13 06:57:05 $
%   Built-in function.
