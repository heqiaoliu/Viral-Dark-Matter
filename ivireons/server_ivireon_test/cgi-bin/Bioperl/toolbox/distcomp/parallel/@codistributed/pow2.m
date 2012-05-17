function X = pow2(F,E)
%POW2 Base 2 power and scale floating point number for codistributed array
%   X = POW2(Y)
%   X = POW2(F,E)
%   
%   Example:
%   spmd
%       N = 1000;
%       D = codistributed.colon(1, N)
%       E = pow2(D)
%   end
%   
%   See also POW2, CODISTRIBUTED, CODISTRIBUTED/COLON, CODISTRIBUTED/ZEROS.


%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/03/25 22:00:00 $

if nargin == 1
   X = codistributed.pElementwiseUnaryOp(@pow2, F);
else
   X = codistributed.pElementwiseBinaryOp(@pow2, F, E);
end

