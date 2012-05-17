function Z = rem(X,Y)
%REM Remainder after division for codistributed array
%   C = REM(A,B)
%   
%   Example:
%   spmd
%       N = 1000;
%       D = rem(codistributed.colon(1, N),2)
%   end
%   
%   See also REM, CODISTRIBUTED, CODISTRIBUTED/COLON, CODISTRIBUTED/ZEROS.


%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/03/25 22:00:25 $

Z = codistributed.pElementwiseBinaryOp(@rem, X, Y);
