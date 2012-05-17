function C = complex(A,B)
%COMPLEX Construct complex codistributed array from real and imaginary parts
%   C = COMPLEX(A,B)
%   
%   Example:
%   spmd
%       N = 1000;
%       D1 = 3*codistributed.ones(N);
%       D2 = 4*codistributed.ones(N);
%       E = complex(D1,D2)
%   end
%   
%   See also COMPLEX, CODISTRIBUTED, CODISTRIBUTED/ONES.


%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/03/25 21:58:26 $

if ~isValidInputForComplex(A) || (nargin > 1 && ~isValidInputForComplex(B))
      error('distcomp:codistributed:complex:Input', ...
          'Inputs must be numeric, real, and full.');
end

if nargin == 1
   C = codistributed.pElementwiseUnaryOp(@complex, A);
else
   C = codistributed.pElementwiseBinaryOp(@complex, A, B);
end

%%%subfunction

function flag = isValidInputForComplex(A)
%   Check if A is a valid input for COMPLEX
flag = isreal(A) && ~issparse(A); % && isnumeric(A);
