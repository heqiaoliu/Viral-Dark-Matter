%DOUBLE Double-precision  floating-point real-world value of fi object
%   DOUBLE(A) returns the real-world value of fi object A in 
%   double-precision floating point. 
%
%   Fixed-point numbers can be represented as:
%
%      real_world_value = 2^(-fraction_length)*(stored_integer)
%
%   or, equivalently,
%
%      real_world_value = (slope * stored_integer) + (bias)
%   
%   DOUBLE(A) returns the real_world_value corresponding to A.
%
%   See also EMBEDDED.FI/SINGLE

%   Copyright 1999-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2006/11/19 21:18:27 $