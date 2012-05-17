function Z = realpow(X,Y)
%REALPOW Real power of codistributed array
%   Z = REALPOW(X,Y)
%   
%   Example:
%   spmd
%       N = 1000;
%       D = -8*codistributed.ones(N)
%       try realpow(D,1/3), catch, disp('complex output!'), end
%       E = realpow(-D,1/3)
%   end
%   
%   See also REALPOW, CODISTRIBUTED.


%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/03/25 22:00:21 $

Z = codistributed.pElementwiseBinaryOp(@realpow, X, Y);
