%BITCMP Complement bits.
%   C = BITCMP(A) returns the bitwise complement of A, where A is an unsigned
%   integer or an array of unsigned integers.
%
%   C = BITCMP(A,N) returns the bit-wise complement of A as an N-bit
%   unsigned integer. A may not have any bits sets higher than N, i.e. may
%   not have value greater than 2^N-1. The largest value of N is the number of
%   bits in the unsigned integer class of A, e.g., the largest value for
%   UINT32s is N=32.
%
%   Example:
%      a = uint16(intmax('uint8'))
%      bitcmp(a,8)
%
%   See also BITAND, BITOR, BITXOR, BITSHIFT, BITSET, BITGET, INTMAX.

%   Copyright 1984-2005 The MathWorks, Inc.
%   $Revision: 1.15.4.6 $  $Date: 2005/06/21 19:36:11 $

