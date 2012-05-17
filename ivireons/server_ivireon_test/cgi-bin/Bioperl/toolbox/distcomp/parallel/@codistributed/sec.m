function Y = sec(X)
%SEC Secant of codistributed array in radians
%   Y = SEC(X)
%   
%   Example:
%   spmd
%       N = 1000;
%       D = codistributed.zeros(N);
%       E = sec(D)
%   end
%   
%   See also SEC, CODISTRIBUTED, CODISTRIBUTED/ZEROS.


%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/03/25 22:00:30 $

Y = codistributed.pElementwiseUnaryOp(@sec, X);
