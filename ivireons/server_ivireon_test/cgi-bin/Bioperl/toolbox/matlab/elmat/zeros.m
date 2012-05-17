%ZEROS  Zeros array.
%   ZEROS(N) is an N-by-N matrix of zeros.
%
%   ZEROS(M,N) or ZEROS([M,N]) is an M-by-N matrix of zeros.
%
%   ZEROS(M,N,P,...) or ZEROS([M N P ...]) is an M-by-N-by-P-by-... array of
%   zeros.
%
%   ZEROS(SIZE(A)) is the same size as A and all zeros.
%
%   ZEROS with no arguments is the scalar 0.
%
%   ZEROS(M,N,...,CLASSNAME) or ZEROS([M,N,...],CLASSNAME) is an
%   M-by-N-by-... array of zeros of class CLASSNAME.
%
%   Note: The size inputs M, N, and P... should be nonnegative integers. 
%   Negative integers are treated as 0.
%
%   Example:
%      x = zeros(2,3,'int8');
%
%   See also EYE, ONES.

%   Copyright 1984-2005 The MathWorks, Inc.
%   $Revision: 5.10.4.5 $  $Date: 2005/04/28 19:54:17 $
%   Built-in function.

