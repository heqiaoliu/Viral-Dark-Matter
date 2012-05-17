function C = hypot(A,B)
%HYPOT Robust computation of square root of sum of squares for codistributed array
%   C = HYPOT(A,B)
%   
%   Example:
%   spmd
%       N = 1000;
%       D1 = 3e300*codistributed.ones(N);
%       D2 = 4e300*codistributed.ones(N);
%       E = hypot(D1,D2)
%   end
%   
%   See also HYPOT, CODISTRIBUTED, CODISTRIBUTED/ONES.


%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/03/25 21:59:07 $

C = codistributed.pElementwiseBinaryOp(@hypot, A, B);
