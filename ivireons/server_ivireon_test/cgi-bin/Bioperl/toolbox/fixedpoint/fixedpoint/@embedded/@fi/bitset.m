%BITSET Set bit at certain position
%   C = BITSET(A, BIT) sets bit position BIT in a to 1 (on). 
%   C = BITSET(A, BIT, V) sets bit position BIT in A to V. V must be 0 
%   (off) or 1 (on). Any value v other than 0 is automatically set to 1.
%
%   BIT must be a number between 1 and the number of bits in the fixed-point
%   integer representation of A. If A has a signed numerictype, then the bit
%   representation of the stored integer is in two's complement
%   representation. 
%
%   BITSET only supports fi objects with fixed-point data types.
%
%   Example:
%     a = fi(-4:4,1,16,0)
%     c = bitset(a,1,1)
%     % sets bit 1, the least-significant bit of each number and returns:
%     % -3    -3    -1    -1     1     1     3     3     5
%     % Note that it turned them all into odd numbers.
%
%   See also EMBEDDED.FI/BITAND, EMBEDDED.FI/BITCMP, EMBEDDED.FI/BITGET, 
%            EMBEDDED.FI/BITOR, EMBEDDED.FI/BITXOR

%   Copyright 1999-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2008/07/18 18:39:54 $
