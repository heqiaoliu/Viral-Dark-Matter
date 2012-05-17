function P = angle(H)
%ANGLE Phase angle of codistributed array
%   Y = ANGLE(X)
%   
%   Example:
%   spmd
%       N = 1000;
%       D = 1i * codistributed.ones(N);
%       E = angle(D)
%   end
%   
%   See also ANGLE, CODISTRIBUTED, CODISTRIBUTED/SQRT.


%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/03/25 21:57:53 $

P = codistributed.pElementwiseUnaryOp(@angle, H);
