function n = uint8(this)
%UINT8  Stored integer value of fi object as built-in uint8
%   UINT8(A) returns the stored integer value of fixed-point number A as
%   an uint8 data type.  If the data will not fit in an uint8, then the
%   data is rounded-to-nearest and saturated with no warning.
%
%   For the smallest native data type that will fit, use INT.  For data
%   types with word lengths greater than 32, use INTARRAY.
%
%   Example:
%
%     a = fi([pi 0.1 1]', 0, 8, 5);
%     uint8(a)
%
%   returns
%     101      % =  pi
%       3      % =  0.1
%      32      % =  1
%
%   Compare to bin(a)
%     01100101  % =  pi     
%     00000011  % =  0.1   
%     00100000  % =  1
%
%   See also FI, EMBEDDED.FI/INT, EMBEDDED.FI/BIN, 
%            EMBEDDED.FI/OCT, EMBEDDED.FI/DEC, EMBEDDED.FI/HEX

%   Thomas A. Bryan, 14 January 2004
%   Copyright 1999-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2006/12/20 07:13:04 $

if this.wordlength <= 32
  n = uint8(int(this));
else
  n = uint8(double(stripscaling(this)));
end
