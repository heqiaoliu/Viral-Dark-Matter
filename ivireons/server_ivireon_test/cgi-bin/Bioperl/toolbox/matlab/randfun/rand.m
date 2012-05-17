%RAND Uniformly distributed pseudorandom numbers.
%   R = RAND(N) returns an N-by-N matrix containing pseudorandom values drawn
%   from the standard uniform distribution on the open interval(0,1).  RAND(M,N)
%   or RAND([M,N]) returns an M-by-N matrix.  RAND(M,N,P,...) or
%   RAND([M,N,P,...]) returns an M-by-N-by-P-by-... array.  RAND returns a
%   scalar.  RAND(SIZE(A)) returns an array the same size as A.
%
%   Note: The size inputs M, N, P, ... should be nonnegative integers.
%   Negative integers are treated as 0.
%
%   R = RAND(..., 'double') or R = RAND(..., 'single') returns an array of
%   uniform values of the specified class.
%
%   Compatibility Note: In versions of MATLAB prior to 7.7, you controlled
%   the internal state of the random number stream used by RAND by calling
%   RAND directly with the 'seed', 'state', or 'twister' keywords.  That
%   syntax is still supported for backwards compatibility, but is deprecated.
%   Beginning in MATLAB 7.7, use the default stream as described in
%   RANDSTREAM.
%
%   The sequence of numbers produced by RAND is determined by the internal
%   state of the uniform pseudorandom number generator that underlies RAND,
%   RANDI, and RANDN.  Control that default random number stream using its
%   properties and methods.  See RANDSTREAM for details about the default
%   stream.
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
%      Generate values from the uniform distribution on the interval [a, b].
%         r = a + (b-a).*rand(100,1);
%
%      Use the RANDI function to generate to generate one integer value from the
%      uniform distribution on the set 1:100.
%         r = randi(100,1);
%
%      Save the current state of the default stream, generate 5 values,
%      restore the state, and repeat the sequence.
%         defaultStream = RandStream.getDefaultStream;
%         savedState = defaultStream.State;
%         u1 = rand(1,5)
%         defaultStream.State = savedState;
%         u2 = rand(1,5) % contains exactly the same values as u1
%
%      Replace the default stream with a stream whose seed is based on CLOCK, so
%      RAND will return different values in different MATLAB sessions.  NOTE: It
%      is usually not desirable to do this more than once per MATLAB session.
%         RandStream.setDefaultStream(RandStream('mt19937ar','seed',sum(100*clock)));
%         rand(1,5)
%
%   See also RANDI, RANDN, RANDSTREAM, RANDSTREAM/RAND, RANDSTREAM.GETDEFAULTSTREAM,
%            SPRAND, SPRANDN, RANDPERM.

%   Copyright 1984-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2010/02/25 08:10:34 $
%   Built-in function.


% ================ Copyright notice for the Mersenne Twister ================
%
%    A C-program for MT19937, with initialization improved 2002/1/26.
%    Coded by Takuji Nishimura and Makoto Matsumoto.
%
%    Copyright (C) 1997 - 2002, Makoto Matsumoto and Takuji Nishimura,
%    All rights reserved.
%
%    Redistribution and use in source and binary forms, with or without
%    modification, are permitted provided that the following conditions
%    are met:
%
%      1. Redistributions of source code must retain the above copyright
%         notice, this list of conditions and the following disclaimer.
%
%      2. Redistributions in binary form must reproduce the above copyright
%         notice, this list of conditions and the following disclaimer in the
%         documentation and/or other materials provided with the distribution.
%
%      3. The names of its contributors may not be used to endorse or promote
%         products derived from this software without specific prior written
%         permission.
%
%    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
%    "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
%    LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
%    A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR
%    CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
%    EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
%    PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
%    PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
%    LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
%    NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
%    SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
%
%
%    Any feedback is very welcome.
%    http://www.math.keio.ac.jp/matumoto/emt.html
%    email: matumoto@math.keio.ac.jp

% ================ end ================
