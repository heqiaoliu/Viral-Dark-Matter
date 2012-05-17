function Z = mod(X,Y)
%MOD Modulus after division of codistributed array
%   C = MOD(A,B)
%   
%   Example:
%   spmd
%       N = 1000;
%       D = mod(codistributed.colon(1,N),2)
%   end
%   
%   See also MOD, CODISTRIBUTED, CODISTRIBUTED/COLON, CODISTRIBUTED/ZEROS.


%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/03/25 21:59:33 $

Z = codistributed.pElementwiseBinaryOp(@mod, X, Y);
