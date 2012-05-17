%BITSET Set bit.
%   C = BITSET(A,BIT) sets bit position BIT in A to 1 (on). A must be an
%   unsigned integer or an array of unsigned integers, and BIT must be a 
%   number between 1 and the length in bits of the unsigned integer class 
%   of A, e.g., 32 for UINT32s.
%
%   C = BITSET(A,BIT,V) sets the bit at position BIT to the value V.
%   V must be either 0 or 1.
%
%   Example:
%      Repeatedly subtract powers of 2 from the largest UINT32 value:
%
%      a = intmax('uint32')
%      for i = 1:32, a = bitset(a,32-i+1,0), end
%
%   See also BITGET, BITAND, BITOR, BITXOR, BITCMP, BITSHIFT, INTMAX.

%   Copyright 1984-2005 The MathWorks, Inc.
%   $Revision: 1.18.4.5 $  $Date: 2005/06/21 19:36:14 $
