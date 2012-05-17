function Z = atan2(Y,X)
%ATAN2 Four quadrant inverse tangent of codistributed array
%   Z = ATAN2(Y,X)
%   
%   Example:
%   spmd
%       N = 1000;
%       D = codistributed.ones(N);
%       E = atan2(D,D)
%   end
%   
%   See also ATAN2, CODISTRIBUTED, CODISTRIBUTED/ONES.


%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/03/25 21:58:02 $

Z = codistributed.pElementwiseBinaryOp(@atan2, Y, X);
