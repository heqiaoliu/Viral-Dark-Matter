function V = digitalShifts(N)
%DIGITALSHIFTS Create random digital shifts.
%
%  DIGITALSHIFTS(N) returns a vector of N digital shifts.

%  References:
%    [1] Hee Sun Hong and Fred J. Hickernell (2003) ALGORITHM 823
%        Implementing Scrambled Disgital Sequences, ACM Transactions on
%        Mathematical Software, Vol. 29, No. 2.

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $    $Date: 2010/03/16 00:21:29 $

NBits = 53;
V = uint64(rand(1,N).*(2^NBits));
