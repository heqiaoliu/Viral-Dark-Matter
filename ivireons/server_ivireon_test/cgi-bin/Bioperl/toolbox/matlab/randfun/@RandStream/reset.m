function reset(s,seed)
%RESET Reset a random stream to its initial internal state.
%   RESET(S) resets the generator for the random stream S to its initial
%   internal state.  This is almost equivalent to clearing S and recreating
%   it using RandStream(TYPE,...), except RESET does not set the stream's
%   RandnAlg, Antithetic, and Precision properties to their original values.
%
%   RESET(S,SEED) resets the generator for the random stream S to the initial
%   internal state corresponding to the seed SEED.  Resetting a stream's seed
%   can invalidate independence with other streams.
%
%   Resetting a stream should be used primarily for reproducing results.
%
%   See also RANDSTREAM, RANDSTREAM/RANDSTREAM.

%   Copyright 2008 The MathWorks, Inc. 
%   $Revision: 1.1.6.2 $  $Date: 2008/08/08 12:56:20 $
%   Mex function.
