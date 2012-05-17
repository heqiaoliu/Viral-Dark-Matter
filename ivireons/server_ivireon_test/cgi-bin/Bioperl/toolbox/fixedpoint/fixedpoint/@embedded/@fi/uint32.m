function n = uint32(this)
%UINT32 Stored integer value of fi object as built-in uint32
%   UINT32(A) returns the stored integer value of fixed-point number A as
%   an uint32 data type.  If the data will not fit in an uint32, then the
%   data is rounded-to-nearest and saturated with no warning.
%
%   For the smallest native data type that will fit, use INT.  For data
%   types with word lengths greater than 32, use INTARRAY.
%
%   Example:
%
%     a = fi([pi 0.1 1]', 0, 32, 29);
%     uint32(a)
%
%   returns
%     1686629713      % =  pi
%       53687091      % =  0.1
%      536870912      % =  1
%
%   Compare to bin(a)
%     01100100100001111110110101010001  % =  pi     
%     00000011001100110011001100110011  % =  0.1   
%     00100000000000000000000000000000  % =  1
%
%   See also FI, EMBEDDED.FI/INT, EMBEDDED.FI/BIN,
%            EMBEDDED.FI/OCT, EMBEDDED.FI/DEC, EMBEDDED.FI/HEX

%   Thomas A. Bryan, 14 January 2004
%   Copyright 1999-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2006/12/20 07:13:03 $

if this.wordlength <= 32
  n = uint32(int(this));
else
  n = uint32(double(stripscaling(this)));
end
