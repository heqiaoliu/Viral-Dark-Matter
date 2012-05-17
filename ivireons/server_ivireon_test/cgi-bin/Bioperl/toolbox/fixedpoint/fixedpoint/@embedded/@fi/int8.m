function n = int8(this)
%INT8  Stored integer value of fi object as built-in int8
%   INT8(A) returns the stored integer value of fixed-point number A as
%   an int8 data type.  If the data will not fit in an int8, then the
%   data is rounded-to-nearest and saturated with no warning.
%
%   For the smallest native data type that will fit, use INT.  For data
%   types with word lengths greater than 32, use INTARRAY.
%
%   Example:
%
%     a = fi([-1 0.1 1]', 1, 8, 7);
%     int8(a)
%
%   returns
%     -128      % = -1
%       13      % =  0.1
%      127      % =  1-2^-7
%
%   Compare to bin(a)
%    10000000   % = -1     
%    00001101   % =  0.1   
%    01111111   % =  1-2^-7
%
%   See also FI, EMBEDDED.FI/INT, EMBEDDED.FI/BIN, 
%            EMBEDDED.FI/OCT, EMBEDDED.FI/DEC, EMBEDDED.FI/HEX

%   Thomas A. Bryan, 14 January 2004
%   Copyright 1999-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2006/12/20 07:12:17 $

if this.wordlength <= 32
  n = int8(int(this));
else
  n = int8(double(stripscaling(this)));
end
