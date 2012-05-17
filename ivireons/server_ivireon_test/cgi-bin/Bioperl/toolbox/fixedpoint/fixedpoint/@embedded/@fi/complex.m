function c = complex(a,b)
%COMPLEX Construct complex result from real and imaginary parts
%   C = COMPLEX(A,B) returns the complex result A + Bi, where A and B are
%   identically sized real N-D arrays, matrices, or scalars of the same data type.
%   Note: In the event that B is all zeros, C is complex with all zero imaginary
%   part, unlike the result of the addition A+0i, which returns a
%   strictly real result.
%
%   C = COMPLEX(A) for real A returns the complex result C with real part A
%   and all zero imaginary part. Even though its imaginary part is all zero,
%   C is complex and so isreal(C) returns false.
%
%   See also EMBEDDED.FI/IMAG, EMBEDDED.FI/REAL

%   Thomas A. Bryan, 6 February 2003
%   Copyright 2003-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2006/12/20 07:11:59 $

% Assign the output data type to be same as the left-most FI object.
if nargin==1
    % complex(a)
  c = binaryop_complex(a,0);
else
  % complex(a,b)
  c = binaryop_complex(a,b);
end
