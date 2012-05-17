function Y = round(X)
%ROUND Round towards nearest integer for codistributed array
%   Y = ROUND(X)
%   
%   Example:
%   spmd
%       N = 1000;
%       D = codistributed.colon(1, N)./2
%       E = round(D)
%   end
%   
%   See also ROUND, CODISTRIBUTED, CODISTRIBUTED/COLON, CODISTRIBUTED/ZEROS


%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/03/25 22:00:29 $

Y = codistributed.pElementwiseUnaryOp(@round, X);
