function n = uint64(this)
%UINT64  Stored integer value of fi object as built-in uint64
%   UINT64(A) returns the stored integer value of fixed-point number A as
%   an uint64 data type.  If the data will not fit in an uint64, then the
%   data is rounded-to-nearest and saturated with no warning.
%
%   For the smallest native data type that will fit, use INT.  For data
%   types with word lengths greater than 64, use INTARRAY.
%
%   Example:
%
%     a = fi([pi 0.1 1]', 0, 45, 42);
%     uint64(a)
%
%   returns
%     13816870609431      % = pi
%       439804651110      % =  0.1
%      4398046511104      % =  1
%
%   Compare to bin(a)
%     011001001000011111101101010100010001000010111 % = pi
%     000000110011001100110011001100110011001100110 % = 0.1
%     001000000000000000000000000000000000000000000 % = 1
%
%   See also FI, EMBEDDED.FI/INT, EMBEDDED.FI/BIN,
%            EMBEDDED.FI/OCT, EMBEDDED.FI/DEC, 
%            EMBEDDED.FI/HEX

%   Copyright 1999-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/01/29 15:33:36 $

if embedded.fi.Is64BitPlatform && this.wordlength <= 64
  n = uint64(this.simulinkarray);
else
  n = uint64(double(stripscaling(this)));
end
