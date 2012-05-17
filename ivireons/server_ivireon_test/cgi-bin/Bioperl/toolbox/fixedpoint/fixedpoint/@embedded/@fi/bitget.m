%BITGET Bit at certain position
%   C = BITGET(A, BIT) returns the value of the bit at position BIT in A.  
%   BIT must be a number between 1 and the number of bits in the fixed-point
%   integer representation of A.  If A has a signed numerictype, then the bit
%   representation of the stored integer is in two's complement representation.
%
%   BITGET only supports fi objects with fixed-point data types.
%
%   The return type of BITGET is u1,0 (unsigned integer of word length 1).
%  
%   Example:
%     a = fi(-4:4,1,16,0)
%     c = bitget(a,1)
%     % returns bit 1, the least-significat bit of each number:
%     %  0     1     0     1     0     1     0     1     0
%     % Note the even (0), odd (1) least-significant bits.
%
%
%   See also EMBEDDED.FI/BITSLICEGET, EMBEDDED.FI/BITCONCAT
%            EMBEDDED.FI/BITAND, EMBEDDED.FI/BITCMP, EMBEDDED.FI/BITOR, 
%            EMBEDDED.FI/BITSET, EMBEDDED.FI/BITXOR.

%   Copyright 1999-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2008/07/18 18:39:51 $
