%EYE Identity matrix.
%   EYE(N) is the N-by-N identity matrix.
%
%   EYE(M,N) or EYE([M,N]) is an M-by-N matrix with 1's on
%   the diagonal and zeros elsewhere.
%
%   EYE(SIZE(A)) is the same size as A.
%
%   EYE with no arguments is the scalar 1.
%
%   EYE(M,N,CLASSNAME) or EYE([M,N],CLASSNAME) is an M-by-N matrix with 1's
%   of class CLASSNAME on the diagonal and zeros elsewhere.
%
%   Note: The size inputs M and N should be nonnegative integers. 
%   Negative integers are treated as 0.
%
%   Example:
%      x = eye(2,3,'int8');
%
%   See also SPEYE, ONES, ZEROS, RAND, RANDN.

%   Copyright 1984-2005 The MathWorks, Inc. 
%   $Revision: 5.8.4.5 $  $Date: 2005/04/28 19:53:49 $
%   Built-in function.

