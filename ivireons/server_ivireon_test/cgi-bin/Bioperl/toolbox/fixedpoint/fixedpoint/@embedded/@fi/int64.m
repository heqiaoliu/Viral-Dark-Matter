function n = int64(this)
%INT64  Stored integer value of fi object as built-in int64
%   INT64(A) returns the stored integer value of fixed-point number A as
%   an int64 data type.  If the data will not fit in an int64, then the
%   data is rounded-to-nearest and saturated with no warning.
%
%   For the smallest native data type that will fit, use INT.  For data
%   types with word lengths greater than 64, use INTARRAY.
%
%   Example:
%
%     a = fi([-1 0.1 1]', 1, 45, 44);
%     int64(a)
%
%   returns
%     -17592186044416      % = -1
%       1759218604442      % =  0.1
%      17592186044415      % =  1-2^-44
%
%   Compare to bin(a)
%     100000000000000000000000000000000000000000000  % = -1     
%     000011001100110011001100110011001100110011010  % =  0.1   
%     011111111111111111111111111111111111111111111  % =  1-2^-44
%
%   See also FI, EMBEDDED.FI/INT, EMBEDDED.FI/BIN,
%            EMBEDDED.FI/OCT, EMBEDDED.FI/DEC, 
%            EMBEDDED.FI/HEX

%   Copyright 1999-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/01/29 15:33:33 $

if embedded.fi.Is64BitPlatform && this.wordlength <= 64
  n = int64(this.simulinkarray);
else
  n = int64(double(stripscaling(this)));
end
