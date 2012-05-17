function Z = power(X,Y)
%.^ Array power for codistributed array
%   C = A .^ B
%   C = POWER(A,B)
%   
%   Example:
%   spmd
%       N = 1000;
%       D1 = 2*codistributed.eye(N);
%       D2 = D1 .^ 2
%   end
%   
%   See also POWER, CODISTRIBUTED, CODISTRIBUTED/EYE.


%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/03/25 22:00:02 $

Z = codistributed.pElementwiseBinaryOp(@power,X,Y);
