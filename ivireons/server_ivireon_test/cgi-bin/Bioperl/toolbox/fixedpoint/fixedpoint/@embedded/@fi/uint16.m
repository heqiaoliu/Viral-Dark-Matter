function n = uint16(this)
%UINT16 Stored integer value of fi object as built-in uint16
%   UINT16(A) returns the stored integer value of fixed-point number A as
%   an uint16 data type.  If the data will not fit in an uint16, then the
%   data is rounded-to-nearest and saturated with no warning.
%
%   For the smallest native data type that will fit, use INT.  For data
%   types with word lengths greater than 32, use INTARRAY.
%
%   Example:
%
%     a = fi([pi 0.1 1]', 0, 16, 13);
%     uint16(a)
%
%   returns
%     25736      % =  pi
%       819      % =  0.1
%      8192      % =  1
%
%   Compare to bin(a)
%     0110010010001000  % =  pi     
%     0000001100110011  % =  0.1   
%     0010000000000000  % =  1
%
%   See also FI, EMBEDDED.FI/INT, EMBEDDED.FI/BIN, 
%            EMBEDDED.FI/OCT, EMBEDDED.FI/DEC, EMBEDDED.FI/HEX

%   Thomas A. Bryan, 14 January 2004
%   Copyright 1999-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2006/12/20 07:13:01 $

if this.wordlength <= 32
  n = uint16(int(this));
else
  n = uint16(double(stripscaling(this)));
end
