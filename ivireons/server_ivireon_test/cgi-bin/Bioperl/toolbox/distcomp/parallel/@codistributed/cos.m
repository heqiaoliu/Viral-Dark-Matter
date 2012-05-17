function Y = cos(X)
%COS Cosine of codistributed array in radians
%   Y = COS(X)
%   
%   Example:
%   spmd
%       N = 1000;
%       D = codistributed.zeros(N);
%       E = cos(D)
%   end
%   
%   See also COS, CODISTRIBUTED, CODISTRIBUTED/ZEROS.


%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/03/25 21:58:28 $

Y = codistributed.pElementwiseUnaryOp(@cos, X);
