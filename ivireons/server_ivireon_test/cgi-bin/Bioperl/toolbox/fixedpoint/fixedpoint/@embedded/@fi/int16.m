function n = int16(this)
%INT16 Stored integer value of fi object as built-in int16 
%   INT16(A) returns the stored integer value of fixed-point number A as
%   an int16 data type.  If the data will not fit in an int16, then the
%   data is rounded-to-nearest and saturated with no warning.
%
%   For the smallest native data type that will fit, use INT.  For data
%   types with word lengths greater than 32, use INTARRAY.
%
%   Example:
%
%     a = fi([-1 0.1 1]', 1, 16, 15);
%     int16(a)
%
%   returns
%     -32768      % = -1
%       3277      % =  0.1
%      32767      % =  1-2^-15
%
%   Compare to bin(a)
%     1000000000000000  % = -1     
%     0000110011001101  % =  0.1   
%     0111111111111111  % =  1-2^-15
%
%   See also EMBEDDED.FI/INT, EMBEDDED.FI/BIN, 
%            EMBEDDED.FI/OCT, EMBEDDED.FI/DEC, 
%            EMBEDDED.FI/HEX

%   Thomas A. Bryan, 14 January 2004
%   Copyright 1999-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2006/12/20 07:12:15 $

if this.wordlength <= 32
  n = int16(int(this));
else
  n = int16(double(stripscaling(this)));
end
