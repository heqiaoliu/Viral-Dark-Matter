function D = eps(X)
%EPS Spacing of floating point numbers for codistributed array
%   E = EPS(D)
%   
%   Example:
%   spmd
%       N = 1000;
%       D = codistributed.ones(N,'single');
%       E = eps(D)
%   end
%   
%   returns E = eps('single')*codistributed.ones(N).
%   
%   See also EPS, CODISTRIBUTED, CODISTRIBUTED/ONES.


%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/03/25 21:58:47 $

D = codistributed.pElementwiseUnaryOp(@eps,X);
