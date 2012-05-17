function C = mrdivide(A,B)
%/ Slash or right matrix divide for codistributed array
%   C = A / B
%   C = MRDIVIDE(A,B)
%   
%   B must be scalar.
%   
%   Example:
%   spmd
%       N = 1000;
%       D1 = codistributed.colon(1, N)'
%       D2 = D1 / 2
%   end
%   
%   See also MRDIVIDE, CODISTRIBUTED, CODISTRIBUTED/COLON, CODISTRIBUTED/ZEROS.


%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/03/25 21:59:34 $

if isscalar(B)
   C = codistributed.pElementwiseBinaryOp(@rdivide,A,B);
else
   error('distcomp:codistributed:mrdivide:nonscalarB', ...
       'Input B must be scalar.')
end
