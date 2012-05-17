function n = int32(this)
%INT32  Stored integer value of fi object as built-in int32
%   INT32(A) returns the stored integer value of fixed-point number A as
%   an int32 data type.  If the data will not fit in an int32, then the
%   data is rounded-to-nearest and saturated with no warning.
%
%   For the smallest native data type that will fit, use INT.  For data
%   types with word lengths greater than 32, use INTARRAY.
%
%   Example:
%
%     a = fi([-1 0.1 1]', 1, 32, 31);
%     int32(a)
%
%   returns
%     -2147483648      % = -1
%       214748365      % =  0.1
%      2147483647      % =  1-2^-31
%
%   Compare to bin(a)
%     10000000000000000000000000000000  % = -1     
%     00001100110011001100110011001101  % =  0.1   
%     01111111111111111111111111111111  % =  1-2^-31
%
%   See also FI, EMBEDDED.FI/INT, EMBEDDED.FI/BIN,
%            EMBEDDED.FI/OCT, EMBEDDED.FI/DEC, 
%            EMBEDDED.FI/HEX

%   Thomas A. Bryan, 14 January 2004
%   Copyright 1999-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2006/12/20 07:12:16 $

if this.wordlength <= 32
  n = int32(int(this));
else
  n = int32(double(stripscaling(this)));
end
